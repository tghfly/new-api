# 任务清单：日志控制器模块

## 状态：未开始

## 任务描述

修改 `controller/log.go` 的三个接口：`GetAllLogs`、`GetLogsStat`、`DeleteHistoryLogs`，增加 DCloud 权限前置判断。当 `DCloudIntegrationEnabled=true` 且用户持有日志权限时，按权限范围过滤数据。

## 前置依赖

- `pkg/permission/` 包已实现（Phase 1）
- `model/log.go` 已扩展 GroupFilter 参数（Phase 3）

## 子任务

### 1. 辅助函数

- [ ] 实现 `getLogScope(data map[string]interface{}) string` — 安全读取 `Data["scope"]`
- [ ] 实现 `getLogOrgs(data map[string]interface{}) []string` — 安全读取 `Data["orgs"]`
- [ ] 实现 `getLogDeptId(data map[string]interface{}) string` — 安全读取 `Data["dept_id"]`
- [ ] 实现 `handleGetAllLogs(c *gin.Context, groupFilter *model.GroupFilter)` — 提取公用查询逻辑
- [ ] 实现 `handleGetUserLogs(c *gin.Context)` — 提取公用查询逻辑（me scope 专用）
- [ ] 实现 `handleGetLogsStat(c *gin.Context, username string, groupFilter *model.GroupFilter)` — 提取公用统计逻辑
- [ ] 实现 `returnEmptyLogData(c *gin.Context)` — 返回空的日志列表
- [ ] 实现 `returnEmptyLogStat(c *gin.Context)` — 返回空的统计数据

### 2. GetAllLogs DCloud 分支

- [ ] 在函数开头、role 判断之前，插入 DCloud 权限判断：
  ```go
  if common.DCloudIntegrationEnabled {
      auth := permission.LogsAuth.Resolve(c)
      if auth.HasAuth {
          scope := getLogScope(auth.Data)
          // switch scope { ... }
          return
      }
      // HasAuth=false → 继续走原有逻辑
  }
  ```
- [ ] 实现 `switch scope` 分支：
  - [ ] `LogScopeAll` → 调用 `handleGetAllLogs(c, nil)`（不过滤）
  - [ ] `LogScopeSpecDown` → 调用 `handleGetAllLogs(c, &model.GroupFilter{Mode:"prefix", Orgs:getLogOrgs(auth.Data)})`
  - [ ] `LogScopeSpec` → 调用 `handleGetAllLogs(c, &model.GroupFilter{Mode:"in", Orgs:getLogOrgs(auth.Data)})`
  - [ ] `LogScopeLocalDown` → 调用 `handleGetAllLogs(c, &model.GroupFilter{Mode:"prefix", Orgs:[]string{getLogDeptId(auth.Data)}})`
  - [ ] `LogScopeLocal` → 调用 `handleGetAllLogs(c, &model.GroupFilter{Mode:"exact", Orgs:[]string{getLogDeptId(auth.Data)}})`
  - [ ] `LogScopeMe` → 调用 `handleGetUserLogs(c)`（不走 GroupFilter，按 userId 查询）
  - [ ] default → 调用 `returnEmptyLogData(c)`（未知 scope 返回空数据）

### 3. GetLogsStat DCloud 分支

- [ ] 修改 `GetLogsStat` 函数，在统计查询之前插入 DCloud 权限判断：
  - [ ] `LogScopeAll` → `handleGetLogsStat(c, "", nil)`
  - [ ] `LogScopeSpecDown` → `handleGetLogsStat(c, "", &model.GroupFilter{Mode:"prefix", Orgs:getLogOrgs(auth.Data)})`
  - [ ] `LogScopeSpec` → `handleGetLogsStat(c, "", &model.GroupFilter{Mode:"in", Orgs:getLogOrgs(auth.Data)})`
  - [ ] `LogScopeLocalDown` → `handleGetLogsStat(c, "", &model.GroupFilter{Mode:"prefix", Orgs:[]string{getLogDeptId(auth.Data)})`
  - [ ] `LogScopeLocal` → `handleGetLogsStat(c, "", &model.GroupFilter{Mode:"exact", Orgs:[]string{getLogDeptId(auth.Data)})`
  - [ ] `LogScopeMe` → `handleGetLogsStat(c, c.GetString("username"), nil)`（只用当前用户 username，不用 query 参数）
  - [ ] default → `returnEmptyLogStat(c)`

### 4. DeleteHistoryLogs DCloud 分支

- [ ] 修改 `DeleteHistoryLogs` 函数，在删除操作之前插入 DCloud 权限判断：
  - [ ] `LogScopeMe` → 返回 403 + "无删除权限"（me 权限不允许删除）
  - [ ] `LogScopeAll` → `model.DeleteOldLog(ctx, targetTimestamp, 100, nil)`
  - [ ] `LogScopeSpecDown` → `model.DeleteOldLog(ctx, targetTimestamp, 100, &model.GroupFilter{Mode:"prefix", Orgs:getLogOrgs(auth.Data)})`
  - [ ] `LogScopeSpec` → `model.DeleteOldLog(ctx, targetTimestamp, 100, &model.GroupFilter{Mode:"in", Orgs:getLogOrgs(auth.Data)})`
  - [ ] `LogScopeLocalDown` → `model.DeleteOldLog(ctx, targetTimestamp, 100, &model.GroupFilter{Mode:"prefix", Orgs:[]string{getLogDeptId(auth.Data)})`
  - [ ] `LogScopeLocal` → `model.DeleteOldLog(ctx, targetTimestamp, 100, &model.GroupFilter{Mode:"exact", Orgs:[]string{getLogDeptId(auth.Data)})`
  - [ ] default → 返回 403 + "无删除权限"

### 5. 集成测试

- [ ] 使用 SQLite 内存数据库编写集成测试（可选，参考详细设计文档 10.2.3）
- [ ] TC-C-01 ~ TC-C-17 测试用例覆盖

## 验收标准

- [ ] `GetAllLogs` 在 DCloud 用户持有日志权限时按 scope 过滤数据
- [ ] `GetLogsStat` 在 DCloud 用户持有日志权限时按 scope 过滤统计数据
- [ ] `DeleteHistoryLogs` 在 DCloud 用户持有日志权限时按 scope 控制删除范围
- [ ] `me` 权限调用 `DeleteHistoryLogs` 返回 403
- [ ] `me` 权限调用 `GetLogsStat` 只统计当前用户数据
- [ ] `HasAuth=false` 或 DCloud 禁用时继续走原有逻辑
- [ ] TC-C-01 ~ TC-C-17 全部通过