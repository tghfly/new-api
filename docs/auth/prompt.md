# 调用日志分权分域 — Coding Prompt

## 1. 项目概述

本任务为 new-api 项目实现**调用日志分权分域**功能，使日志查询接口能够接入算力平台（DCloud）的细粒度权限体系，根据用户权限动态控制日志数据的可见范围。

### 1.1 功能目标

| 权限类型（Value） | 可见范围 |
|------|---------|
| `all` | 全部日志 |
| `spec_down:org1,org2` | 指定组织及其下级（前缀匹配） |
| `spec:org1,org2` | 指定组织（精确匹配） |
| `local_down` | 当前用户所属组织及其下级（前缀匹配） |
| `local` | 当前用户所属组织 |
| `me` | 仅当前用户自己的日志 |

### 1.2 涉及接口

| 接口 | 路由 | 说明 |
|------|------|------|
| `GetAllLogs` | `GET /api/log/` | 日志列表查询 |
| `GetLogsStat` | `GET /api/log/stat` | 日志用量统计 |
| `DeleteHistoryLogs` | `DELETE /api/log/` | 删除历史日志 |

### 1.3 技术栈

- **语言**: Go 1.22+
- **Web 框架**: Gin
- **ORM**: GORM v2
- **测试**: Go 原生 `testing` 包 + `httptest`
- **代码检测**: `go vet`, `golangci-lint`

### 1.4 关键约束（必须遵守）

1. **JSON 包**：所有 JSON marshal/unmarshal 必须使用 `common/json.go` 中的包装函数，禁止直接使用 `encoding/json`
2. **数据库兼容**：SQLite / MySQL / PostgreSQL 三库兼容，使用 GORM 抽象，不直接拼接 SQL
3. **group 列引用**：使用 `model/log.go` 中已定义的 `logGroupCol` 变量，跨数据库兼容
4. **权限解析框架**：`pkg/permission/` 使用 `Result.Data map[string]interface{}`，不写死具体 key，支持后续扩展

## 2. 参考文档

| 文档 | 路径 | 用途 |
|------|------|------|
| 需求文档 | `docs/auth/proposal.md` | 功能需求和背景 |
| 概要设计 | `docs/auth/high-level-design.md` | 架构概览和模块划分 |
| 详细设计 | `docs/auth/detailed-design.md` | 完整实现细节（含代码示例） |
| 任务清单 | `docs/auth/tasks/*.md` | 各模块最小可执行任务 |
| 实施进度 | `docs/auth/tasks/progress.md` | 整体进度跟踪 |

## 3. 架构概览

```
┌──────────────────────────────────────────────────────────────────┐
│  pkg/permission/         通用权限解析框架（新增）                    │
│   Result {HasAuth, Data map}                                     │
│   ParseFunc: func(value) (map, ok)                              │
│   Resolver: primaryKey + fallbackKey + parseFunc                 │
│   LogsAuth = NewResolver("new-api:logs:auth","new-api:auth",...) │
└───────────┬──────────────────────────────────────────────────────┘
            │ permission.LogsAuth.Resolve(c) → Result{Data: {...}}
            │
┌───────────▼──────────────────────────────────────────────────────┐
│  middleware/                                                      │
│   dcloud.go — DCloudAuth/Required: 补充 vdc_code + other_role_map │
│   auth.go — AdminAuth: 泛化绕过 role 检查（new-api:*:auth）       │
└───────────┬──────────────────────────────────────────────────────┘
            │
┌───────────▼──────────────────────────────────────────────────────┐
│  controller/log.go                                               │
│   GetAllLogs / GetLogsStat / DeleteHistoryLogs                  │
│   → auth.Data["scope"] / ["orgs"] / ["dept_id"]                  │
│   → model.GroupFilter {Mode, Orgs}                               │
└───────────┬──────────────────────────────────────────────────────┘
            │
┌───────────▼──────────────────────────────────────────────────────┐
│  model/log.go — 扩展 GroupFilter 参数                              │
│   GetAllLogs / GetUserLogs / SumUsedQuota / DeleteOldLog         │
└──────────────────────────────────────────────────────────────────┘
```

## 4. 实施顺序（必须按此顺序执行）

### Phase 1：通用权限解析框架
**任务文件**: `docs/auth/tasks/pkg-permission.md`
**产出**:
- `pkg/permission/permission.go`
- `pkg/permission/scope.go`
- `pkg/permission/logs.go`
- `pkg/permission/permission_test.go`
- `pkg/permission/logs_test.go`

### Phase 2：认证中间件改造
**任务文件**: `docs/auth/tasks/middleware-auth.md`
**产出**:
- `middleware/dcloud.go` 修改（3 处 context 补充 + ResolveLogAuth 转发）
- `middleware/auth.go` 修改（AdminAuth 泛化绕过）

### Phase 3：Model 层扩展
**任务文件**: `docs/auth/tasks/model-log.md`
**产出**:
- `model/log.go` 修改（GroupFilter 结构体 + 4 个方法扩展）

### Phase 4：日志控制器改造
**任务文件**: `docs/auth/tasks/controller-log.md`
**产出**:
- `controller/log.go` 修改（3 个接口的 DCloud 分支 + 8 个辅助函数）

### Phase 5：集成测试
端到端流程验证

## 5. Phase 1 详细实现指令

### 5.1 pkg/permission/permission.go

**文件路径**: `/home/ubuntu/ragbridge/dev/code/frontend/new-api/pkg/permission/permission.go`

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

// Resolver 权限解析器，用于从 other_role_map 解析指定资源的权限。
type Resolver struct {
    primaryKey  string
    fallbackKey string
    parseFunc   ParseFunc
}

// NewResolver 创建权限解析器。
func NewResolver(primaryKey, fallbackKey string, parseFunc ParseFunc) *Resolver

// Resolve 从 gin context 中解析权限。
func (r *Resolver) Resolve(c *gin.Context) Result

// getDeptId 从 context 获取 dept_id（vdc_code）
func getDeptId(c *gin.Context) string
```

**关键实现要点**:
- `Resolve` 方法从 `c.Get("other_role_map")` 获取 map，优先查 `primaryKey`，失败后查 `fallbackKey`
- 格式错误（`parseFunc` 返回 `ok=false`）视为该 key 不存在，继续兜底
- 解析成功后自动从 context 注入 `dept_id` 到 Data 中

### 5.2 pkg/permission/scope.go

**文件路径**: `/home/ubuntu/ragbridge/dev/code/frontend/new-api/pkg/permission/scope.go`

实现 `parseScopeValue(value string) (scope string, orgs []string, ok bool)`

**解析规则**:

| Value 格式 | scope | orgs | ok |
|-----------|-------|------|----|
| `"all"` | `"all"` | 空 | true |
| `"spec_down:X,Y"` | `"spec_down"` | `["X", "Y"]` | true |
| `"spec:X,Y"` | `"spec"` | `["X", "Y"]` | true |
| `"local_down"` | `"local_down"` | 空 | true |
| `"local"` | `"local"` | 空 | true |
| `"me"` | `"me"` | 空 | true |

**格式错误（返回 ok=false）**:

| Value 输入 | 原因 |
|-----------|------|
| `""` | 空字符串 |
| `"ALL"` | 大小写不匹配 |
| `"spec_down:"` | 冒号后无组织编码 |
| `"spec_down: "` | 冒号后为空白字符 |
| `"spec_down:020,"` | 尾部逗号导致空元素 |
| `" spec:020"` | 前导空格 |
| `"unknown_scope"` | 无法识别的 scope 名称 |

### 5.3 pkg/permission/logs.go

**文件路径**: `/home/ubuntu/ragbridge/dev/code/frontend/new-api/pkg/permission/logs.go`

```go
package permission

// 日志权限 scope 常量
const (
    LogScopeAll       = "all"
    LogScopeSpecDown  = "spec_down"
    LogScopeSpec      = "spec"
    LogScopeLocalDown = "local_down"
    LogScopeLocal     = "local"
    LogScopeMe        = "me"
)

// parseLogAuthValue 解析日志权限 value
func parseLogAuthValue(value string) (map[string]interface{}, bool)

// 预定义实例
var LogsAuth = NewResolver("new-api:logs:auth", "new-api:auth", parseLogAuthValue)
```

**Data map keys 约定**:

| Data key | 类型 | 说明 |
|---------|------|------|
| `"scope"` | `string` | 权限范围 |
| `"orgs"` | `[]string` | 组织编码列表（spec_down/spec 有值） |
| `"dept_id"` | `string` | 当前用户 dept_id（由 Resolve 自动注入） |

### 5.4 测试要求

- 使用 Go 原生 `testing` 包
- 使用 `gin.CreateTestContext(httptest.NewRecorder())` 创建测试 context
- TC-P-01 ~ TC-P-19 必须全部覆盖
- 运行验证: `go test ./pkg/permission/ -v`

## 6. Phase 2 详细实现指令

### 6.1 middleware/dcloud.go 修改

**在以下 3 处添加 context 设置**:

```go
c.Set("vdc_code", claims.VdcCode)
c.Set("other_role_map", claims.OtherRoleMap)
```

1. `DCloudAuth()` 函数 — 第 318 行附近（`c.Set("use_access_token", false)` 之后）
2. `DCloudAuthRequired()` 函数 — 第 400 行附近（`c.Set("use_access_token", false)` 之后）
3. `authHelper()` 函数 — 第 91-96 行附近（`dcloudAuth = true` 之后）

**ResolveLogAuth 转发**:
将现有的 `ResolveLogAuth()` 函数改为转发到 `permission.LogsAuth.Resolve(c)`，保持原有函数签名不变。

### 6.2 middleware/auth.go 修改

**修改位置**: `authHelper()` 函数，`role.(int) < minRole` 检查之前

**添加泛化绕过逻辑**:

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

**关键点**:
- 前缀匹配 `new-api:` + 后缀匹配 `:auth`，泛化支持未来扩展的权限类型
- 仅在 `dcloudAuth == true` 时生效

## 7. Phase 3 详细实现指令

### 7.1 model/log.go 新增结构体

```go
// GroupFilter 组织过滤条件
type GroupFilter struct {
    Mode string   // "prefix" | "exact" | "in"
    Orgs []string // 组织编码列表
}
```

### 7.2 辅助函数

```go
// applyGroupFilterWithTable 将 GroupFilter 应用到 GORM tx。
// tablePrefix: 表名前缀，如 "logs."，为空时不加前缀。
func applyGroupFilterWithTable(tx *gorm.DB, groupFilter *GroupFilter, tablePrefix string) *gorm.DB

// applyGroupFilter 便捷封装，默认使用 "logs." 表名前缀。
func applyGroupFilter(tx *gorm.DB, groupFilter *GroupFilter) *gorm.DB
```

**Mode 语义**:

| Mode | SQL 条件 |
|------|---------|
| `"prefix"` | `logs."group" LIKE 'org1%' OR logs."group" LIKE 'org2%'` |
| `"exact"` | `logs."group" = 'org1'` 或 `logs."group" IN ('org1','org2')` |
| `"in"` | `logs."group" IN ('org1','org2')` |

**跨数据库兼容**: 使用 `logGroupCol` 变量引用 group 列

### 7.3 方法签名扩展

```go
func GetAllLogs(..., groupFilter *GroupFilter) (logs []*Log, total int64, err error)
func GetUserLogs(..., groupFilter *GroupFilter) (logs []*Log, total int64, err error)
func SumUsedQuota(..., groupFilter *GroupFilter) (stat Stat, err error)
func DeleteOldLog(ctx context.Context, targetTimestamp int64, limit int, groupFilter *GroupFilter) (int64, error)
```

**GroupFilter 为 nil 时行为**: 不附加任何条件，与原逻辑完全一致（向后兼容）

## 8. Phase 4 详细实现指令

### 8.1 辅助函数（8 个）

```go
func getLogScope(data map[string]interface{}) string      // 安全读取 Data["scope"]
func getLogOrgs(data map[string]interface{}) []string     // 安全读取 Data["orgs"]
func getLogDeptId(data map[string]interface{}) string      // 安全读取 Data["dept_id"]
func handleGetAllLogs(c *gin.Context, groupFilter *model.GroupFilter)
func handleGetUserLogs(c *gin.Context)
func handleGetLogsStat(c *gin.Context, username string, groupFilter *model.GroupFilter)
func returnEmptyLogData(c *gin.Context)
func returnEmptyLogStat(c *gin.Context)
```

### 8.2 各接口 DCloud 分支

**所有分支必须先判断**: `if common.DCloudIntegrationEnabled`

**Scope 映射**:

| scope | GetAllLogs | GetLogsStat | DeleteHistoryLogs |
|-------|-----------|-------------|------------------|
| `LogScopeAll` | `handleGetAllLogs(c, nil)` | `handleGetLogsStat(c, "", nil)` | `DeleteOldLog(..., nil)` |
| `LogScopeSpecDown` | GroupFilter{prefix, orgs} | GroupFilter{prefix, orgs} | GroupFilter{prefix, orgs} |
| `LogScopeSpec` | GroupFilter{in, orgs} | GroupFilter{in, orgs} | GroupFilter{in, orgs} |
| `LogScopeLocalDown` | GroupFilter{prefix, [dept_id]} | GroupFilter{prefix, [dept_id]} | GroupFilter{prefix, [dept_id]} |
| `LogScopeLocal` | GroupFilter{exact, [dept_id]} | GroupFilter{exact, [dept_id]} | GroupFilter{exact, [dept_id]} |
| `LogScopeMe` | `handleGetUserLogs(c)` | `handleGetLogsStat(c, c.GetString("username"), nil)` | 403 |
| `default` | `returnEmptyLogData(c)` | `returnEmptyLogStat(c)` | 403 |

**安全要点**:
- `me` scope 的 `GetLogsStat` 必须使用 `c.GetString("username")`，不能用 query 参数
- `me` scope 的 `DeleteHistoryLogs` 必须返回 403

## 9. 测试执行与验证

### 9.1 测试命令

```bash
# Phase 1
go test ./pkg/permission/ -v

# Phase 2 (需要先完成 Phase 1)
go test ./middleware/ -run TestAdminAuth -v

# Phase 3 (需要先完成 Phase 1)
go test ./model/ -run TestGroupFilter -v

# Phase 4 (需要先完成 Phase 1, 2, 3)
go test ./controller/ -run TestLog -v

# 全量测试
go test ./... -v
go vet ./...
golangci-lint run
```

### 9.2 测试覆盖要求

**pkg/permission**: TC-P-01 ~ TC-P-19（19 个测试用例）
**middleware**: TC-A-01 ~ TC-A-09（9 个测试用例）
**controller/log**: TC-C-01 ~ TC-C-17（17 个测试用例）
**model/log**: TC-M-01 ~ TC-M-08（8 个测试用例）

**总计**: 53 个测试用例

## 10. 代码风格要求

1. **注释**: 不写无用注释，只在 WHY 不明显处添加说明
2. **错误处理**: 使用 `common.ApiError(c, err)` 返回错误，不直接 `panic`
3. **JSON 处理**: 必须使用 `common/json.go` 中的包装函数
4. **命名**: 遵循 Go 惯例，使用驼峰命名，导出函数大写开头

## 11. 文件变更总览

| 文件 | 操作 |
|------|------|
| `pkg/permission/permission.go` | 新增 |
| `pkg/permission/scope.go` | 新增 |
| `pkg/permission/logs.go` | 新增 |
| `pkg/permission/permission_test.go` | 新增 |
| `pkg/permission/logs_test.go` | 新增 |
| `middleware/dcloud.go` | 修改 |
| `middleware/auth.go` | 修改 |
| `model/log.go` | 修改 |
| `controller/log.go` | 修改 |

## 12. 常见问题

**Q: parseScopeValue 解析失败的原因可能有哪些？**
A: 空字符串、大小写不匹配（应为小写）、组织列表为空（`spec_down:` 后面没有内容）、前导/尾随空格、多 org 时尾部逗号（`spec:020,`）、无法识别的 scope 名称。

**Q: GroupFilter 为 nil 和 GroupFilter.Orgs 为空切片有什么区别？**
A: `applyGroupFilter` 会对 nil 和空切片都直接返回 tx，不过滤任何数据，行为一致。

**Q: 为什么 AdminAuth 绕过使用 `new-api:*:auth` 前缀匹配而不是硬编码列表？**
A: 为了扩展性。后续新增 `new-api:channel:auth` 等权限类型时，AdminAuth 自动支持，无需修改中间件代码。

**Q: 三个数据库的 group 列引用方式是什么？**
A: 使用 `logGroupCol` 变量（`model/log.go` 已定义）：PostgreSQL 为 `"group"`，MySQL/SQLite 为 `` `group` ``。

## 13. 确认事项

在开始编码之前，请确认以下事项：

1. **测试工具**: Go 原生 `testing` 包 + `httptest` ✅ 已确认
2. **代码检测**: `go vet` + `golangci-lint`（Go 项目标准）
3. **JSON 处理**: 必须通过 `common/json.go` 包装函数
4. **数据库兼容**: 三个数据库（SQLite/MySQL/PostgreSQL）均需工作正常
5. **现有代码**: 不破坏现有功能和测试用例

---

**开始编码前，请先阅读以下文件**:
1. `docs/auth/tasks/progress.md` — 了解整体进度
2. `docs/auth/tasks/pkg-permission.md` — Phase 1 详细任务
3. `docs/auth/detailed-design.md` — 完整实现细节
4. `middleware/dcloud.go`（现有代码，理解 DCloud JWT 认证流程）
5. `model/log.go`（现有代码，理解现有查询方法签名）