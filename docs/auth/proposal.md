# 调用日志分权分域 — 需求文档

## 1. 背景

当前 new-api 的调用日志查询逻辑仅依赖内置角色等级（RoleAdminUser / RoleRootUser）做硬编码过滤，缺乏与算力平台（DCloud）权限体系的对接能力。算力平台通过 JWT 中的 `other_role` 传递细粒度权限标识，需要对日志查询接口进行改造，使其支持按组织范围（分域）和角色（分权）进行数据隔离。

## 2. 目标

在现有 `GetAllLogs` 接口中，根据当前用户的 DCloud 权限信息，动态决定日志数据的可见范围，实现以下能力：

| 权限类型（Value） | 可见范围 |
|------|---------|
| `all` | 全部日志 |
| `spec_down:org1,org2` | 指定组织及其下级（前缀匹配） |
| `spec:org1,org2` | 指定组织（精确匹配） |
| `local_down` | 当前用户所属组织及其下级（前缀匹配） |
| `local` | 当前用户所属组织 |
| `me` | 仅当前用户自己的日志 |

## 3. 权限数据来源

### 3.1 JWT Claims 结构

算力平台 JWT（`dcloud_token`）解析后的 `DCloudJWTClaims` 包含以下关键字段：

```go
type DCloudJWTClaims struct {
    TenantId     string            `json:"tenant_id"`      // 租户 ID
    RoleName     string            `json:"role_name"`      // 角色名（逗号分隔）
    VdcCode      string            `json:"vdc_code"`       // 当前用户组织编码（即 dept_id）
    RoleId       string            `json:"role_id"`        // 角色 ID（如 "fbadminrole"）
    UserId       string            `json:"user_id"`        // 外部用户 ID
    UserName     string            `json:"user_name"`      // 用户名
    OtherRole    interface{}       `json:"other_role"`     // 扩展权限 JSON
    OtherRoleMap map[string]string `json:"-"`              // 解析后的权限 map
}
```

### 3.2 OtherRoleMap 格式

`other_role` 是一个 JSON 对象，解析为 `map[string]string`。日志权限使用以下 key（优先级从高到低）：

| Key | 说明 | 优先级 |
|-----|------|--------|
| `new-api:logs:auth` | 日志专用权限 | 高 |
| `new-api:auth` | 通用权限（日志权限的兜底） | 低 |

**示例：**

```json
{
    "aiprovider": "admin",
    "newapi": "10",
    "new-api:logs:auth": "spec_down:020",
    "new-api:auth": "local_down",
    "filebrowser": "fbprojrole"
}
```

**Value 格式（两个 key 共用）：**

| Value 格式 | 含义 | 示例 |
|-----------|------|------|
| `all` | 全部可见 | `"all"` |
| `spec_down:{orgs}` | 指定组织及下级（前缀匹配），多个组织用逗号分隔 | `"spec_down:020"`, `"spec_down:020,021"` |
| `spec:{orgs}` | 指定组织（精确匹配），多个组织用逗号分隔 | `"spec:020"`, `"spec:020,021"` |
| `local_down` | 当前用户所属组织及下级（前缀匹配） | `"local_down"` |
| `local` | 当前用户所属组织 | `"local"` |
| `me` | 仅当前用户自己的日志 | `"me"` |

**解析逻辑：**
1. 优先读取 `"new-api:logs:auth"` 的 value
2. 若该 key 不存在或 value 为空，降级读取 `"new-api:auth"` 的 value
3. 若两个 key 均不存在 → 无 DCloud 日志权限，回退到原有逻辑
4. 按第一个冒号 `:` 拆分 value，左侧为 scope，右侧为参数（可选）
5. scope 为 `spec_down` / `spec` 时，将参数部分按逗号 `,` 拆分为组织列表
6. scope 为 `local_down` / `local` 时，从 JWT 的 `VdcCode` 获取当前用户 dept_id
7. scope 为 `all` / `me` 时，无需额外参数

> 注：当前 `OtherRoleMap` 中已存在 `"newapi"` key 用于角色等级覆盖，本功能使用的 `"new-api:logs:auth"` 和 `"new-api:auth"` key 与之独立共存。

### 3.3 日志模型现有字段

```go
type Log struct {
    UserId  int    `json:"user_id"`  // 用户 ID（用于 me 过滤）
    Group   string `json:"group"`    // 组织/分组（用于组织域过滤，gorm:"index"）
    // ... 其他字段
}
```

`Group` 字段存储组织编码，用于 `spec_down` / `spec` / `local_down` / `local` 时的过滤条件。`UserId` 字段用于 `me` 时的过滤。

### 3.4 当前用户 dept_id

当前用户的组织编码从 `DCloudJWTClaims.VdcCode` 获取，同步到 `User.DeptId`，但当前**未**写入 gin context，需要在认证阶段补充。

## 4. 权限判定逻辑

整体流程：**按优先级依次检查，命中最优先的则使用其权限，全不命中则回退到原有角色逻辑。**

```
┌──────────────────────────────────┐
│       开始查询日志                 │
└──────────┬───────────────────────┘
           ▼
┌──────────────────────────────────┐
│  DCloudIntegrationEnabled?       │
└──────────┬───────────────────────┘
     否      │               │ 是
      ▼      │               ▼
 ┌──────────┐│  ┌──────────────────────────────────┐
 │ 原有逻辑  ││  │  "new-api:logs:auth" key 存在?   │───是──→ 解析 value
 │(角色判定) ││  └──────────┬───────────────────────┘        │
 └──────────┘│             │ 否                              │
             │             ▼                                  │
             │  ┌──────────────────────────────────┐          │
             │  │  "new-api:auth" key 存在?         │───是──→ 解析 value
             │  └──────────┬───────────────────────┘        │
             │             │ 否                              │
             │             ▼                                  │
             │  ┌──────────────────────────────────┐          │
             │  │  回退到原有逻辑                    │          │
             │  │  (RoleAdminUser / RoleRootUser)   │          │
             │  └──────────────────────────────────┘          │
             │                                                │
             └────────── 所有路径最终统一 ────────────────────┘
                                 │
                   ┌───────┬─────┼──────┬──────┬──────┐
                   ▼       ▼     ▼      ▼      ▼      ▼
                  all   spec_  spec  local_ local  me
                        down          down
                   │       │     │      │      │      │
                   ▼       ▼     ▼      ▼      ▼      ▼
                 不限    group  group  group  group  user_id
                 制    LIKE   = 指定  LIKE  = 当前  = 当前
                       org%   组织   dept_id% dept_id 用户ID
```

### 4.1 权限解析优先级

按以下顺序依次判定，命中最优先的则采用其权限：

| 优先级 | 判定项 | 说明 |
|--------|--------|------|
| 1（最高） | `new-api:logs:auth` value | 日志专用权限，最精确 |
| 2 | `new-api:auth` value | 通用权限，日志模块将其作为兜底 |
| 3（回退） | 原有 RoleAdminUser / RoleRootUser 逻辑 | 不命中任何 DCloud 权限时回退 |

**关键要点：**
- 两个 key 的 value 格式和解析逻辑完全一致
- 若 `new-api:logs:auth` 存在，直接使用其 scope，不再检查 `new-api:auth`
- 若两个 key 均不存在，回退到原有内置角色判定逻辑

### 4.2 匹配规则

| 权限 | Log 过滤条件 | 匹配方式 |
|------|-------------|---------|
| `spec_down:org1,org2` | `logs.group LIKE 'org1%' OR logs.group LIKE 'org2%'` | 前缀匹配 |
| `spec:org1,org2` | `logs.group = 'org1' OR logs.group = 'org2'` | 精确匹配 |
| `local_down` | `logs.group LIKE '{dept_id}%'` | 前缀匹配 |
| `local` | `logs.group = '{dept_id}'` | 精确匹配 |
| `me` | `logs.user_id = {current_user_id}` | 精确匹配 |

### 4.3 无 DCloud 权限时的回退行为

若 DCloud 已启用，但两个 key 均不存在：
- `"new-api:logs:auth"` key 不存在
- `"new-api:auth"` key 不存在

则无条件**回退到原有 `RoleAdminUser` / `RoleRootUser` 判定逻辑**，保持行为一致。

| 场景 | 走新分支 | 走旧分支 |
|------|---------|---------|
| DCloud 未启用 | — | 原有逻辑 |
| DCloud 已启用 + `new-api:logs:auth` 存在 | ✅（第1优先） | — |
| DCloud 已启用 + `new-api:auth` 存在（无 logs:auth） | ✅（第2优先，降级兜底） | — |
| DCloud 已启用 + 两个 key 均不存在 | — | ✅ 回退 |

## 5. 影响范围

### 5.1 后端改动

#### 5.1.1 认证中间件（`middleware/dcloud.go` / `middleware/auth.go`）

在 DCloud 认证流程中，将以下信息写入 gin context：

| Context Key | 来源 | 用途 |
|------------|------|------|
| `vdc_code` / `dept_id` | `claims.VdcCode` | local_down/local 过滤 |
| `other_role_map` | `claims.OtherRoleMap` | 日志权限解析 |

**影响位置：**
- `SyncDCloudUser()` — 无需改动（已同步 User 表）
- `DCloudAuth()` / `DCloudAuthRequired()` — 补充设置 context
- `authHelper()` — 补充 DCloud JWT 认证分支的 context 设置

#### 5.1.2 Controller 层（`controller/log.go`）

修改 `GetAllLogs` 函数：
- 在现有 RoleAdminUser / RoleRootUser 分支判断之前，插入 DCloud 日志权限判断
- 新增辅助函数 `resolveLogPermission(c *gin.Context) (hasAuth bool, scope string, orgs []string)`
  - 内部先查 `"new-api:logs:auth"` key，不存在则降级查 `"new-api:auth"` key
  - 两个 key 均不存在时 `hasAuth = false`
- 根据解析结果选择对应的查询策略

**`GetAllLogs` 改动后流程：**

```
func GetAllLogs(c *gin.Context) {
    // ---- 新：DCloud 权限判定（按优先级）----
    if common.DCloudIntegrationEnabled {
        // 第1优先：检查 new-api:logs:auth
        // 第2优先：检查 new-api:auth
        if hasAuth, scope, orgs := resolveLogPermission(c); hasAuth {
            switch scope {
            case "all":
                // 不做限制，查询全部日志
            case "spec_down":
                // group LIKE org1% OR group LIKE org2%
            case "spec":
                // group IN ('org1', 'org2')
            case "local_down":
                // group LIKE dept_id%
            case "local":
                // group = dept_id
            case "me":
                // user_id = current_user_id
            }
            return
        }
        // 两个 key 均不命中 → 不 return，回退到原有逻辑
    }

    // ---- 旧：原有 RoleAdminUser / RoleRootUser 逻辑（兜底）----
    //（原有代码保持不变）
    role := c.GetInt("role")
    if role == common.RoleAdminUser {
        // Admin 用户：只查自己的日志
        ...
        return
    }
    // Root 用户：可以查看所有日志
    ...
}
```

> 设计要点：`resolveLogPermission()` 返回 `(hasAuth bool, scope string, orgs []string)`。内部先查 `"new-api:logs:auth"`，不存在则降级查 `"new-api:auth"`。两个 key 均不存在时 `hasAuth = false`，不拦截，继续走回退路径。

#### 5.1.3 Model 层（`model/log.go`）

新增或扩展日志查询方法，支持基于组织列表的过滤：

| 方法 | 说明 |
|------|------|
| `GetLogsByGroupPrefix(orgs []string, ...)` | 按组织前缀匹配查询（用于 spec_down / local_down） |
| `GetLogsByGroupExact(orgs []string, ...)` | 按组织精确匹配查询（用于 spec / local） |
| 或在 `GetAllLogs` 中动态拼接 WHERE 条件 | 最小改动方案 |

> 注意：`group` 列为保留字，需使用现有 `logGroupCol` 动态列名引用，保证跨数据库兼容。

#### 5.1.4 其他受影响的接口

| 接口 | 路由 | 当前限制 | 是否需要分权改造 |
|------|------|---------|----------------|
| `GetLogsStat` | `GET /api/log/stat` | 无 org 过滤 | **建议同步改造**，否则统计数据可能存在越权 |
| `GetLogByKey` | （通过 token_id 查） | 无权限校验 | 低优先级（需 token_id） |
| `DeleteHistoryLogs` | `DELETE /api/log/` | 无 org 过滤 | **建议同步改造**，防越权删除 |

### 5.2 前端改动

**无。** 前端仅展示后端返回的过滤后数据，无需新增 UI 组件。（但建议在日志列表页顶部增加一行"数据范围"提示文本，如"当前显示：指定组织及下级（020）"，提升用户体验，非必须。）

### 5.3 数据库改动

**Log 表无需新增字段。** 现有 `group` 和 `user_id` 字段即可满足过滤需求。

## 6. 数据流示例

### 6.1 spec_down 场景

```
请求: GET /api/log/

用户 Claims:
  VdcCode: "020"
  OtherRoleMap: { "new-api:logs:auth": "spec_down:020" }

判定:
  1. OtherRoleMap 中存在 "new-api:logs:auth" key → value = "spec_down:020"
  2. 按冒号拆分: scope = spec_down, orgs = ["020"]
  3. 过滤条件: logs.group LIKE '020%'
  4. 返回 group 以 "020" 开头的所有日志
```

### 6.2 local_down 场景

```
请求: GET /api/log/

用户 Claims:
  VdcCode: "030"
  OtherRoleMap: { "new-api:logs:auth": "local_down" }

判定:
  1. OtherRoleMap 中存在 "new-api:logs:auth" key → value = "local_down"
  2. scope = local_down，从 VdcCode 获取 dept_id = "030"
  3. 过滤条件: logs.group LIKE '030%'
  4. 返回 group 以 "030" 开头的所有日志
```

### 6.3 me 场景

```
请求: GET /api/log/

用户 Claims:
  VdcCode: "030"
  OtherRoleMap: { "new-api:logs:auth": "me" }

判定:
  1. OtherRoleMap 中存在 "new-api:logs:auth" key → value = "me"
  2. scope = me，从 session/context 获取当前用户 ID（user.Id = 42）
  3. 过滤条件: logs.user_id = 42
  4. 返回当前用户自己的日志
```

## 7. 路由与中间件依赖

```
GET /api/log/
  ├── middleware.AdminAuth()     ← 需要确认：是否与 DCloud 日志权限共存
  │    └── authHelper(c, RoleAdminUser)
  │         ├── DCloud JWT 认证（自动）
  │         └── role >= 10 检查
  └── controller.GetAllLogs
       └── 新增 DCloud 日志权限判断
```

> 注意事项：`AdminAuth()` 要求 role >= `RoleAdminUser`（10）。若 DCloud 用户的 role 低于 10（如普通用户 role=1 但拥有 `"new-api:logs:auth":"all"` 权限），请求会被中间件拦截，无法到达 `GetAllLogs`。**需要评估是否需要调整中间件策略**，例如：
> - 新增 `DCloudLogAuth()` 中间件替代 `AdminAuth()`，在 DCloud 集成启用时放行有日志权限的用户
> - 或修改 `AdminAuth()` 使其兼容 DCloud 权限体系

## 8. 实施建议

### 8.1 阶段一：基础能力（最小可行）

1. 在 DCloud 认证流程中补充 `vdc_code`、`other_role_map` 到 gin context
2. 在 `controller/log.go` 中实现 `resolveLogPermission()` 辅助函数
3. 改造 `GetAllLogs` 分支逻辑
4. 在 `GetAllLogs` 的 model 查询中动态拼接组织过滤条件

### 8.2 阶段二：完善与对齐

1. `GetLogsStat` 同步添加分权分域过滤
2. `DeleteHistoryLogs` 同步添加分权分域过滤
3. 评估并解决 `AdminAuth()` 中间件与 DCloud 权限体系的兼容性问题

### 8.3 阶段三：可观测与运维

1. 接入日志权限的调试日志（当前已有 `fmt.Printf` 风格的 DCloud debug 日志，需统一为 `logger` 包）
2. 考虑在用户详情页展示已生效的日志权限范围（前/后端配合）

## 9. 待决策事项

| # | 事项 | 建议 |
|---|------|------|
| 1 | `AdminAuth()` 中间件与 DCloud 日志权限的冲突处理 | 在 DCloud 集成启用时，新增更宽松的中间件或修改现有中间件逻辑 |
| 2 | `GetLogsStat` 是否同步改造 | 建议同步，否则统计数据存在越权风险 |
| 3 | `DeleteHistoryLogs` 是否同步改造 | 建议同步，防越权删除 |
| 4 | 当前用户无任何日志权限时的行为 | 建议返回空结果而非 403（避免前端报错） |
| 5 | 是否需要考虑 `tenant_id` 维度的隔离 | 当前未纳入范围，建议二期评估 |

## 10. 附录

### 10.1 现有代码参考位置

| 文件 | 关键行 | 说明 |
|------|--------|------|
| `middleware/dcloud.go:21-34` | `DCloudJWTClaims` 结构定义 | JWT Claims 数据模型 |
| `middleware/dcloud.go:130-148` | OtherRole 解析逻辑 | 将 JSON 转为 `OtherRoleMap` |
| `middleware/dcloud.go:157-218` | `SyncDCloudUser` | 用户同步，处理了 role 和 OtherRoleMap["newapi"] |
| `middleware/dcloud.go:254-321` | `DCloudAuth()` | 可选认证中间件，设置 context |
| `middleware/dcloud.go:325-404` | `DCloudAuthRequired()` | 必需认证中间件，设置 context |
| `middleware/auth.go:34-203` | `authHelper()` | 核心认证，含 DCloud JWT 认证分支 |
| `controller/log.go:13-58` | `GetAllLogs` | 日志查询入口，当前硬编码角色判断 |
| `model/log.go:21-43` | Log 结构定义 | 含 UserId、Group 等字段 |
| `model/log.go:258-345` | `GetAllLogs` (model) | 数据库查询，含 group 过滤条件 |
| `model/main.go:26` | `logGroupCol` 定义 | 跨数据库兼容的 group 列引用 |

### 10.2 术语对照

| 术语 | 含义 |
|------|------|
| 分权 | 根据用户权限控制能否访问日志功能 |
| 分域 | 根据用户权限控制能访问哪些组织的数据范围 |
| 前缀匹配 | SQL `LIKE 'prefix%'`，匹配指定组织编码开头的所有 group |
| 精确匹配 | SQL `= 'value'`，仅匹配 group 等于指定组织编码的记录 |
