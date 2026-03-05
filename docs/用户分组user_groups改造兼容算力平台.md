# 用户分组(user_groups)改造兼容算力平台

## 一、背景与需求

当前 new-api 用户管理只有用户概念，没有组织或部门概念，也没有项目概念，但有一个用户组的概念。用户组主要用于 API 限速以及倍率、用户充值最小金额与最大金额。

算力平台 cloud-web 目前已经集成 new-api，目前的集成也就是用户打通了(登录和角色)，但 cloud-web 除了租户、用户体系，还有部门、项目。需要让 new-api 支持部门、项目概念。

## 二、现状分析

### 2.1 new-api 用户组架构

```
┌─────────────────────────────────────────────────────────────┐
│  层级1: 用户 (User)                                          │
│  ├── 字段: group (string) - 用户所属的用户组                   │
│  └── 作用: 默认用户组，用于计费、限速等                        │
├─────────────────────────────────────────────────────────────┤
│  层级2: API令牌 (Token)                                       │
│  ├── 字段: group (string) - 令牌分组                          │
│  └── 作用: 每个令牌只能属于一个用户组                          │
│      └── 创建令牌时选择的分组决定了该令牌的倍率/限速策略        │
├─────────────────────────────────────────────────────────────┤
│  层级3: 渠道/模型 (Channel)                                   │
│  ├── 字段: group (string) - 逗号分隔的多个用户组               │
│  └── 作用: 渠道可以服务多个用户组                              │
└─────────────────────────────────────────────────────────────┘
```

**关键结论**：
- API 限速/倍率最终作用在 Token 级别（通过 `ContextKeyUsingGroup = tokenGroup`）
- 权限控制是基于用户的默认可用分组列表（通过 `GetUserUsableGroups(userCache.Group)`）
- 用户创建 Token 时，只能选择自己有权访问的项目（必须在用户的项目列表中）
- 渠道可以关联多个项目，但只有 Token 所属项目在渠道关联列表中时才能调用
- **`users.group` 和 `token.group` 都对应算力平台的 project_code**，而非 vdc_code

### 2.2 算力平台数据结构

浏览器本地存储localstorage `saber-userInfo`：
```json
{
  "content": {
    "account": "D15012",
    "tenantId": "888888",
    "vdcCode": "02002I02J02N",
    "deptId": "147",
    "deptName": "云平台研发部",
    "projectId": "28,95,96",
    "project_code": "02002I02J02NP01X,02002I02J02NP01Y,02002I02J02NP01Z",
    "projectName": "dcloud,演示项目,laap-project"
  }
}
```

当前项目信息 `saber-currentProject`：
```json
{
  "content": {
    "id": 95,
    "name": "演示项目",
    "project_code": "02002I02J02NP01X",
    "vdc_code": "02002I02J02N"
  }
}
```

## 三、映射方案设计

### 3.1 核心映射关系

| 算力平台概念 | new-api 字段 | 说明 |
|------------|-------------|------|
| **项目 (Project)** | **用户组 (UserGroup)** | 一对一映射 |
| 项目ID (project_id) | user_groups.external_id | 项目唯一标识 |
| 项目编码 (project_code) | user_groups.symbol | 作为用户组的 Symbol |
| 项目编码 (project_code) | user_groups.project_code | 原始项目代码 |
| 项目名称 (project_name) | user_groups.name | 项目名称 |
| 组织编码 (vdc_code) | user_groups.dept_id | 组织编码（冗余存储）|
| 租户ID (tenant_id) | user_groups.tenant_id | 租户ID |
| **用户的默认项目** | **users.group** | 对应 project_code |
| **令牌绑定的项目** | **token.group** | 对应 project_code |

### 3.2 Symbol 生成规则

```go
// 格式: {project_code}
// 示例: 02002I02J02NP01X
symbol := projectCode
```

**说明**：
- project_code 本身就能唯一标识一个项目（如 `02002I02J02NP01X`）
- tenant_id 和 dept_id 已在其他字段独立存储
- Symbol 只需保证唯一性，无需包含层级信息

### 3.3 用户多项目支持实现

由于一个用户可以拥有多个 Token，而每个 Token 只属于一个用户组（项目）：

```go
// 场景：用户A属于项目P1、P2、P3
// 实现方式：
Token1: { Name: "P1-Key", Group: "02002I02J02NP01X", UserId: A }  // P1项目令牌
Token2: { Name: "P2-Key", Group: "02002I02J02NP01Y", UserId: A }  // P2项目令牌
Token3: { Name: "P3-Key", Group: "02002I02J02NP01Z", UserId: A }  // P3项目令牌
```

### 3.4 users.group 的处理

**重要说明**：
1. `users.group` 对应算力平台的 **project_code**，不是 vdc_code
2. `users.group` 是用户的默认项目，从用户的项目列表中选择一个作为默认值
3. 建议将当前选中的项目（`saber-currentProject.project_code`）设为 `users.group`
4. 如果用户有多个项目，优先使用第一个项目作为默认值
5. 真正的权限控制是在 `Token.Group` 级别，创建 Token 时必须选择具体的项目

## 四、数据同步方案

### 4.1 方案：前端存储驱动同步（推荐）

利用 `saber-userInfo` 中的 `projectId`、`project_code` 和 `projectName`：

**同步时机**：
1. 用户登录时，从 `saber-userInfo` 读取项目列表
2. 调用 new-api 接口同步用户组信息
3. 如果项目不存在于 new-api，自动创建对应的 UserGroup

**优势**：
- ✅ 无需算力平台提供额外接口
- ✅ 不破坏 new-api 原始数据结构
- ✅ 实时同步，用户切换项目后立即生效

### 4.2 同步逻辑

```go
// 解析逗号分隔的项目列表
projectIds := strings.Split("28,95,96", ",")
projectNames := strings.Split("dcloud,演示项目,laap-project", ",")
projectCodes := strings.Split("02002I02J02NP01X,02002I02J02NP01Y,02002I02J02NP01Z", ",")

for i := range projectIds {
    userGroup := &UserGroup{
        ExternalId:  parseInt(projectIds[i]),
        Symbol:      projectCodes[i],           // 直接用 project_code
        Name:        projectNames[i],
        ProjectCode: projectCodes[i],
        DeptId:      vdcCode,
        TenantId:    tenantId,
        Source:      "synced",
    }
    // 保存到数据库
}
```

## 五、开发计划

### Phase 1: 数据库变更 ✅ 已完成

#### 1.1 新增用户-用户组关联表 ✅

```sql
-- 见 bin/migration_user_group_mappings.sql
CREATE TABLE user_group_mappings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL COMMENT 'new-api 用户ID',
    group_id INT NOT NULL COMMENT '用户组ID',
    external_user_id VARCHAR(64) COMMENT '算力平台用户ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_group (user_id, group_id),
    INDEX idx_user_id (user_id),
    INDEX idx_group_id (group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**说明**：
- 建立用户和用户组的多对多关系
- 一个用户可以属于多个用户组（项目）
- 通过 external_user_id 记录算力平台的用户ID

### Phase 2: 后端接口开发 ✅ 已完成

#### 2.1 修改 Symbol 生成规则 ⏸️ 待定
- [ ] 修改 `model/user_group.go` 中的 GetSymbol() 方法
- [ ] 当 Source == "dcloud" 时，返回 project_code 作为 symbol
- [ ] 确保现有 local 用户的 symbol 不受影响

#### 2.2 批量同步用户组接口 ✅ 已完成
- [x] 修改 `POST /api/user-groups/batch-sync` 接口
- [x] 接收参数：tenant_id, vdc_code, projects[]
- [x] 批量创建或更新 synced 类型的用户组
- [x] **同时建立 user 和 user_group 的关联关系**
- [x] 返回统计信息：created_count, updated_count

#### 2.3 获取用户项目列表接口 ✅ 已完成
- [x] 修改 `GET /api/user/self/groups` 接口
- [x] **根据 user_group_mappings 表查询用户关联的所有用户组**
- [x] 返回用户的所有可访问项目列表

#### 2.4 修改 GetUserUsableGroups 函数 ✅ 已完成
- [x] 修改 `service/group.go` 中的 GetUserUsableGroups 函数
- [x] 添加 userId 参数
- [x] 查询 user_group_mappings 表获取用户关联的所有用户组
- [x] 将这些用户组加入可用分组列表

#### 2.5 修改调用处 ✅ 已完成
- [x] `middleware/auth.go` - TokenAuth 中间件
- [x] `controller/group.go` - GetUserGroups
- [x] `controller/pricing.go` - GetPricing
- [x] `controller/user.go` - GetUserModels

#### 2.6 修改 DCloud 登录同步逻辑 ⏸️ 待定
- [ ] 修改 `middleware/dcloud.go` 中的 SyncDCloudUserWithProjects 函数
- [ ] 调用 BatchSyncUserGroups 批量同步项目为用户组
- [ ] **调用 SaveUserGroupMappings 建立用户-用户组关联**
- [ ] 设置用户默认分组为第一个项目的 project_code

### Phase 3: 前端适配改造 ✅ 已完成

#### 3.1 Token 创建页面 ✅ 已完成
- [x] `EditTokenModal.jsx` 已使用 `/api/user/self/groups` 接口
- [x] 下拉选项显示用户有权限的项目

#### 3.2 用户管理页面 ✅ 已完成
- [x] `useUsersData.jsx` - 修改 `processGroupsData` 函数适配新格式
- [x] `EditUserModal.jsx` - 修改 `fetchGroups` 函数适配新格式

#### 3.3 渠道管理页面 ✅ 已完成
- [x] `EditChannelModal.jsx` - 修改 `fetchGroups` 函数适配新格式
- [x] `EditTagModal.jsx` - 修改 `fetchGroups` 函数适配新格式
- [x] `useChannelsData.jsx` - 修改 `fetchGroups` 函数适配新格式

**前端改造说明**：
所有涉及 `/api/group/` 接口的前端组件都已适配新的返回格式：
```javascript
// 旧格式: data 是字符串数组 ["default", "vip"]
// 新格式: data 是对象数组 [{symbol, name, desc, ratio}]

// 适配后的代码示例:
setGroupOptions(
  res.data.data.map((group) => ({
    label: group.name || group.symbol,  // 显示名称
    value: group.symbol,                 // 使用 symbol 作为值
  })),
);
```


## 六、接口设计

### 6.1 批量同步用户组接口

```http
POST /api/user-groups/sync
Content-Type: application/json

{
  "tenant_id": "888888",
  "vdc_code": "02002I02J02N",
  "projects": [
    {
      "external_id": 28,
      "project_code": "02002I02J02NP01X",
      "project_name": "dcloud"
    },
    {
      "external_id": 95,
      "project_code": "02002I02J02NP01Y",
      "project_name": "演示项目"
    }
  ]
}
```

响应：
```json
{
  "success": true,
  "data": {
    "created": 2,
    "updated": 0,
    "groups": [
      {
        "id": 1,
        "symbol": "02002I02J02NP01X",
        "name": "dcloud"
      }
    ]
  }
}
```

### 6.2 获取用户所属项目列表接口

```http
GET /api/user/my-groups
```

响应：
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "symbol": "02002I02J02NP01X",
      "name": "dcloud",
      "ratio": 1.0,
      "api_rate": 600
    },
    {
      "id": 2,
      "symbol": "02002I02J02NP01Y",
      "name": "演示项目",
      "ratio": 1.0,
      "api_rate": 600
    }
  ]
}
```

## 七、数据库变更

### 7.1 新增用户-用户组关联表

```sql
-- 用户-用户组关联表
CREATE TABLE user_group_mappings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL COMMENT 'new-api 用户ID',
    group_id INT NOT NULL COMMENT '用户组ID',
    external_user_id VARCHAR(64) COMMENT '算力平台用户ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_group (user_id, group_id),
    INDEX idx_user_id (user_id),
    INDEX idx_group_id (group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 7.2 现有 user_groups 表结构

```go
TenantId    string `json:"tenant_id" gorm:"type:varchar(12);index;default:''"`    // 租户ID
DeptId      string `json:"dept_id" gorm:"type:varchar(64);index;default:''"`      // 部门ID，对应算力平台的vdc_code
ProjectCode string `json:"project_code" gorm:"type:varchar(64);index;default:''"` // 原始项目代码
ExternalId  int64  `json:"external_id" gorm:"index;default:0"`                    // cloud-web 项目ID
Source      string `json:"source" gorm:"type:varchar(20);default:'local'"`        // 来源: local/synced
```

## 八、核心代码实现

### 8.1 用户-用户组关联模型

```go
// model/user_group_mapping.go
type UserGroupMapping struct {
    Id             int       `json:"id" gorm:"primary_key"`
    UserId         int       `json:"user_id" gorm:"index;not null"`
    GroupId        int       `json:"group_id" gorm:"index;not null"`
    ExternalUserId string    `json:"external_user_id" gorm:"type:varchar(64)"`
    CreatedAt      time.Time `json:"created_at"`
}

// GetUserGroupsByUserId 根据用户ID获取关联的所有用户组
func GetUserGroupsByUserId(userId int) ([]*UserGroup, error) {
    var userGroups []*UserGroup
    err := DB.Joins("JOIN user_group_mappings ON user_group_mappings.group_id = user_groups.id").
        Where("user_group_mappings.user_id = ?", userId).
        Find(&userGroups).Error
    return userGroups, err
}

// SaveUserGroupMapping 保存用户-用户组关联
func SaveUserGroupMapping(userId, groupId int, externalUserId string) error {
    mapping := UserGroupMapping{
        UserId:         userId,
        GroupId:        groupId,
        ExternalUserId: externalUserId,
        CreatedAt:      time.Now(),
    }
    // 使用 ON DUPLICATE KEY UPDATE 或 REPLACE INTO 避免重复
    return DB.Where("user_id = ? AND group_id = ?", userId, groupId).
        FirstOrCreate(&mapping).Error
}

// DeleteUserGroupMappingsByUserId 删除用户的所有关联
func DeleteUserGroupMappingsByUserId(userId int) error {
    return DB.Where("user_id = ?", userId).Delete(&UserGroupMapping{}).Error
}
```

### 8.2 修改 GetUserUsableGroups

```go
// service/group.go
func GetUserUsableGroups(userGroup string, userId int) map[string]string {
    groupsCopy := setting.GetUserUsableGroupsCopy()
    
    // 添加用户关联的所有用户组
    userGroups, err := model.GetUserGroupsByUserId(userId)
    if err == nil {
        for _, g := range userGroups {
            groupsCopy[g.Symbol] = g.Name
        }
    }
    
    // 保留原有逻辑：添加用户的默认分组
    if userGroup != "" {
        if _, ok := groupsCopy[userGroup]; !ok {
            groupsCopy[userGroup] = "用户分组"
        }
    }
    
    return groupsCopy
}
```

### 8.3 批量同步时建立关联

```go
// 在批量同步用户组时，同时建立 user 和 user_group 的关联
func SyncUserGroups(projects []map[string]interface{}, userId int, externalUserId string) (int, int, error) {
    created, updated, err := model.BatchSyncUserGroups(tenantId, vdcCode, projects)
    if err != nil {
        return 0, 0, err
    }
    
    // 建立用户-用户组关联
    for _, project := range projects {
        externalId := int64(project["external_id"].(float64))
        projectCode := project["project_code"].(string)
        
        // 获取用户组
        userGroup, err := model.GetUserGroupByExternalId(externalId)
        if err != nil {
            continue
        }
        
        // 建立关联
        model.SaveUserGroupMapping(userId, userGroup.Id, externalUserId)
    }
    
    return created, updated, nil
}
```

## 九、权限验证流程详解

### 9.1 TokenAuth 中的用户组判断逻辑

```go
// middleware/auth.go - TokenAuth()

// 1. 获取用户的默认分组（对应 project_code）
userGroup := userCache.Group      // 如: "02002I02J02NP01X"
                                  // 来自 users.group 字段

// 2. 获取令牌绑定的分组（对应 project_code）
tokenGroup := token.Group         // 如: "02002I02J02NP01Y"
                                  // 来自 token.group 字段

if tokenGroup != "" {
    // 3. 检查用户是否有权访问该分组
    // GetUserUsableGroups 返回用户默认可用的所有分组列表
    if _, ok := service.GetUserUsableGroups(userGroup, userId)[tokenGroup]; !ok {
        abortWithOpenAiMessage(c, http.StatusForbidden, 
            fmt.Sprintf("无权访问 %s 分组", tokenGroup))
        return
    }
    
    // 4. 最终使用的分组 = 令牌指定的分组
    userGroup = tokenGroup
}

// 5. 设置上下文中的使用分组
common.SetContextKey(c, constant.ContextKeyUsingGroup, userGroup)
```

### 9.2 完整验证流程示例

**场景**：用户A属于项目 P1(02002I02J02NP01X) 和 P2(02002I02J02NP01Y)

| 步骤 | 操作 | 数据 |
|-----|------|------|
| 1 | 登录同步 | `users.group` = "P1" (第一个项目) |
| 2 | 同步用户组 | user_groups 表新增 P1、P2 两条记录 |
| 3 | 建立关联 | user_group_mappings 表记录 A->P1, A->P2 |
| 4 | 创建Token1 | 下拉选项：[P1, P2]，选择 P1 |
| 5 | 创建Token2 | 下拉选项：[P1, P2]，选择 P2 |
| 6 | 使用Token1调用API | 验证：P1 在用户的可用列表中 ✅ |
| 7 | 使用Token2调用API | 验证：P2 在用户的可用列表中 ✅ |

**关键点**：
- `users.group` 只是用于构建用户的默认可用分组列表
- 真正的权限控制是检查 `token.group` 是否在可用列表中
- 两个字段都存储 project_code，不是 vdc_code
- 通过 user_group_mappings 表建立用户和用户组的多对多关系

## 十、总结

本方案通过以下改进实现了算力平台项目与 new-api 用户组的完全兼容：

1. ✅ **新增用户-用户组关联表**：解决一个用户属于多个项目的问题
2. ✅ **改进同步逻辑**：同步项目时同时建立用户-用户组关联
3. ✅ **改进权限验证**：通过关联表查询用户所有可访问的项目
4. ✅ **保持向后兼容**：不影响现有 local 用户的使用
5. ✅ **无需算力平台提供额外接口**：利用前端 localStorage 数据驱动同步

实施本方案后，用户可以在算力平台切换项目，然后在 new-api 中创建对应项目的 Token 来调用 API，实现项目级别的资源隔离和计费。
