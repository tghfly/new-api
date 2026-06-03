# 调用日志分权分域 — 详细设计

## 1. 修订记录

| 版本 | 日期 | 作者 | 描述 |
|------|------|------|------|
| v0.1 | 2026-06-02 | | 初始版本 |

## 2. 整体架构

### 2.1 架构概览

```
┌──────────────────────────────────────────────────────────────────┐
│  pkg/permission/         通用权限解析框架                          │
│   Resolver              基于 primaryKey + fallbackKey 解析权限     │
│   ParseFunc             权限 value 解析函数类型                    │
│   Result                HasAuth + Data map（各权限类型自定义）     │
│   LogsAuth              （预定义的日志权限解析器实例）              │
│   (未来) ChannelAuth    （预定义的渠道权限解析器实例）              │
└───────────┬──────────────────────────────────────────────────────┘
            │ Resolve(c) → Result{HasAuth, Data: {"scope":"all"}}
            │
┌───────────▼──────────────────────────────────────────────────────┐
│  middleware/dcloud.go    变薄：context 设置 + 保持原有导出符号     │
│   DCloudAuth()           设置 vdc_code / other_role_map           │
│   DCloudAuthRequired()   设置 vdc_code / other_role_map           │
│   ResolveLogAuth()       转发到 permission.LogsAuth.Resolve()     │
└───────────┬──────────────────────────────────────────────────────┘
            │
┌───────────▼──────────────────────────────────────────────────────┐
│  middleware/auth.go      AdminAuth 绕过泛化                       │
│   authHelper()           检查 other_role_map 中任意               │
│                          new-api:*:auth key，有则跳过 role 检查    │
└───────────┬──────────────────────────────────────────────────────┘
            │
┌───────────▼──────────────────────────────────────────────────────┐
│  controller/log.go       auth.Data["scope"] / ["orgs"] / ["dept_id"]
│   GetAllLogs             DCloud 分支：按 scope 做数据过滤          │
│   GetLogsStat            DCloud 分支：按 scope 做数据过滤          │
│   DeleteHistoryLogs      DCloud 分支：按 scope 控制删除权限        │
└───────────┬──────────────────────────────────────────────────────┘
            │
┌───────────▼──────────────────────────────────────────────────────┐
│  model/log.go            GroupFilter 已是通用设计，无需变动        │
│   applyGroupFilter()     根据 Mode (prefix/exact/in) 生成条件      │
└──────────────────────────────────────────────────────────────────┘
```

### 2.2 核心设计原则

1. **权限解析框架通用化**：`pkg/permission/` 只负责 key 查找和 value 解析分发，不感知具体字段。每个权限类型通过 `ParseFunc` 自定义 value 解析逻辑，解析结果存入 `Data map`，框架不限制 data 结构。
2. **新增权限类型 0 成本接入框架**：只需实现 `ParseFunc` + 创建 `Resolver` 实例，框架层无需修改。
3. **模块独立测试**：`pkg/permission/` 是纯函数，无外部依赖，可独立单元测试。Model 层的 `GroupFilter` 已设计为通用结构。

## 3. 通用权限解析框架 (`pkg/permission/permission.go`)

### 3.1 类型定义

```go
package permission

// Result 权限解析结果。
// HasAuth 表示是否持有有效权限。
// Data 包含具体的权限数据，keys 由各权限类型的 ParseFunc 定义。
type Result struct {
    HasAuth bool
    Data    map[string]interface{}
}

// ParseFunc 权限 value 解析函数。
// 输入: other_role_map 中的 value 字符串
// 输出: data — 解析后的数据 map，keys 由具体权限类型定义
//       ok   — false 表示格式不合法，视为该 key 不存在
type ParseFunc func(value string) (data map[string]interface{}, ok bool)
```

### 3.2 Resolver 结构体

```go
// Resolver 权限解析器，用于从 other_role_map 解析指定资源的权限。
// 每个权限类型（日志、渠道等）对应一个 Resolver 实例，各自定义 primaryKey、
// fallbackKey 和 parseFunc。
type Resolver struct {
    primaryKey  string    // 资源专用权限 key，如 "new-api:logs:auth"
    fallbackKey string    // 通用权限 key，如 "new-api:auth"
    parseFunc   ParseFunc // value 解析函数，由各权限类型自定义
}

// NewResolver 创建权限解析器。
// primaryKey 为空时不查主 key，fallbackKey 为空时不查兜底 key。
func NewResolver(primaryKey, fallbackKey string, parseFunc ParseFunc) *Resolver {
    return &Resolver{
        primaryKey:  primaryKey,
        fallbackKey: fallbackKey,
        parseFunc:   parseFunc,
    }
}
```

### 3.3 Resolve 方法

```go
// Resolve 从 gin context 中解析权限。
// 1. 从 context 获取 other_role_map
// 2. 优先查 primaryKey，调用 parseFunc 解析 value
// 3. primaryKey 不存在或格式错误时查 fallbackKey
// 4. 均不存在或格式错误时返回 HasAuth=false
// 5. 解析成功时自动注入 dept_id 到 Data（从 context 获取）
//
// 格式错误的 value 视为该 key 不存在，继续兜底逻辑。
func (r *Resolver) Resolve(c *gin.Context) Result {
    otherRoleMapRaw, exists := c.Get("other_role_map")
    if !exists {
        return Result{HasAuth: false}
    }
    otherRoleMap, ok := otherRoleMapRaw.(map[string]string)
    if !ok || len(otherRoleMap) == 0 {
        return Result{HasAuth: false}
    }

    // 尝试解析 value
    data := r.tryResolve(otherRoleMap)
    if data == nil {
        return Result{HasAuth: false}
    }

    // 注入 dept_id（通用上下文信息）
    if deptId := getDeptId(c); deptId != "" {
        data["dept_id"] = deptId
    }

    return Result{HasAuth: true, Data: data}
}

// tryResolve 尝试从 other_role_map 中按优先级查找并解析 value。
func (r *Resolver) tryResolve(otherRoleMap map[string]string) map[string]interface{} {
    // 1. 优先查 primaryKey
    if r.primaryKey != "" {
        if value, exists := otherRoleMap[r.primaryKey]; exists && value != "" {
            if data, ok := r.parseFunc(value); ok {
                return data
            }
            // 格式错误 → 视为该 key 不存在，继续兜底
        }
    }

    // 2. 查 fallbackKey
    if r.fallbackKey != "" {
        if value, exists := otherRoleMap[r.fallbackKey]; exists && value != "" {
            if data, ok := r.parseFunc(value); ok {
                return data
            }
        }
    }

    return nil
}

// getDeptId 从 context 获取 dept_id（vdc_code）
func getDeptId(c *gin.Context) string {
    if deptId, exists := c.Get("vdc_code"); exists {
        if str, ok := deptId.(string); ok {
            return str
        }
    }
    return ""
}
```

### 3.4 日志权限类型定义

日志权限的 Data map 约定如下 keys：

| Data key | 类型 | 说明 |
|---------|------|------|
| `"scope"` | `string` | 权限范围：`"all"`, `"spec_down"`, `"spec"`, `"local_down"`, `"local"`, `"me"` |
| `"orgs"` | `[]string` | 组织编码列表（仅 spec_down / spec 有值） |
| `"dept_id"` | `string` | 当前用户的 dept_id（由 Resolve 方法自动注入） |

```go
// pkg/permission/logs.go

package permission

// 日志权限 scope 值
const (
    LogScopeAll       = "all"
    LogScopeSpecDown  = "spec_down"
    LogScopeSpec      = "spec"
    LogScopeLocalDown = "local_down"
    LogScopeLocal     = "local"
    LogScopeMe        = "me"
)

// parseLogAuthValue 解析日志权限 value。
// 支持的格式：
//   "all" → {scope: "all"}
//   "spec_down:020,021" → {scope: "spec_down", orgs: ["020","021"]}
//   "spec:020" → {scope: "spec", orgs: ["020"]}
//   "local_down" → {scope: "local_down"}
//   "local" → {scope: "local"}
//   "me" → {scope: "me"}
func parseLogAuthValue(value string) (map[string]interface{}, bool) {
    scope, orgs, ok := parseScopeValue(value)
    if !ok {
        return nil, false
    }
    data := map[string]interface{}{
        "scope": scope,
    }
    if len(orgs) > 0 {
        data["orgs"] = orgs
    }
    return data, true
}
```

### 3.5 parseScopeValue 辅助函数

`parseScopeValue` 是对 `scope:org1,org2` 格式的通用解析器。如果后续其他权限类型也使用相同的 scope 格式，可以直接复用此函数。

```go
// parseScopeValue 解析 "scope" 或 "scope:org1,org2" 格式的 value。
// 返回 scope、orgs 和是否解析成功。
func parseScopeValue(value string) (scope string, orgs []string, ok bool)
```

**解析规则：**

| Value 格式 | scope | orgs | ok |
|-----------|-------|------|----|
| `"all"` | `"all"` | 空 | true |
| `"spec_down:X,Y"` | `"spec_down"` | `["X", "Y"]` | true |
| `"spec:X,Y"` | `"spec"` | `["X", "Y"]` | true |
| `"local_down"` | `"local_down"` | 空 | true |
| `"local"` | `"local"` | 空 | true |
| `"me"` | `"me"` | 空 | true |

**格式错误处理（全部返回 ok=false）：**

| Value 输入 | 原因 |
|-----------|------|
| `""` | 空字符串 |
| `"ALL"` | 大小写不匹配 |
| `"spec_down:"` | 冒号后无组织编码 |
| `"spec_down: "` | 冒号后为空白字符 |
| `"spec_down:020,"` | 尾部逗号导致空元素 |
| `" unknown:xxx"` | 前导空格 |
| `"unknown_scope"` | 无法识别的 scope 名称 |

### 3.6 预定义的权限解析器实例

```go
// 预定义的权限解析器实例
var (
    // LogsAuth 日志权限解析器
    LogsAuth = NewResolver("new-api:logs:auth", "new-api:auth", parseLogAuthValue)

    // 后续其他权限类型在此添加：
    // ChannelAuth = NewResolver("new-api:channel:auth", "new-api:auth", parseChannelAuthValue)
    // UserAuth    = NewResolver("new-api:user:auth",     "new-api:auth", parseUserAuthValue)
)
```

### 3.7 包结构

```
pkg/permission/
├── permission.go      # 核心：Result / ParseFunc / Resolver / NewResolver / Resolve
├── scope.go           # parseScopeValue 辅助函数（scope 格式公用解析器）
├── logs.go            # 日志权限：parseLogAuthValue + LogsAuth 实例 + scope 常量
├── permission_test.go # 通用框架单元测试
└── logs_test.go       # 日志权限单元测试
```

## 4. 认证中间件模块 (`middleware/auth.go`)

### 4.1 context 补充

#### 4.1.1 DCloudAuth

在 `DCloudAuth()` 的 JWT 认证成功后（第 318 行 `c.Set("use_access_token", false)` 之后），补充：

```go
c.Set("vdc_code", claims.VdcCode)
c.Set("other_role_map", claims.OtherRoleMap)
```

#### 4.1.2 DCloudAuthRequired

在 `DCloudAuthRequired()` 的 JWT 认证成功后（第 400 行 `c.Set("use_access_token", false)` 之后），补充：

```go
c.Set("vdc_code", claims.VdcCode)
c.Set("other_role_map", claims.OtherRoleMap)
```

#### 4.1.3 authHelper

在 `authHelper()` 的 DCloud JWT 认证分支中（第 91-96 行 `dcloudAuth = true` 之后），补充：

```go
c.Set("vdc_code", claims.VdcCode)
c.Set("other_role_map", claims.OtherRoleMap)
```

### 4.2 AdminAuth 修改 — 泛化权限 key 绕过

**修改位置：** `authHelper()` 函数，`role.(int) < minRole` 检查之前（第 177 行）。

**修改后逻辑：**

```
authHelper(c, minRole)
  ...
  └─ if DCloudIntegrationEnabled && dcloudAuth
       └─ 从 context 获取 other_role_map
            └─ 检查是否存在 key 匹配前缀 "new-api:" + 后缀 ":auth" 的模式
                 ├─ 存在任意匹配 → skipRoleCheck = true
                 └─ 不存在 → skipRoleCheck = false
  ├─ if !skipRoleCheck && role.(int) < minRole
  │    └─ 返回 403 权限不足（原逻辑）
  └─ 继续设置 context → c.Next()（原逻辑）
```

**具体代码：**

```go
// DCloud 权限 key 绕过 role 检查
skipRoleCheck := false
if common.DCloudIntegrationEnabled && dcloudAuth {
    if otherRoleMapRaw, exists := c.Get("other_role_map"); exists {
        if otherRoleMap, ok := otherRoleMapRaw.(map[string]string); ok {
            for key := range otherRoleMap {
                if strings.HasPrefix(key, "new-api:") && strings.HasSuffix(key, ":auth") {
                    skipRoleCheck = true
                    break
                }
            }
        }
    }
}

// 原 role 检查
if !skipRoleCheck && role.(int) < minRole {
    c.JSON(http.StatusOK, gin.H{
        "success": false,
        "message": "无权进行此操作，权限不足",
    })
    c.Abort()
    return
}
```

> **设计说明：** 使用前缀 `"new-api:"` + 后缀 `":auth"` 模式匹配，而非硬编码 key 列表。这样新增权限类型时（如 `new-api:channel:auth`），AdminAuth 自动支持绕过，无需修改中间件代码。控制器层面的细粒度权限过滤由各 controller 自行调用对应的 `permission.XXXResolver` 完成。

## 5. 日志控制器模块 (`controller/log.go`)

### 5.1 修改点概览

三个接口 `GetAllLogs`、`GetLogsStat`、`DeleteHistoryLogs` 增加 DCloud 权限前置判断：

```
if common.DCloudIntegrationEnabled {
    auth := permission.LogsAuth.Resolve(c)
    if auth.HasAuth {
        scope := getLogScope(auth.Data)  // 从 Data map 读取
        handleDCloudBranch(c, scope, auth.Data)
        return
    }
    // HasAuth=false → 继续走原有 RoleAdminUser / RoleRootUser 逻辑
}
// DCloudIntegrationEnabled == false → 继续走原有逻辑
```

### 5.2 辅助函数：从 Data map 读取日志权限字段

```go
// getLogScope 从 Data map 中安全读取 scope
func getLogScope(data map[string]interface{}) string {
    if v, ok := data["scope"]; ok {
        if s, ok := v.(string); ok {
            return s
        }
    }
    return ""
}

// getLogOrgs 从 Data map 中安全读取 orgs
func getLogOrgs(data map[string]interface{}) []string {
    if v, ok := data["orgs"]; ok {
        if s, ok := v.([]string); ok {
            return s
        }
    }
    return nil
}

// getLogDeptId 从 Data map 中安全读取 dept_id
func getLogDeptId(data map[string]interface{}) string {
    if v, ok := data["dept_id"]; ok {
        if s, ok := v.(string); ok {
            return s
        }
    }
    return ""
}
```

### 5.3 GetAllLogs DCloud 分支

```go
if common.DCloudIntegrationEnabled {
    auth := permission.LogsAuth.Resolve(c)
    if auth.HasAuth {
        scope := getLogScope(auth.Data)
        switch scope {
        case permission.LogScopeAll:
            handleGetAllLogs(c, nil)

        case permission.LogScopeSpecDown:
            handleGetAllLogs(c, &model.GroupFilter{
                Mode: "prefix",
                Orgs: getLogOrgs(auth.Data),
            })

        case permission.LogScopeSpec:
            handleGetAllLogs(c, &model.GroupFilter{
                Mode: "in",
                Orgs: getLogOrgs(auth.Data),
            })

        case permission.LogScopeLocalDown:
            handleGetAllLogs(c, &model.GroupFilter{
                Mode: "prefix",
                Orgs: []string{getLogDeptId(auth.Data)},
            })

        case permission.LogScopeLocal:
            handleGetAllLogs(c, &model.GroupFilter{
                Mode: "exact",
                Orgs: []string{getLogDeptId(auth.Data)},
            })

        case permission.LogScopeMe:
            handleGetUserLogs(c)

        default:
            // 无法识别的 scope → 返回空数据
            returnEmptyLogData(c)
        }
        return
    }
    // HasAuth=false → 继续走原有逻辑
}
```

**Scope ↔ GroupFilter 映射关系：**

| Scope | Mode | Orgs 来源 |
|-------|------|----------|
| `all` | — | 无过滤 |
| `spec_down` | `prefix` | `auth.Data["orgs"]` |
| `spec` | `in` | `auth.Data["orgs"]` |
| `local_down` | `prefix` | `[auth.Data["dept_id"]]` |
| `local` | `exact` | `[auth.Data["dept_id"]]` |
| `me` | — | 调用 `model.GetUserLogs(userId, ...)` |
| (未知) | — | 返回空数据 |

### 5.4 GetLogsStat DCloud 分支

```go
if common.DCloudIntegrationEnabled {
    auth := permission.LogsAuth.Resolve(c)
    if auth.HasAuth {
        scope := getLogScope(auth.Data)
        switch scope {
        case permission.LogScopeAll:
            handleGetLogsStat(c, "", nil)

        case permission.LogScopeSpecDown:
            handleGetLogsStat(c, "", &model.GroupFilter{
                Mode: "prefix", Orgs: getLogOrgs(auth.Data),
            })

        case permission.LogScopeSpec:
            handleGetLogsStat(c, "", &model.GroupFilter{
                Mode: "in", Orgs: getLogOrgs(auth.Data),
            })

        case permission.LogScopeLocalDown:
            handleGetLogsStat(c, "", &model.GroupFilter{
                Mode: "prefix", Orgs: []string{getLogDeptId(auth.Data)},
            })

        case permission.LogScopeLocal:
            handleGetLogsStat(c, "", &model.GroupFilter{
                Mode: "exact", Orgs: []string{getLogDeptId(auth.Data)},
            })

        case permission.LogScopeMe:
            // 仅统计当前用户（使用 context 中的 username，而非 query 参数）
            handleGetLogsStat(c, c.GetString("username"), nil)

        default:
            returnEmptyLogStat(c)
        }
        return
    }
}
```

> **安全说明：** `me` scope 时，`username` 参数使用 `c.GetString("username")`（当前登录用户），而非从 query 参数读取，防止越权查看他人统计数据。

### 5.5 DeleteHistoryLogs DCloud 分支

```go
if common.DCloudIntegrationEnabled {
    auth := permission.LogsAuth.Resolve(c)
    if auth.HasAuth {
        scope := getLogScope(auth.Data)
        if scope == permission.LogScopeMe {
            c.JSON(http.StatusForbidden, gin.H{
                "success": false, "message": "无删除权限",
            })
            return
        }

        targetTimestamp, _ := strconv.ParseInt(c.Query("target_timestamp"), 10, 64)
        if targetTimestamp == 0 {
            c.JSON(http.StatusOK, gin.H{
                "success": false, "message": "target timestamp is required",
            })
            return
        }

        var groupFilter *model.GroupFilter
        switch scope {
        case permission.LogScopeAll:
            groupFilter = nil
        case permission.LogScopeSpecDown:
            groupFilter = &model.GroupFilter{Mode: "prefix", Orgs: getLogOrgs(auth.Data)}
        case permission.LogScopeSpec:
            groupFilter = &model.GroupFilter{Mode: "in", Orgs: getLogOrgs(auth.Data)}
        case permission.LogScopeLocalDown:
            groupFilter = &model.GroupFilter{Mode: "prefix", Orgs: []string{getLogDeptId(auth.Data)}}
        case permission.LogScopeLocal:
            groupFilter = &model.GroupFilter{Mode: "exact", Orgs: []string{getLogDeptId(auth.Data)}}
        default:
            c.JSON(http.StatusForbidden, gin.H{
                "success": false, "message": "无删除权限",
            })
            return
        }

        count, err := model.DeleteOldLog(c.Request.Context(), targetTimestamp, 100, groupFilter)
        if err != nil {
            common.ApiError(c, err)
            return
        }
        c.JSON(http.StatusOK, gin.H{
            "success": true, "message": "", "data": count,
        })
        return
    }
}
```

### 5.6 辅助函数

```go
// handleGetAllLogs 提取公用的 GetAllLogs 查询逻辑
func handleGetAllLogs(c *gin.Context, groupFilter *model.GroupFilter) {
    pageInfo := common.GetPageQuery(c)
    logType, _ := strconv.Atoi(c.Query("type"))
    startTimestamp, _ := strconv.ParseInt(c.Query("start_timestamp"), 10, 64)
    endTimestamp, _ := strconv.ParseInt(c.Query("end_timestamp"), 10, 64)
    username := c.Query("username")
    tokenName := c.Query("token_name")
    modelName := c.Query("model_name")
    channel, _ := strconv.Atoi(c.Query("channel"))
    group := c.Query("group")
    requestId := c.Query("request_id")
    logs, total, err := model.GetAllLogs(
        logType, startTimestamp, endTimestamp,
        modelName, username, tokenName,
        pageInfo.GetStartIdx(), pageInfo.GetPageSize(),
        channel, group, requestId,
        groupFilter,
    )
    if err != nil {
        common.ApiError(c, err)
        return
    }
    pageInfo.SetTotal(int(total))
    pageInfo.SetItems(logs)
    common.ApiSuccess(c, pageInfo)
}

// handleGetUserLogs 提取公用的 GetUserLogs 查询逻辑
func handleGetUserLogs(c *gin.Context) {
    pageInfo := common.GetPageQuery(c)
    userId := c.GetInt("id")
    logType, _ := strconv.Atoi(c.Query("type"))
    startTimestamp, _ := strconv.ParseInt(c.Query("start_timestamp"), 10, 64)
    endTimestamp, _ := strconv.ParseInt(c.Query("end_timestamp"), 10, 64)
    tokenName := c.Query("token_name")
    modelName := c.Query("model_name")
    group := c.Query("group")
    requestId := c.Query("request_id")
    logs, total, err := model.GetUserLogs(
        userId, logType, startTimestamp, endTimestamp,
        modelName, tokenName,
        pageInfo.GetStartIdx(), pageInfo.GetPageSize(),
        group, requestId,
        nil, // me scope 只按 userId 过滤
    )
    if err != nil {
        common.ApiError(c, err)
        return
    }
    pageInfo.SetTotal(int(total))
    pageInfo.SetItems(logs)
    common.ApiSuccess(c, pageInfo)
}

// handleGetLogsStat 提取公用的统计查询逻辑
func handleGetLogsStat(c *gin.Context, username string, groupFilter *model.GroupFilter) {
    logType, _ := strconv.Atoi(c.Query("type"))
    startTimestamp, _ := strconv.ParseInt(c.Query("start_timestamp"), 10, 64)
    endTimestamp, _ := strconv.ParseInt(c.Query("end_timestamp"), 10, 64)
    tokenName := c.Query("token_name")
    modelName := c.Query("model_name")
    channel, _ := strconv.Atoi(c.Query("channel"))
    group := c.Query("group")
    stat, err := model.SumUsedQuota(
        logType, startTimestamp, endTimestamp,
        modelName, username, tokenName,
        channel, group,
        groupFilter,
    )
    if err != nil {
        common.ApiError(c, err)
        return
    }
    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
        "data": gin.H{
            "quota": stat.Quota,
            "rpm":   stat.Rpm,
            "tpm":   stat.Tpm,
        },
    })
}

func returnEmptyLogData(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
        "data":    gin.H{},
    })
}

func returnEmptyLogStat(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
        "data": gin.H{
            "quota": 0,
            "rpm":   0,
            "tpm":   0,
        },
    })
}
```

> **重构说明：** `handleGetUserLogs` 与现有 `GetUserLogs` 控制器函数逻辑一致。推荐将 `GetUserLogs` 控制器的查询逻辑提取重用。

## 6. Model 层扩展 (`model/log.go`)

### 6.1 GroupFilter 结构体

```go
// GroupFilter 组织过滤条件
type GroupFilter struct {
    Mode string   // "prefix" | "exact" | "in"
    Orgs []string // 组织编码列表
}
```

### 6.2 applyGroupFilter 辅助函数

```go
// applyGroupFilterWithTable 将 GroupFilter 应用到 GORM tx。
// tablePrefix: 表名前缀，如 "logs."，为空时不加前缀。
func applyGroupFilterWithTable(tx *gorm.DB, groupFilter *GroupFilter, tablePrefix string) *gorm.DB {
    if groupFilter == nil || len(groupFilter.Orgs) == 0 {
        return tx
    }

    groupCol := tablePrefix + logGroupCol

    switch groupFilter.Mode {
    case "prefix":
        conditions := make([]string, 0, len(groupFilter.Orgs))
        args := make([]interface{}, 0, len(groupFilter.Orgs))
        for _, org := range groupFilter.Orgs {
            conditions = append(conditions, groupCol+" LIKE ?")
            args = append(args, org+"%")
        }
        return tx.Where(strings.Join(conditions, " OR "), args...)

    case "exact":
        if len(groupFilter.Orgs) == 1 {
            return tx.Where(groupCol+" = ?", groupFilter.Orgs[0])
        }
        return tx.Where(groupCol+" IN ?", groupFilter.Orgs)

    case "in":
        return tx.Where(groupCol+" IN ?", groupFilter.Orgs)

    default:
        return tx
    }
}

// applyGroupFilter 便捷封装，默认使用 "logs." 表名前缀。
func applyGroupFilter(tx *gorm.DB, groupFilter *GroupFilter) *gorm.DB {
    return applyGroupFilterWithTable(tx, groupFilter, "logs.")
}
```

### 6.3 各查询方法扩展

#### GetAllLogs

**扩展后签名（GroupFilter 为最后参数）：**

```go
func GetAllLogs(logType int, startTimestamp int64, endTimestamp int64, modelName string, username string,
    tokenName string, startIdx int, num int, channel int, group string, requestId string,
    groupFilter *GroupFilter) (logs []*Log, total int64, err error)
```

**新增逻辑：** 在现有 group 精确匹配之后，增加：

```go
if groupFilter != nil {
    tx = applyGroupFilter(tx, groupFilter)
}
```

#### GetUserLogs

**扩展后签名：**

```go
func GetUserLogs(userId int, logType int, startTimestamp int64, endTimestamp int64, modelName string,
    tokenName string, startIdx int, num int, group string, requestId string,
    groupFilter *GroupFilter) (logs []*Log, total int64, err error)
```

**新增逻辑：** 在现有 group 精确匹配之后，增加：

```go
if groupFilter != nil {
    tx = applyGroupFilter(tx, groupFilter)
}
```

#### SumUsedQuota

**扩展后签名：**

```go
func SumUsedQuota(logType int, startTimestamp int64, endTimestamp int64, modelName string, username string,
    tokenName string, channel int, group string,
    groupFilter *GroupFilter) (stat Stat, err error)
```

**新增逻辑：** 在现有 group 精确匹配之后，同时应用到 `tx` 和 `rpmTpmQuery`：

```go
if groupFilter != nil {
    tx = applyGroupFilter(tx, groupFilter)
    rpmTpmQuery = applyGroupFilter(rpmTpmQuery, groupFilter)
}
```

#### DeleteOldLog

**扩展后签名：**

```go
func DeleteOldLog(ctx context.Context, targetTimestamp int64, limit int, groupFilter *GroupFilter) (int64, error)
```

**新增逻辑：** 在 `Delete` 之前增加 group 过滤：

```go
tx := LOG_DB.Where("created_at < ?", targetTimestamp)
if groupFilter != nil {
    tx = applyGroupFilterWithTable(tx, groupFilter, "") // DeleteOldLog 不使用表别名
}
result := tx.Limit(limit).Delete(&Log{})
```

> **注意：** `DeleteOldLog` 不使用表别名，因此调用 `applyGroupFilterWithTable` 时 `tablePrefix` 传空字符串。

## 7. 数据库兼容性

| 方面 | 策略 |
|------|------|
| `group` 列引用 | 使用 `logGroupCol` 变量：PostgreSQL → `"group"`，MySQL/SQLite → `` `group` `` |
| LIKE 查询 | GORM 参数化查询 `LIKE ?`，参数传 `org+"%"`，防 SQL 注入 |
| IN 查询 | GORM 切片参数 `IN ?`，自动展开为 `IN (?,?,...)` |
| GroupFilter 为空 | 不附加任何条件，原行为不变 |

## 8. 错误处理

| 场景 | 处理 |
|------|------|
| Value 格式错误（如 `"spec_down:"`、`"ALL"`） | `parseFunc` 返回 `ok=false`，`Resolve` 返回 `HasAuth=false`，回退到内置角色逻辑 |
| `HasAuth=true` 但 Data 中 scope 不在已知列表中 | Controller 返回空数据/空统计 |
| `me` 权限调用 `DeleteHistoryLogs` | 403 + "无删除权限" |
| `DCloudIntegrationEnabled=false` | 不执行 DCloud 分支，完全走原逻辑 |
| DB 查询错误 | 按现有方式返回 500 |

## 9. 模块依赖关系

```
                            ┌─────────────────────────────────┐
                            │   pkg/permission/                │
                            │   Resolver / Result / ParseFunc  │
                            │   logs.go: parseLogAuthValue     │
                            │           LogsAuth 实例          │
                            │   scope.go: parseScopeValue      │
                            └──────┬──────────────────────────┘
                                   │ 被调用
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
          ▼                        ▼                        ▼
┌──────────────────┐   ┌──────────────────┐   ┌──────────────────────┐
│ middleware/       │   │ middleware/       │   │ controller/log.go    │
│ dcloud.go        │   │ auth.go          │   │ permission.LogsAuth  │
│ (context 设置)    │   │ AdminAuth 绕过    │   │ .Resolve(c)          │
└──────────────────┘   └──────────────────┘   │ auth.Data["scope"]   │
                                               └──────────┬───────────┘
                                                          │ 调用
                                                          ▼
                                                 ┌──────────────────┐
                                                 │ model/log.go     │
                                                 │ GroupFilter      │
                                                 │ applyGroupFilter │
                                                 └──────────────────┘
```

**依赖方向：**
- `middleware/dcloud.go` → `pkg/permission/`（可选转发）
- `middleware/auth.go` → 读取 context 中的 `other_role_map`（不直接依赖 `pkg/permission/`）
- `controller/log.go` → `pkg/permission/`（调用 `LogsAuth.Resolve`）+ `model/log.go`（调用查询方法）

## 10. 可测试性设计

### 10.1 模块解耦

| 模块 | 外部依赖 | 测试方式 | 可独立测试 |
|------|---------|---------|-----------|
| `pkg/permission/` (Resolver, ParseFunc) | `gin.Context`（通过 Set 注入） | 纯函数单元测试 | ✅ |
| `middleware/auth.go` (AdminAuth 绕过) | `gin.Context`, `sessions` | httptest + mock session | ✅ |
| `controller/log.go` (DCloud 分支) | `permission.LogsAuth`, model 查询 | 集成测试 (SQLite 内存DB) | ✅ |
| `model/log.go` (GroupFilter) | GORM + DB | 集成测试 (SQLite 内存DB) | ✅ |

### 10.2 各模块测试策略

#### 10.2.1 pkg/permission/ — 单元测试

直接构造带 `other_role_map` 的 `gin.Context`，调用 `Resolver.Resolve` 并验证返回值。无需 mock：

```go
func makeContext(otherRoleMap map[string]string, vdcCode string) *gin.Context {
    c, _ := gin.CreateTestContext(httptest.NewRecorder())
    c.Set("other_role_map", otherRoleMap)
    c.Set("vdc_code", vdcCode)
    return c
}

// 测试 LogsAuth Resolver
func TestLogsAuth_Resolve_All(t *testing.T) {
    c := makeContext(map[string]string{"new-api:logs:auth": "all"}, "")
    result := permission.LogsAuth.Resolve(c)
    assert.True(t, result.HasAuth)
    assert.Equal(t, "all", result.Data["scope"])
}
```

#### 10.2.2 middleware/auth.go — 单元测试 (httptest)

```go
func makeAdminAuthRequest(t *testing.T, dcloudEnabled bool,
    otherRoleMap map[string]string, role int) *httptest.ResponseRecorder {
    original := common.DCloudIntegrationEnabled
    common.DCloudIntegrationEnabled = dcloudEnabled
    defer func() { common.DCloudIntegrationEnabled = original }()

    w := httptest.NewRecorder()
    c, _ := gin.CreateTestContext(w)
    c.Set("other_role_map", otherRoleMap)
    c.Set("role", role)
    AdminAuth()(c)
    return w
}
```

#### 10.2.3 controller/log.go — 集成测试

使用 SQLite 内存数据库，验证完整请求→响应流程：

```go
func setupLogControllerTest(t *testing.T) {
    db, _ := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
    db.AutoMigrate(&model.Log{})
    db.Create(&model.Log{UserId: 1, Group: "0201", ...})
    originalDB := model.LOG_DB
    model.LOG_DB = db
    t.Cleanup(func() { model.LOG_DB = originalDB })
}
```

#### 10.2.4 model/log.go — 集成测试

```go
func setupModelTest(t *testing.T) *gorm.DB {
    db, _ := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
    db.AutoMigrate(&model.Log{})
    db.Create(&Log{Group: "0201"})
    db.Create(&Log{Group: "0202"})
    db.Create(&Log{Group: "0301"})
    model.LOG_DB = db
    return db
}
```

### 10.3 接口抽象方案（可选）

```go
// controller/log_service.go（可选）
type LogQueryService interface {
    GetAllLogs(...) ([]*model.Log, int64, error)
    GetUserLogs(...) ([]*model.Log, int64, error)
    SumUsedQuota(...) (model.Stat, error)
    DeleteOldLog(...) (int64, error)
}
```

考虑到当前代码架构不使用接口注入模式，**优先推荐集成测试方案**。接口抽象可在后续确有必要时引入。

## 11. 测试用例

### 11.1 权限解析框架测试用例 (pkg/permission/)

#### Resolve 方法（使用 LogsAuth 实例）

| 编号 | 测试场景 | `other_role_map` | `vdc_code` | 期望 `HasAuth` | 期望 `Data` |
|------|---------|-----------------|-----------|---------------|------------|
| TC-P-01 | primaryKey→all | `{"new-api:logs:auth":"all"}` | — | `true` | `{"scope":"all"}` |
| TC-P-02 | primaryKey→spec_down 多组织 | `{"new-api:logs:auth":"spec_down:020,021"}` | — | `true` | `{"scope":"spec_down","orgs":["020","021"]}` |
| TC-P-03 | primaryKey→spec 单组织 | `{"new-api:logs:auth":"spec:020"}` | — | `true` | `{"scope":"spec","orgs":["020"]}` |
| TC-P-04 | primaryKey→local_down（含 dept_id） | `{"new-api:logs:auth":"local_down"}` | `"020"` | `true` | `{"scope":"local_down","dept_id":"020"}` |
| TC-P-05 | primaryKey→local（含 dept_id） | `{"new-api:logs:auth":"local"}` | `"020"` | `true` | `{"scope":"local","dept_id":"020"}` |
| TC-P-06 | primaryKey→me | `{"new-api:logs:auth":"me"}` | — | `true` | `{"scope":"me"}` |
| TC-P-07 | 优先级：两个 key 都存在 | `{"new-api:logs:auth":"me","new-api:auth":"all"}` | — | `true` | `{"scope":"me"}` |
| TC-P-08 | 兜底：primaryKey 空，fallbackKey 存在 | `{"new-api:auth":"all"}` | — | `true` | `{"scope":"all"}` |
| TC-P-09 | 两个 key 都不存在 | `{}` | — | `false` | `nil` |
| TC-P-10 | `other_role_map` 为 nil | — | — | `false` | `nil` |

#### parseScopeValue 边界情况

| 编号 | 测试场景 | 输入 | 期望 `ok` | 期望 `scope` |
|------|---------|------|----------|-------------|
| TC-P-11 | 格式正确：all | `"all"` | `true` | `"all"` |
| TC-P-12 | 格式正确：spec_down | `"spec_down:020,021"` | `true` | `"spec_down"` |
| TC-P-13 | 空字符串 | `""` | `false` | — |
| TC-P-14 | 大小写不匹配 | `"ALL"` | `false` | — |
| TC-P-15 | 空组织列表 | `"spec_down:"` | `false` | — |
| TC-P-16 | 空白组织 | `"spec_down: "` | `false` | — |
| TC-P-17 | 尾部逗号 | `"spec_down:020,"` | `false` | — |
| TC-P-18 | 前导空格 | `" spec:020"` | `false` | — |
| TC-P-19 | 无法识别的 scope 名称 | `"unknown_scope"` | `false` | — |

### 11.2 认证中间件模块测试用例

| 编号 | 测试场景 | `DCloudEnabled` | `dcloudAuth` | `other_role_map` | `role` | `minRole` | 期望结果 |
|------|---------|----------------|-------------|-----------------|-------|----------|---------|
| TC-A-01 | 非 DCloud 模式，role < 10 | `false` | — | — | 1 | 10 | 403 |
| TC-A-02 | 非 DCloud 模式，role >= 10 | `false` | — | — | 10 | 10 | 放行 |
| TC-A-03 | DCloud + 日志 key，role < 10 | `true` | `true` | `{"new-api:logs:auth":"all"}` | 1 | 10 | 放行 |
| TC-A-04 | DCloud + 通用 key，role < 10 | `true` | `true` | `{"new-api:auth":"all"}` | 1 | 10 | 放行 |
| TC-A-05 | DCloud + 无 key，role < 10 | `true` | `true` | `{}` | 1 | 10 | 403 |
| TC-A-06 | DCloud + 无 key，role >= 10 | `true` | `true` | `{}` | 10 | 10 | 放行 |
| TC-A-07 | DCloud + 日志 key，role >= 10 | `true` | `true` | `{"new-api:logs:auth":"me"}` | 10 | 10 | 放行 |
| TC-A-08 | DCloud + dcloudAuth=false | `true` | `false` | `{"new-api:logs:auth":"all"}` | 1 | 10 | 403 |
| TC-A-09 | DCloud + 未来扩展 key，role < 10 | `true` | `true` | `{"new-api:channel:auth":"all"}` | 1 | 10 | 放行 |

> TC-A-09 验证泛化绕过的可扩展性：新增 `new-api:channel:auth` 后，AdminAuth 自动支持，无需修改中间件代码。

### 11.3 日志控制器模块测试用例

#### GetAllLogs

| 编号 | 测试场景 | `Data["scope"]` | 调用的 Model 方法 | `GroupFilter` |
|------|---------|----------------|-----------------|--------------|
| TC-C-01 | all | `"all"` | `GetAllLogs` | `nil` |
| TC-C-02 | spec_down | `"spec_down"`, orgs=`["020","021"]` | `GetAllLogs` | `{Mode:"prefix", Orgs:["020","021"]}` |
| TC-C-03 | spec | `"spec"`, orgs=`["020"]` | `GetAllLogs` | `{Mode:"in", Orgs:["020"]}` |
| TC-C-04 | local_down | `"local_down"`, dept_id=`"020"` | `GetAllLogs` | `{Mode:"prefix", Orgs:["020"]}` |
| TC-C-05 | local | `"local"`, dept_id=`"020"` | `GetAllLogs` | `{Mode:"exact", Orgs:["020"]}` |
| TC-C-06 | me | `"me"` | `GetUserLogs` | `nil` |
| TC-C-07 | 未知 scope | `"unknown"` | 不调用 | — |
| TC-C-08 | HasAuth=false | — | 按 role 调用已有方法 | — |
| TC-C-09 | DCloud 禁用 | — | 按 role 调用已有方法 | — |

#### GetLogsStat

| 编号 | 测试场景 | `Data["scope"]` | `SumUsedQuota` 的 `username` 参数 | `GroupFilter` |
|------|---------|----------------|----------------------------------|--------------|
| TC-C-10 | all | `"all"` | `""` | `nil` |
| TC-C-11 | me | `"me"` | 当前用户 username | `nil` |
| TC-C-12 | spec_down | `"spec_down"` | `""` | `{Mode:"prefix", ...}` |
| TC-C-13 | 未知 scope | `"unknown"` | 不调用 | — |

#### DeleteHistoryLogs

| 编号 | 测试场景 | `Data["scope"]` | 期望结果 |
|------|---------|----------------|---------|
| TC-C-14 | me | `"me"` | 403 |
| TC-C-15 | all | `"all"` | 调用 `DeleteOldLog(ctx, ts, 100, nil)` |
| TC-C-16 | spec_down | `"spec_down"` | 调用 `DeleteOldLog(ctx, ts, 100, {Mode:"prefix",...})` |
| TC-C-17 | 未知 scope | `"unknown"` | 403 |

### 11.4 Model 层测试用例

前置条件：SQLite 内存数据库，插入测试数据：

| id | user_id | group | created_at | type |
|----|---------|-------|-----------|------|
| 1 | 1 | `"0201"` | 1000 | 2 |
| 2 | 2 | `"0202"` | 1000 | 2 |
| 3 | 3 | `"0301"` | 1000 | 2 |
| 4 | 1 | `"0201001"` | 1000 | 2 |
| 5 | 2 | `"020"` | 1000 | 2 |

| 编号 | 测试场景 | `GroupFilter` | 期望返回的 log id |
|------|---------|-------------|-----------------|
| TC-M-01 | prefix 单组织 | `{Mode:"prefix", Orgs:["020"]}` | 1, 2, 4, 5 |
| TC-M-02 | prefix 多组织 | `{Mode:"prefix", Orgs:["020","030"]}` | 1, 2, 3, 4, 5 |
| TC-M-03 | exact 单组织 | `{Mode:"exact", Orgs:["020"]}` | 5 |
| TC-M-04 | in 多组织 | `{Mode:"in", Orgs:["0201","0202"]}` | 1, 2 |
| TC-M-05 | nil | `nil` | 1, 2, 3, 4, 5 |
| TC-M-06 | 空 Orgs | `{Mode:"prefix", Orgs:[]}` | 1, 2, 3, 4, 5 |
| TC-M-07 | prefix 不匹配 | `{Mode:"prefix", Orgs:["040"]}` | 空 |
| TC-M-08 | in 不匹配 | `{Mode:"in", Orgs:["999"]}` | 空 |

## 12. 文件变更清单

| 文件 | 操作 | 变更内容 |
|------|------|---------|
| `pkg/permission/permission.go` | **新增** | 通用框架核心：`Result`、`ParseFunc`、`Resolver`、`NewResolver`、`Resolve` 方法 |
| `pkg/permission/scope.go` | **新增** | `parseScopeValue` 辅助函数（scope 格式公用解析器） |
| `pkg/permission/logs.go` | **新增** | 日志权限：`parseLogAuthValue` + `LogsAuth` 实例 + scope 常量 |
| `pkg/permission/permission_test.go` | **新增** | 通用框架单元测试 |
| `pkg/permission/logs_test.go` | **新增** | 日志权限单元测试 |
| `middleware/dcloud.go` | 修改 | `DCloudAuth()`/`DCloudAuthRequired()` 补充 `vdc_code`/`other_role_map` 到 context；`authHelper()` DCloud JWT 分支同样补充；`ResolveLogAuth()` 改为转发到 `permission.LogsAuth.Resolve(c)`（保持导出符号兼容） |
| `middleware/auth.go` | 修改 | `authHelper()` 中 `role < minRole` 检查前增加泛化绕过逻辑：检查 `other_role_map` 中任意 `new-api:*:auth` 前缀的 key |
| `controller/log.go` | 修改 | `GetAllLogs`/`GetLogsStat`/`DeleteHistoryLogs` 增加 DCloud 分支；新增 `getLogScope`/`getLogOrgs`/`getLogDeptId`/`handleGetAllLogs`/`handleGetUserLogs`/`handleGetLogsStat`/`returnEmptyLogData`/`returnEmptyLogStat` 辅助函数 |
| `model/log.go` | 修改 | 新增 `GroupFilter` 结构体；新增 `applyGroupFilterWithTable`/`applyGroupFilter` 辅助函数；`GetAllLogs`/`GetUserLogs`/`SumUsedQuota`/`DeleteOldLog` 扩展 `GroupFilter` 参数 |

## 13. 实施顺序

### Phase 1：通用权限解析框架

1. **`pkg/permission/`** — 新增三个源文件：
   - `permission.go`：`Result`、`ParseFunc`、`Resolver`、`NewResolver`、`Resolve`
   - `scope.go`：`parseScopeValue` 公用解析器
   - `logs.go`：`parseLogAuthValue`、`LogsAuth` 实例、scope 常量

2. **`pkg/permission/*_test.go`** — 新增测试：
   - TC-P-01 ~ TC-P-19

**验证点：** `go test ./pkg/permission/` 全部通过

### Phase 2：认证中间件改造

3. **`middleware/dcloud.go`** — 修改：
   - 补充 `vdc_code`/`other_role_map` context 设置（3 处）
   - `ResolveLogAuth()` 改为转发到 `permission.LogsAuth.Resolve(c)`

4. **`middleware/auth.go`** — 修改：
   - `authHelper()` role 检查前增加泛化绕过逻辑

**验证点：** TC-A-01 ~ TC-A-09

### Phase 3：Model 层扩展

5. **`model/log.go`** — 扩展：
   - `GroupFilter` 结构体
   - `applyGroupFilterWithTable`/`applyGroupFilter` 辅助函数
   - 四个查询方法的 `GroupFilter` 参数扩展

**验证点：** TC-M-01 ~ TC-M-08

### Phase 4：Controller 接入

6. **`controller/log.go`** — 改造：
   - 新增 8 个辅助函数
   - 三个接口的 DCloud 分支

**验证点：** TC-C-01 ~ TC-C-17

### Phase 5：集成测试

7. 编写完整的集成测试，覆盖端到端流程
