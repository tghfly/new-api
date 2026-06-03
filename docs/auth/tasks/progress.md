# 调用日志分权分域 — 实施进度

## 项目概述

根据需求文档、概要设计文档、详细设计文档，将实施工作划分为 5 个 Phase，共 4 个模块。

## 进度总览

| # | 模块 | 阶段 | 状态 | 验收标准 |
|---|------|------|------|---------|
| 1 | pkg/permission — 通用权限解析框架 | Phase 1 | ⬜ 未开始 | go test ./pkg/permission/ 全部通过 |
| 2 | middleware — 认证中间件改造 | Phase 2 | ⬜ 未开始 | TC-A-01 ~ TC-A-09 全部通过 |
| 3 | model/log — Model 层扩展 | Phase 3 | ⬜ 未开始 | TC-M-01 ~ TC-M-08 全部通过 |
| 4 | controller/log — 日志控制器改造 | Phase 4 | ⬜ 未开始 | TC-C-01 ~ TC-C-17 全部通过 |
| 5 | 集成测试 | Phase 5 | ⬜ 未开始 | 端到端流程验证 |

## 详细进度

### Phase 1：通用权限解析框架

**模块文件：** `docs/auth/tasks/pkg-permission.md`

- [ ] **未开始** `pkg/permission/permission.go` — 核心框架（Result, ParseFunc, Resolver, NewResolver, Resolve）
- [ ] **未开始** `pkg/permission/scope.go` — parseScopeValue 辅助函数
- [ ] **未开始** `pkg/permission/logs.go` — 日志权限（parseLogAuthValue, LogsAuth 实例）
- [ ] **未开始** `pkg/permission/permission_test.go` — 通用框架单元测试
- [ ] **未开始** `pkg/permission/logs_test.go` — 日志权限单元测试

**验证命令：** `go test ./pkg/permission/`

---

### Phase 2：认证中间件改造

**模块文件：** `docs/auth/tasks/middleware-auth.md`

- [ ] **未开始** DCloudAuth — context 补充（vdc_code, other_role_map）
- [ ] **未开始** DCloudAuthRequired — context 补充（vdc_code, other_role_map）
- [ ] **未开始** authHelper — DCloud JWT 分支 context 补充
- [ ] **未开始** AdminAuth — 泛化绕过逻辑（new-api:*:auth 模式匹配）
- [ ] **未开始** ResolveLogAuth — 转发到 permission.LogsAuth.Resolve(c)

**验证命令：** `go test ./middleware/ -run TestAdminAuth`

---

### Phase 3：Model 层扩展

**模块文件：** `docs/auth/tasks/model-log.md`

- [ ] **未开始** GroupFilter 结构体定义
- [ ] **未开始** applyGroupFilterWithTable / applyGroupFilter 辅助函数
- [ ] **未开始** GetAllLogs — 扩展 GroupFilter 参数
- [ ] **未开始** GetUserLogs — 扩展 GroupFilter 参数
- [ ] **未开始** SumUsedQuota — 扩展 GroupFilter 参数
- [ ] **未开始** DeleteOldLog — 扩展 GroupFilter 参数
- [ ] **未开始** 集成测试（SQLite 内存数据库）

**验证命令：** `go test ./model/ -run TestGroupFilter`

---

### Phase 4：日志控制器改造

**模块文件：** `docs/auth/tasks/controller-log.md`

- [ ] **未开始** 辅助函数（getLogScope, getLogOrgs, getLogDeptId, handleGetAllLogs, handleGetUserLogs, handleGetLogsStat, returnEmptyLogData, returnEmptyLogStat）
- [ ] **未开始** GetAllLogs — DCloud 分支接入
- [ ] **未开始** GetLogsStat — DCloud 分支接入
- [ ] **未开始** DeleteHistoryLogs — DCloud 分支接入

**验证命令：** `go test ./controller/ -run TestLog`

---

### Phase 5：集成测试

- [ ] **未开始** 端到端流程验证（DCloud JWT → AdminAuth 绕过 → Controller DCloud 分支 → Model GroupFilter）

---

## 测试用例清单

### 权限解析框架测试用例（pkg/permission/）

| 编号 | 测试场景 | 状态 |
|------|---------|------|
| TC-P-01 | primaryKey→all | ⬜ |
| TC-P-02 | primaryKey→spec_down 多组织 | ⬜ |
| TC-P-03 | primaryKey→spec 单组织 | ⬜ |
| TC-P-04 | primaryKey→local_down（含 dept_id） | ⬜ |
| TC-P-05 | primaryKey→local（含 dept_id） | ⬜ |
| TC-P-06 | primaryKey→me | ⬜ |
| TC-P-07 | 优先级：两个 key 都存在 | ⬜ |
| TC-P-08 | 兜底：primaryKey 空，fallbackKey 存在 | ⬜ |
| TC-P-09 | 两个 key 都不存在 | ⬜ |
| TC-P-10 | other_role_map 为 nil | ⬜ |
| TC-P-11 ~ TC-P-19 | parseScopeValue 边界情况 | ⬜ |

### 认证中间件测试用例

| 编号 | 测试场景 | 状态 |
|------|---------|------|
| TC-A-01 | 非 DCloud 模式，role < 10 | ⬜ |
| TC-A-02 | 非 DCloud 模式，role >= 10 | ⬜ |
| TC-A-03 | DCloud + 日志 key，role < 10 | ⬜ |
| TC-A-04 | DCloud + 通用 key，role < 10 | ⬜ |
| TC-A-05 | DCloud + 无 key，role < 10 | ⬜ |
| TC-A-06 | DCloud + 无 key，role >= 10 | ⬜ |
| TC-A-07 | DCloud + 日志 key，role >= 10 | ⬜ |
| TC-A-08 | DCloud + dcloudAuth=false | ⬜ |
| TC-A-09 | DCloud + 未来扩展 key，role < 10 | ⬜ |

### 日志控制器测试用例

| 编号 | 测试场景 | 状态 |
|------|---------|------|
| TC-C-01 ~ TC-C-17 | GetAllLogs / GetLogsStat / DeleteHistoryLogs DCloud 分支 | ⬜ |

### Model 层测试用例

| 编号 | 测试场景 | 状态 |
|------|---------|------|
| TC-M-01 ~ TC-M-08 | GroupFilter prefix/exact/in 模式及边界情况 | ⬜ |

---

## 变更文件清单

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