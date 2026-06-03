# 任务清单：Model 层扩展

## 状态：未开始

## 任务描述

扩展 `model/log.go` 中的日志查询方法，增加 `GroupFilter` 参数支持组织级别的数据过滤。`GroupFilter` 为通用结构，可被日志、统计、删除等多个方法复用。

## 前置依赖

- 无（纯 Model 层扩展，不依赖其他模块）

## 子任务

### 1. GroupFilter 结构体

- [ ] 在 `model/log.go` 中定义 `GroupFilter` 结构体
  ```go
  type GroupFilter struct {
      Mode string   // "prefix" | "exact" | "in"
      Orgs []string // 组织编码列表
  }
  ```

### 2. applyGroupFilter 辅助函数

- [ ] 实现 `applyGroupFilterWithTable(tx *gorm.DB, groupFilter *GroupFilter, tablePrefix string) *gorm.DB`
  - [ ] `Mode = "prefix"`: 生成 `groupCol LIKE 'org1%' OR groupCol LIKE 'org2%'`
  - [ ] `Mode = "exact"`: 单 org 用 `=`，多 org 用 `IN ?`
  - [ ] `Mode = "in"`: 使用 `IN ?`
  - [ ] `groupFilter == nil` 或 `len(Orgs) == 0` 时直接返回 tx（不过滤）
  - [ ] 使用 `logGroupCol` 变量保证跨数据库兼容
- [ ] 实现 `applyGroupFilter(tx *gorm.DB, groupFilter *GroupFilter) *gorm.DB`
  - [ ] 默认 `tablePrefix = "logs."`，调用 `applyGroupFilterWithTable`

### 3. GetAllLogs 扩展

- [ ] 修改函数签名的最后参数为 `groupFilter *GroupFilter`
  ```go
  func GetAllLogs(..., groupFilter *GroupFilter) (logs []*Log, total int64, err error)
  ```
- [ ] 在现有 group 精确匹配条件之后（log.go:291 行附近），增加：
  ```go
  if groupFilter != nil {
      tx = applyGroupFilter(tx, groupFilter)
  }
  ```

### 4. GetUserLogs 扩展

- [ ] 修改函数签名增加 `groupFilter *GroupFilter` 参数
  ```go
  func GetUserLogs(..., groupFilter *GroupFilter) (logs []*Log, total int64, err error)
  ```
- [ ] 在现有 group 精确匹配条件之后（log.go:377 行附近），增加 groupFilter 过滤逻辑

### 5. SumUsedQuota 扩展

- [ ] 修改函数签名增加 `groupFilter *GroupFilter` 参数
  ```go
  func SumUsedQuota(..., groupFilter *GroupFilter) (stat Stat, err error)
  ```
- [ ] 在现有 group 精确匹配条件之后（log.go:476 行附近），同时应用到 `tx` 和 `rpmTpmQuery`:
  ```go
  if groupFilter != nil {
      tx = applyGroupFilter(tx, groupFilter)
      rpmTpmQuery = applyGroupFilter(rpmTpmQuery, groupFilter)
  }
  ```

### 6. DeleteOldLog 扩展

- [ ] 修改函数签名为 `DeleteOldLog(ctx context.Context, targetTimestamp int64, limit int, groupFilter *GroupFilter) (int64, error)`
- [ ] 在 `LOG_DB.Where("created_at < ?", targetTimestamp)` 之后，`Limit(limit).Delete(&Log{})` 之前
- [ ] 增加 groupFilter 过滤（使用 `applyGroupFilterWithTable(tx, groupFilter, "")`，因为 DeleteOldLog 不使用表别名）

### 7. 集成测试

- [ ] 使用 SQLite 内存数据库编写集成测试
- [ ] 验证 `applyGroupFilter` 生成的 SQL 正确（prefix/exact/in 三种模式）
- [ ] 验证 GroupFilter 为 nil 时行为与原逻辑一致
- [ ] TC-M-01 ~ TC-M-08 测试用例全部通过

## 验收标准

- [ ] 四个查询方法均支持 `GroupFilter` 参数
- [ ] `Mode = "prefix"` 生成 `LIKE 'org%'` 条件
- [ ] `Mode = "exact"` 生成 `= 'org'` 或 `IN (...)` 条件
- [ ] `Mode = "in"` 生成 `IN (...)` 条件
- [ ] `GroupFilter = nil` 时不过滤，与原行为一致
- [ ] 跨数据库兼容（使用 `logGroupCol`）
- [ ] TC-M-01 ~ TC-M-08 全部通过