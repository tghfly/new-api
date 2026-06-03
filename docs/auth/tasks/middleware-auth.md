# 任务清单：认证中间件模块

## 状态：未开始

## 任务描述

修改 `middleware/dcloud.go` 和 `middleware/auth.go`，在 DCloud 认证流程中补充 `vdc_code` 和 `other_role_map` 到 gin context，并修改 `AdminAuth` 支持 DCloud 日志权限 key 绕过 role 检查。

## 前置依赖

- `pkg/permission/` 包已实现（Phase 1）

## 子任务

### 1. context 补充 — DCloudAuth

- [ ] 在 `DCloudAuth()` JWT 认证成功后，`c.Set("use_access_token", false)` 之后
- [ ] 添加 `c.Set("vdc_code", claims.VdcCode)`
- [ ] 添加 `c.Set("other_role_map", claims.OtherRoleMap)`

### 2. context 补充 — DCloudAuthRequired

- [ ] 在 `DCloudAuthRequired()` JWT 认证成功后，`c.Set("use_access_token", false)` 之后
- [ ] 添加 `c.Set("vdc_code", claims.VdcCode)`
- [ ] 添加 `c.Set("other_role_map", claims.OtherRoleMap)`

### 3. context 补充 — authHelper（DCloud JWT 分支）

- [ ] 在 `authHelper()` 的 DCloud JWT 认证分支中（第 91-96 行，`dcloudAuth = true` 之后）
- [ ] 添加 `c.Set("vdc_code", claims.VdcCode)`
- [ ] 添加 `c.Set("other_role_map", claims.OtherRoleMap)`

### 4. AdminAuth 绕过逻辑

- [ ] 在 `authHelper()` 的 `role.(int) < minRole` 检查之前（原第 177 行位置）
- [ ] 实现 `skipRoleCheck` 判断逻辑：
  - [ ] `if common.DCloudIntegrationEnabled && dcloudAuth`
  - [ ] 从 context 获取 `other_role_map`
  - [ ] 遍历 map keys，检查是否存在 `new-api:*:auth` 模式（`strings.HasPrefix(key, "new-api:") && strings.HasSuffix(key, ":auth")`）
  - [ ] 存在则设置 `skipRoleCheck = true`
- [ ] 修改 role 检查条件为 `if !skipRoleCheck && role.(int) < minRole`

### 5. ResolveLogAuth 转发（保持导出符号兼容）

- [ ] 将现有的 `ResolveLogAuth()` 函数改为转发到 `permission.LogsAuth.Resolve(c)`
- [ ] 确保函数签名和返回值不变，保持对 `middleware/dcloud.go` 原有调用方的兼容

## 验收标准

- [ ] `middleware/auth.go` 中 `role < minRole` 检查在 DCloud 用户持有任意 `new-api:*:auth` key 时被跳过
- [ ] `DCloudAuth()` / `DCloudAuthRequired()` / `authHelper()` 三处 context 均正确设置 `vdc_code` 和 `other_role_map`
- [ ] `ResolveLogAuth()` 转发到 `permission.LogsAuth.Resolve(c)` 行为一致
- [ ] TC-A-01 ~ TC-A-09 测试用例全部通过