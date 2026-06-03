# 任务清单：通用权限解析框架

## 状态：未开始

## 任务描述

实现 `pkg/permission/` 包，提供通用的权限解析框架，支持通过 `ParseFunc` 自定义解析逻辑，解析结果存入 `Result.Data map`。

## 前置依赖

- 无（独立模块，无外部依赖）

## 子任务

### 1. permission.go — 核心框架

- [ ] 定义 `Result` 结构体（`HasAuth bool`, `Data map[string]interface{}`）
- [ ] 定义 `ParseFunc` 类型（`func(value string) (data map[string]interface{}, ok bool)`）
- [ ] 定义 `Resolver` 结构体（`primaryKey`, `fallbackKey`, `parseFunc`）
- [ ] 实现 `NewResolver(primaryKey, fallbackKey string, parseFunc ParseFunc) *Resolver`
- [ ] 实现 `Resolver.Resolve(c *gin.Context) Result`
  - [ ] 从 context 获取 `other_role_map`
  - [ ] 优先查 `primaryKey`，调用 `parseFunc` 解析 value
  - [ ] 不存在或格式错误时查 `fallbackKey`
  - [ ] 格式错误时视为该 key 不存在，继续兜底
  - [ ] 解析成功后自动注入 `dept_id` 到 Data（从 context 获取）
- [ ] 实现 `getDeptId(c *gin.Context) string`

### 2. scope.go — 通用 scope 解析器

- [ ] 实现 `parseScopeValue(value string) (scope string, orgs []string, ok bool)`
  - [ ] 支持格式：`"all"`, `"spec_down:X,Y"`, `"spec:X,Y"`, `"local_down"`, `"local"`, `"me"`
  - [ ] 格式错误处理（空字符串、大小写不匹配、空组织列表、空白组织、尾部逗号、前导空格、无法识别的 scope）

### 3. logs.go — 日志权限

- [ ] 定义日志 scope 常量（`LogScopeAll`, `LogScopeSpecDown`, `LogScopeSpec`, `LogScopeLocalDown`, `LogScopeLocal`, `LogScopeMe`）
- [ ] 实现 `parseLogAuthValue(value string) (map[string]interface{}, bool)`
  - [ ] 调用 `parseScopeValue` 获取 scope 和 orgs
  - [ ] 返回 Data map: `{"scope": scope, "orgs": orgs}`
- [ ] 创建预定义实例 `LogsAuth = NewResolver("new-api:logs:auth", "new-api:auth", parseLogAuthValue)`

### 4. 测试文件

- [ ] `permission_test.go` — 通用框架单元测试
  - [ ] `TestResolver_Resolve` — 各 key 优先级、格式错误、HasAuth=false 场景
- [ ] `logs_test.go` — 日志权限单元测试
  - [ ] `TestParseLogAuthValue` — 各 value 格式解析结果
  - [ ] `TestLogsAuth_Resolve` — 集成测试（primaryKey 优先、fallbackKey 兜底）
  - [ ] `TestParseScopeValue` — 边界情况测试（TC-P-11 ~ TC-P-19）

## 验收标准

- [ ] `go test ./pkg/permission/` 全部通过
- [ ] `Result.Data` 使用 `map[string]interface{}`，不写死具体 key
- [ ] 新增权限类型时只需创建 `Resolver` 实例 + `ParseFunc`，框架层无需修改