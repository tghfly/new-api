# 调用日志分权分域 — 概要设计

## 1. 概述

### 1.1 背景

现有日志查询接口 `GetAllLogs` 依赖内置角色等级（`RoleAdminUser` / `RoleRootUser`）做硬编码过滤，无法接入算力平台（DCloud）的细粒度权限体系。本设计实现基于 DCloud `other_role` 的日志分权分域能力。

### 1.2 目标

- 支持按组织编码（`group`）过滤日志数据范围
- 支持按用户 ID（`user_id`）过滤个人日志
- 优先使用日志专用权限 key，兜底使用通用权限 key
- 两个 key 均不存在时回退到原有内置角色逻辑
- DCloud 用户即使 role < 10，只要持有有效日志权限即可访问

### 1.3 涉及接口

| 接口 | 路由 | 说明 |
|------|------|------|
| `GetAllLogs` | `GET /api/log/` | 日志列表查询 |
| `GetLogsStat` | `GET /api/log/stat` | 日志用量统计 |
| `DeleteHistoryLogs` | `DELETE /api/log/` | 删除历史日志 |

## 2. 模块设计

本功能划分为三个核心模块：**权限解析模块**、**认证中间件模块**、**日志控制器模块**。

```
┌─────────────────────────────────────────────────────────────┐
│                      请求入口 /api/log/                       │
└────────────────────────┬────────────────────────────────────┘
                         │
          ┌──────────────┴──────────────┐
          │      AdminAuth 中间件        │ ← 修改：增加日志权限 key 绕过 role 检查
          └──────────────┬──────────────┘
                         │
          ┌──────────────┴──────────────┐
          │    resolveLogPermission()    │ ← 新增：middleware/dcloud.go
          │    解析 other_role_map       │
          │    返回 hasAuth/scope/orgs   │
          └──────────────┬──────────────┘
                         │
          ┌──────────────┴──────────────┐
          │    Controller.GetAllLogs     │ ← 修改：增加 DCloud 权限分支
          │    Controller.GetLogsStat   │ ← 修改：增加 DCloud 权限分支
          │    Controller.DeleteHistory │ ← 修改：增加 DCloud 权限分支
          └──────────────┬──────────────┘
                         │
          ┌──────────────┴──────────────┐
          │    Model 层日志查询         │ ← 扩展：支持 group 前缀/精确匹配过滤
          └────────────────────────────┘
```

## 3. 模块详设

### 3.1 权限解析模块（middleware/dcloud.go）

**职责：** 解析 `other_role_map`，判断当前用户是否持有日志权限，返回权限范围信息。

**新增函数：**

```go
// LogAuthResult 权限解析结果
type LogAuthResult struct {
    HasAuth bool     // 是否持有有效日志权限
    Scope   string   // 权限类型：all, spec_down, spec, local_down, local, me
    Orgs    []string // 组织编码列表（用于 spec_down / spec）
    DeptId  string   // 当前用户 dept_id（用于 local_down / local）
}

// ResolveLogAuth 从 gin context 中获取 other_role_map，解析日志权限
// 优先级：new-api:logs:auth > new-api:auth
// 若均不存在，返回 HasAuth=false
func ResolveLogAuth(c *gin.Context) LogAuthResult

// GetLogScopeDeptId 从 context 中获取 dept_id（vdc_code）
func GetLogScopeDeptId(c *gin.Context) string
```

**解析流程：**

```
ResolveLogAuth(c)
  ├─ 从 c.Get("other_role_map") 获取 otherRoleMap (map[string]string)
  ├─ 优先查 otherRoleMap["new-api:logs:auth"]
  │    ├─ 存在 → 解析 value → 返回 LogAuthResult{HasAuth: true, ...}
  │    └─ 不存在或为空
  │         ├─ 查 otherRoleMap["new-api:auth"]
  │         │    ├─ 存在 → 解析 value → 返回 LogAuthResult{HasAuth: true, ...}
  │         │    └─ 不存在或为空 → 返回 LogAuthResult{HasAuth: false}
  │         └─ (dept_id 从 c.Get("vdc_code") 获取)
```

**Value 解析规则：**

| Value 格式 | Scope | Orgs |
|-----------|-------|------|
| `"all"` | `"all"` | 空 |
| `"spec_down:020"` | `"spec_down"` | `["020"]` |
| `"spec_down:020,021"` | `"spec_down"` | `["020", "021"]` |
| `"spec:020"` | `"spec"` | `["020"]` |
| `"spec:020,021"` | `"spec"` | `["020", "021"]` |
| `"local_down"` | `"local_down"` | 空（dept_id 从 VdcCode 获取） |
| `"local"` | `"local"` | 空（dept_id 从 VdcCode 获取） |
| `"me"` | `"me"` | 空 |

### 3.2 认证中间件模块（middleware/auth.go）

**职责：** 在 DCloud 认证流程中补充 `vdc_code` 和 `other_role_map` 到 gin context；修改 `AdminAuth` 支持 DCloud 日志权限绕过 role 检查。

#### 3.2.1 Context 补充

在 `DCloudAuth()`、`DCloudAuthRequired()`、`authHelper()` 的 DCloud JWT 认证分支中，补充设置：

```go
c.Set("vdc_code", claims.VdcCode)
c.Set("other_role_map", claims.OtherRoleMap)
```

#### 3.2.2 AdminAuth 修改

**修改位置：** `middleware/auth.go` 的 `AdminAuth()`

**修改逻辑：**

```
AdminAuth()
  └─ authHelper(c, RoleAdminUser)
       ├─ DCloudIntegrationEnabled == false
       │    └─ 原逻辑：role >= 10 才放行
       └─ DCloudIntegrationEnabled == true
            ├─ 已通过 authHelper 认证
            ├─ 从 context 获取 other_role_map
            ├─ 检查是否存在 "new-api:logs:auth" 或 "new-api:auth" key
            │    ├─ 存在 → 跳过 role >= 10 检查，直接放行（进入 Controller）
            │    └─ 不存在 → 继续原 role >= 10 检查
```

> 实现方式：在 `authHelper` 末尾写 context 之前，或在 `AdminAuth` 包装层中，在 `role < minRole` 检查之前额外判断 DCloud 日志权限 key 是否存在。若存在则跳过该错误返回，直接调用 `c.Next()`。

### 3.3 日志控制器模块（controller/log.go）

#### 3.3.1 GetAllLogs

**前置判断：** 在 `DCloudIntegrationEnabled == true` 时，调用 `ResolveLogAuth(c)`：

```go
if common.DCloudIntegrationEnabled {
    auth := middleware.ResolveLogAuth(c)
    if auth.HasAuth {
        // 根据 auth.Scope 分支处理
        switch auth.Scope {
        case "all":
            // 调用 model.GetAllLogs() 不加 group 过滤
        case "spec_down":
            // 调用 model.GetAllLogs() + group LIKE 'org1%' OR group LIKE 'org2%'
        case "spec":
            // 调用 model.GetAllLogs() + group IN ('org1', 'org2')
        case "local_down":
            // 调用 model.GetAllLogs() + group LIKE '{dept_id}%'
        case "local":
            // 调用 model.GetAllLogs() + group = '{dept_id}'
        case "me":
            // 调用 model.GetUserLogs(userId) 仅当前用户
        }
        return
    }
    // 两个 key 均不存在 → 继续走原有 RoleAdminUser / RoleRootUser 逻辑
}
```

#### 3.3.2 GetLogsStat

**前置判断：** 同 `GetAllLogs`，但统计接口返回 `quota`、`rpm`、`tpm` 汇总值，过滤条件与 `GetAllLogs` 一致。

**特殊处理：** `me` scope 时，统计结果应仅包含当前用户的数据。

#### 3.3.3 DeleteHistoryLogs

**前置判断：** 同 `GetAllLogs`。

**关键约束：** 删除历史日志操作仅对 `all` / `spec_down` / `spec` / `local_down` / `local` 生效（组织级别），对 `me` 不允许删除他人数据（`me` 用户只能看自己的日志，不能删）。

**前置补充逻辑：**

```go
if auth.HasAuth && auth.Scope == "me" {
    // me 权限不允许删除历史日志
    c.JSON(403, gin.H{"success": false, "message": "无删除权限"})
    return
}
```

### 3.4 Model 层扩展（model/log.go）

#### 3.4.1 扩展现有方法签名

`GetAllLogs` 和 `GetUserLogs` 需要增加可选的 group 过滤参数：

```go
// 扩展后的签名（保持向后兼容）
func GetAllLogs(logType int, startTimestamp, endTimestamp int64, modelName, username,
    tokenName string, startIdx, pageSize int, channel int,
    group string, requestId string,
    groupFilter *GroupFilter, // ← 新增：可选的组织过滤条件
) ([]Log, int64, error)

// GroupFilter 组织过滤条件
type GroupFilter struct {
    Mode  string   // "prefix" | "exact" | "in"
    Orgs  []string // 组织编码列表
}
```

**实现说明：**
- `Mode = "prefix"` → `logs.group LIKE 'org1%' OR logs.group LIKE 'org2%'`
- `Mode = "exact"` → `logs.group IN ('org1', 'org2')`
- `group` 列引用使用现有的 `logGroupCol`（跨数据库兼容）
- 当 `GroupFilter` 为 `nil` 时，不增加 group 过滤条件

#### 3.4.2 GetUserLogs 扩展

`GetUserLogs` 增加 `GroupFilter` 参数，以支持 `me` 之外的组织级别过滤（如 `local_down` 管理员也需要查询自己组织的所有用户日志）。

## 4. 数据库兼容

所有 SQL 拼接使用 GORM ORM 方法，不直接拼接 SQL。

`group` 列为保留字/关键字：
- PostgreSQL：`"group"`
- MySQL/SQLite：`` `group` ``

使用 `model/log.go` 中已定义的 `logGroupCol` 变量引用该列。

## 5. 中间件执行顺序

```
请求 → DCloudAuth() → AdminAuth() → Controller
```

- `DCloudAuth()`：解析 JWT，写入 session 和 context（`vdc_code`、`other_role_map`）
- `AdminAuth()`：认证 + 权限检查（修改后支持日志权限 key 绕过 role >= 10）
- `Controller`：调用 `ResolveLogAuth()` 进行日志分权分域判定

## 6. 错误处理

| 场景 | 返回 |
|------|------|
| 无日志权限（两个 key 均不存在 + 非 Admin/Root） | 回退到原有逻辑 |
| `me` 权限调用 DeleteHistoryLogs | 403 无权限 |
| 其他异常（db error 等） | 按现有错误处理，返回 500 |

## 7. 模块依赖关系

```
middleware/auth.go (AdminAuth 修改)
    ↑ 依赖
middleware/dcloud.go (新增 ResolveLogAuth, GetLogScopeDeptId)
    ↑ context 提供
DCloudJWTClaims (OtherRoleMap 解析，己有)
    ↑ 输入
JWT Token (other_role JSON)

controller/log.go (GetAllLogs, GetLogsStat, DeleteHistoryLogs 修改)
    ↑ 调用
middleware.ResolveLogAuth(c)

model/log.go (GetAllLogs, GetUserLogs 扩展 groupFilter)
    ↑ 被调用
controller/log.go
```

## 8. 文件变更清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `middleware/dcloud.go` | 修改 | 新增 `ResolveLogAuth()`、`LogAuthResult` 结构体 |
| `middleware/auth.go` | 修改 | `AdminAuth` 增加日志权限 key 绕过 role 检查；`DCloudAuth`/`DCloudAuthRequired`/`authHelper` 补充 `vdc_code`、`other_role_map` 到 context |
| `controller/log.go` | 修改 | `GetAllLogs`、`GetLogsStat`、`DeleteHistoryLogs` 增加 DCloud 权限分支 |
| `model/log.go` | 修改 | `GetAllLogs`、`GetUserLogs` 扩展 `GroupFilter` 参数；新增 `GroupFilter` 结构体 |
| `docs/auth/high-level-design.md` | 新增 | 本文档 |

## 9. 实施顺序

**Phase 1：权限解析基础设施**
1. `middleware/dcloud.go` 新增 `ResolveLogAuth()`、`LogAuthResult`、`GetLogScopeDeptId()`
2. `middleware/auth.go` 补充 context 设置；修改 `AdminAuth` 支持日志权限 key 绕过 role 检查

**Phase 2：Controller 接入**
3. `controller/log.go` 改造 `GetAllLogs` 增加 DCloud 权限分支
4. `model/log.go` 扩展 `GetAllLogs` 支持 `GroupFilter`

**Phase 3：其他接口和清理**
5. `controller/log.go` 改造 `GetLogsStat` 和 `DeleteHistoryLogs`
6. Model 层同步扩展 `GetUserLogs` 支持 `GroupFilter`
