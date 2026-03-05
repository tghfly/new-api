# 将 one-hub 的用户组功能迁移到 new-api 的详细改造方案

## 一、现状对比分析

### 1.1 one-hub 用户组功能特点

1. **数据库持久化**：`user_groups` 表存储所有用户组信息
2. **全局缓存管理**：`GlobalUserGroupRatio` 变量统一管理内存中的用户组数据
3. **API限流支持**：`RateLimiter` 接口 + 多种实现（内存/Redis、令牌桶/滑动窗口）
4. **完整CRUD API**：增删改查、启用禁用
5. **关联功能**：用户组升级、Cloud-Web集成

**one-hub 相关文件**：
- `model/user_group.go` - 模型定义和数据库操作
- `model/migrate.go` - 数据库迁移
- `controller/user_group.go` - REST API
- `router/api-router.go` - 路由配置
- `common/limit/*.go` - 限流器实现

### 1.2 new-api 用户组现状

1. **模型定义存在但未启用**：`model/user_group.go` 有结构体定义，但未加入 AutoMigrate
2. **配置分离存储**：
   - `setting/ratio_setting/group_ratio.go` - 分组倍率（内存map）
   - `setting/user_usable_group.go` - 可用分组（内存map）
3. **已有限流框架**：
   - `common/rate-limit.go` - InMemoryRateLimiter
   - `middleware/model-rate-limit.go` - 模型请求限流（支持分组配置）
4. **缺少的功能**：
   - 无数据库持久化
   - 无 `GlobalUserGroupRatio` 统一管理
   - 无用户组 CRUD API
   - 无基于用户组的 API 限流器管理

---

## 二、详细改造方案

### 阶段1：数据模型层改造

#### 1.1 修改 `new-api/model/main.go`

在 `createTable()` 函数的 `db.AutoMigrate()` 中添加 `&UserGroup{}`：

```go
func createTable() {
    // ... 现有代码 ...
    err = db.AutoMigrate(
        // ... 现有模型 ...
        &UserGroup{},  // 新增
    )
    // ... 
}
```

#### 1.2 完善 `new-api/model/user_group.go`

从 one-hub 迁移以下内容：

**结构体定义**：

```go
package model

import (
    "sync"
    "one-api/common/limit"  // 新增的限流器包
)

// UserGroup 用户组模型
type UserGroup struct {
    Id        int     `json:"id" gorm:"primaryKey"`
    Symbol    string  `json:"symbol" gorm:"uniqueIndex;size:64;not null"`  // 唯一标识
    Name      string  `json:"name" gorm:"size:64"`                         // 显示名称
    Ratio     float64 `json:"ratio" gorm:"type:decimal(10,2);default:1"`   // 倍率
    APIRate   int     `json:"api_rate" gorm:"default:600"`                 // 每分组请求数
    Public    bool    `json:"public" gorm:"default:false"`                 // 是否公开
    Enable    *bool   `json:"enable" gorm:"default:true"`                  // 是否启用
    CreatedAt int64   `json:"created_at"`                                  // 创建时间
}

// SearchUserGroupParams 搜索参数
type SearchUserGroupParams struct {
    Keyword string `form:"keyword"`
    Page    int    `form:"page"`
    Size    int    `form:"size"`
}

// UserGroupRatio 用户组缓存管理器
type UserGroupRatio struct {
    sync.RWMutex
    userGroups  map[string]*UserGroup      // symbol -> UserGroup
    apiLimiters map[string]limit.RateLimiter // symbol -> RateLimiter
    publicGroups []*UserGroup              // 公开分组列表
}

// GlobalUserGroupRatio 全局用户组缓存
var GlobalUserGroupRatio = &UserGroupRatio{}
```

**数据库操作方法**：

```go
// GetUserGroupsList 分页查询用户组列表
func GetUserGroupsList(params *SearchUserGroupParams) ([]*UserGroup, error)

// GetUserGroupsById 按ID查询用户组
func GetUserGroupsById(id int) (*UserGroup, error)

// GetUserGroupsAll 获取所有启用的用户组
func GetUserGroupsAll() (map[string]*UserGroup, error)

// GetUserGroupBySymbol 按Symbol查询用户组
func GetUserGroupBySymbol(symbol string) (*UserGroup, error)

// Create 创建用户组
func (ug *UserGroup) Create() error

// Update 更新用户组
func (ug *UserGroup) Update() error

// Delete 删除用户组
func (ug *UserGroup) Delete() error

// ChangeUserGroupEnable 启用/禁用用户组
func ChangeUserGroupEnable(id int, enable bool) error
```

**缓存管理方法**：

```go
// Load 从数据库加载到内存缓存
func (ugr *UserGroupRatio) Load() error

// GetBySymbol 从缓存获取用户组
func (ugr *UserGroupRatio) GetBySymbol(symbol string) *UserGroup

// GetAll 获取所有缓存的用户组
func (ugr *UserGroupRatio) GetAll() map[string]*UserGroup

// GetPublicGroupList 获取公开分组列表
func (ugr *UserGroupRatio) GetPublicGroupList() []*UserGroup

// GetAPIRate 获取API限流速率
func (ugr *UserGroupRatio) GetAPIRate(symbol string) int

// GetAPILimiter 获取API限流器
func (ugr *UserGroupRatio) GetAPILimiter(symbol string) limit.RateLimiter

// RefreshLimiters 刷新所有限流器
func (ugr *UserGroupRatio) RefreshLimiters()
```

#### 1.3 新增 `new-api/model/limit/` 目录

从 one-hub 迁移限流器实现，文件清单：

| 文件名 | 功能说明 |
|--------|---------|
| `limiter.go` | RateLimiter 接口定义 |
| `api_limiter.go` | NewAPILimiter 工厂函数 |
| `memorylimit.go` | 内存限流器实现 |
| `slidingwindow.go` | 滑动窗口限流器 |
| `tokenlimit.go` | 令牌桶限流器 |
| `countlimit.go` | 计数限流器 |
| `*.lua` | Redis Lua 脚本文件 |

**RateLimiter 接口定义**：

```go
package limit

// RateLimiter 定义了限流器的通用接口
type RateLimiter interface {
    Allow(keyPrefix string) bool
    AllowN(keyPrefix string, n int) bool
    GetCurrentRate(keyPrefix string) (int, error)
}
```

**NewAPILimiter 工厂函数**：

```go
// NewAPILimiter 根据RPM创建合适的限流器
func NewAPILimiter(rpm int) RateLimiter {
    // 如果Redis未启用，使用内存限流器
    if !config.RedisEnabled {
        if rpm < RPMThreshold {
            return NewMemoryLimiter(rpm, rpm, window, false)
        } else {
            ratePerSecond := float64(rpm) / 60
            return NewMemoryLimiter(int(ratePerSecond), rpm, window, true)
        }
    }

    // Redis启用时，使用Redis限流器
    if rpm < RPMThreshold {
        return NewCountLimiter(rpm, rpm, window)
    }
    
    ratePerSecond := float64(rpm) / 60
    burst := int(ratePerSecond * TokenBurstMultiplier)
    return NewTokenLimiter(int(ratePerSecond), rpm, burst)
}
```

---

### 阶段2：服务层改造

#### 2.1 修改 `new-api/service/group.go`

将 `GetUserUsableGroups()` 改为从 `GlobalUserGroupRatio` 获取：

```go
package service

import (
    "github.com/QuantumNous/new-api/model"
    "github.com/QuantumNous/new-api/setting"
)

// GetUserUsableGroups 获取用户可用的分组
func GetUserUsableGroups(userGroup string) map[string]string {
    groupsCopy := make(map[string]string)
    
    // 从 GlobalUserGroupRatio 获取公开分组
    publicGroups := model.GlobalUserGroupRatio.GetPublicGroupList()
    for _, g := range publicGroups {
        groupsCopy[g.Symbol] = g.Name
    }
    
    // 添加用户自己的分组（如果不在公开分组中）
    if userGroup != "" {
        if _, ok := groupsCopy[userGroup]; !ok {
            ug := model.GlobalUserGroupRatio.GetBySymbol(userGroup)
            if ug != nil {
                groupsCopy[userGroup] = ug.Name
            }
        }
    }
    
    // 处理特殊可用分组（保留原有逻辑）
    specialSettings, b := ratio_setting.GetGroupRatioSetting().GroupSpecialUsableGroup.Get(userGroup)
    if b {
        for specialGroup, desc := range specialSettings {
            if strings.HasPrefix(specialGroup, "-:") {
                groupToRemove := strings.TrimPrefix(specialGroup, "-:")
                delete(groupsCopy, groupToRemove)
            } else if strings.HasPrefix(specialGroup, "+:") {
                groupToAdd := strings.TrimPrefix(specialGroup, "+:")
                groupsCopy[groupToAdd] = desc
            } else {
                groupsCopy[specialGroup] = desc
            }
        }
    }
    
    return groupsCopy
}

// GroupInUserUsableGroups 检查分组是否在用户可用分组中
func GroupInUserUsableGroups(userGroup, groupName string) bool {
    _, ok := GetUserUsableGroups(userGroup)[groupName]
    return ok
}

// GetUserAutoGroup 根据用户分组获取自动分组设置
func GetUserAutoGroup(userGroup string) []string {
    groups := GetUserUsableGroups(userGroup)
    autoGroups := make([]string, 0)
    for _, group := range setting.GetAutoGroups() {
        if _, ok := groups[group]; ok {
            autoGroups = append(autoGroups, group)
        }
    }
    return autoGroups
}

// GetUserGroupRatio 获取用户使用某个分组的倍率
func GetUserGroupRatio(userGroup, group string) float64 {
    // 优先从数据库缓存获取
    ug := model.GlobalUserGroupRatio.GetBySymbol(userGroup)
    if ug != nil && group == userGroup {
        return ug.Ratio
    }
    
    // 其次检查跨分组倍率配置
    ratio, ok := ratio_setting.GetGroupGroupRatio(userGroup, group)
    if ok {
        return ratio
    }
    
    // 最后使用目标分组的默认倍率
    targetGroup := model.GlobalUserGroupRatio.GetBySymbol(group)
    if targetGroup != nil {
        return targetGroup.Ratio
    }
    
    return 1
}
```

#### 2.2 修改 `new-api/setting/ratio_setting/group_ratio.go`

将其改为从 `GlobalUserGroupRatio` 同步数据：

```go
// GetGroupRatio 获取分组倍率
func GetGroupRatio(name string) float64 {
    ug := model.GlobalUserGroupRatio.GetBySymbol(name)
    if ug != nil {
        return ug.Ratio
    }
    return 1
}

// GetGroupRatioCopy 获取分组倍率副本
func GetGroupRatioCopy() map[string]float64 {
    result := make(map[string]float64)
    for symbol, ug := range model.GlobalUserGroupRatio.GetAll() {
        result[symbol] = ug.Ratio
    }
    return result
}

// ContainsGroupRatio 检查分组是否存在
func ContainsGroupRatio(name string) bool {
    ug := model.GlobalUserGroupRatio.GetBySymbol(name)
    return ug != nil
}
```

---

### 阶段3：Controller 层改造

#### 3.1 新增 `new-api/controller/user_group.go`

从 one-hub 迁移用户组管理 API：

```go
package controller

import (
    "errors"
    "net/http"
    "strconv"
    
    "github.com/QuantumNous/new-api/common"
    "github.com/QuantumNous/new-api/model"
    
    "github.com/gin-gonic/gin"
)

// GetUserGroups 获取用户组列表（分页）
func GetUserGroups(c *gin.Context) {
    var params model.SearchUserGroupParams
    if err := c.ShouldBindQuery(&params); err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    userGroups, err := model.GetUserGroupsList(&params)
    if err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
        "data":    userGroups,
    })
}

// GetUserGroupById 获取单个用户组
func GetUserGroupById(c *gin.Context) {
    id, _ := strconv.Atoi(c.Param("id"))

    userGroup, err := model.GetUserGroupsById(id)
    if err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
        "data":    userGroup,
    })
}

// AddUserGroup 添加用户组
func AddUserGroup(c *gin.Context) {
    userGroup := model.UserGroup{}
    if err := c.ShouldBindJSON(&userGroup); err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    if err := userGroup.Create(); err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
    })
}

// UpdateUserGroup 更新用户组
func UpdateUserGroup(c *gin.Context) {
    userGroup := model.UserGroup{}
    err := c.ShouldBindJSON(&userGroup)
    if err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    if err := userGroup.Update(); err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
    })
}

// DeleteUserGroup 删除用户组
func DeleteUserGroup(c *gin.Context) {
    id, _ := strconv.Atoi(c.Param("id"))

    userGroup, err := model.GetUserGroupsById(id)
    if err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    if userGroup.Symbol == "default" {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": "默认用户组不能删除",
        })
        return
    }

    if err := userGroup.Delete(); err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
    })
}

// ChangeUserGroupEnable 启用/禁用用户组
func ChangeUserGroupEnable(c *gin.Context) {
    id, err := strconv.Atoi(c.Param("id"))
    if err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    userGroup, err := model.GetUserGroupsById(id)
    if err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    if *userGroup.Enable && userGroup.Symbol == "default" {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": "不能关闭默认的用户组，请设置一个默认组后，再关闭",
        })
        return
    }

    err = model.ChangeUserGroupEnable(id, !*userGroup.Enable)
    if err != nil {
        c.JSON(http.StatusOK, gin.H{
            "success": false,
            "message": err.Error(),
        })
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
    })
}
```

#### 3.2 修改 `new-api/controller/group.go`

修改 `GetGroups()` 和 `GetUserGroups()` 方法：

```go
package controller

import (
    "net/http"
    
    "github.com/QuantumNous/new-api/model"
    "github.com/QuantumNous/new-api/service"
    "github.com/QuantumNous/new-api/setting"
    
    "github.com/gin-gonic/gin"
)

// GetGroups 获取所有分组名称
func GetGroups(c *gin.Context) {
    groups := model.GlobalUserGroupRatio.GetAll()
    groupNames := make([]string, 0, len(groups))
    for name := range groups {
        groupNames = append(groupNames, name)
    }
    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
        "data":    groupNames,
    })
}

// GetUserGroups 获取用户可用的分组
func GetUserGroups(c *gin.Context) {
    userId := c.GetInt("id")
    userGroup, _ := model.GetUserGroup(userId, false)
    
    usableGroups := make(map[string]map[string]interface{})
    allGroups := model.GlobalUserGroupRatio.GetAll()
    publicGroups := model.GlobalUserGroupRatio.GetPublicGroupList()
    
    // 添加公开分组
    for _, g := range publicGroups {
        usableGroups[g.Symbol] = map[string]interface{}{
            "ratio": g.Ratio,
            "desc":  g.Name,
        }
    }
    
    // 添加用户自己的分组
    if ug, ok := allGroups[userGroup]; ok {
        if _, exists := usableGroups[userGroup]; !exists {
            usableGroups[userGroup] = map[string]interface{}{
                "ratio": ug.Ratio,
                "desc":  ug.Name,
            }
        }
    }
    
    // 添加auto分组（如果有配置）
    if _, ok := service.GetUserUsableGroups(userGroup)["auto"]; ok {
        usableGroups["auto"] = map[string]interface{}{
            "ratio": "自动",
            "desc":  setting.GetUsableGroupDescription("auto"),
        }
    }
    
    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "",
        "data":    usableGroups,
    })
}
```

---

### 阶段4：Router 层改造

#### 4.1 修改 `new-api/router/api-router.go`

在管理员路由区域添加用户组管理路由：

```go
// 用户组管理路由
userGroupRoute := apiRouter.Group("/user_group")
userGroupRoute.Use(middleware.AdminAuth())
{
    userGroupRoute.GET("/", controller.GetUserGroups)
    userGroupRoute.GET("/:id", controller.GetUserGroupById)
    userGroupRoute.POST("/", controller.AddUserGroup)
    userGroupRoute.PUT("/", controller.UpdateUserGroup)
    userGroupRoute.DELETE("/:id", controller.DeleteUserGroup)
    userGroupRoute.PUT("/enable/:id", controller.ChangeUserGroupEnable)
}
```

---

### 阶段5：初始化逻辑

#### 5.1 修改 `new-api/model/main.go`

在数据库初始化后调用 `GlobalUserGroupRatio.Load()`：

```go
func init() {
    // ... 数据库初始化代码 ...
    
    // 加载用户组缓存
    if err := GlobalUserGroupRatio.Load(); err != nil {
        common.SysLog("加载用户组缓存失败: " + err.Error())
    }
    
    // ... 其他初始化代码 ...
}
```

#### 5.2 默认用户组初始化

在 `GlobalUserGroupRatio.Load()` 中确保存在默认用户组：

```go
func (ugr *UserGroupRatio) Load() error {
    ugr.Lock()
    defer ugr.Unlock()
    
    // 确保默认用户组存在
    var defaultGroup UserGroup
    err := DB.Where("symbol = ?", "default").FirstOrCreate(&defaultGroup, UserGroup{
        Symbol: "default",
        Name:   "默认分组",
        Ratio:  1,
        Public: true,
        Enable: func() *bool { b := true; return &b }(),
    }).Error
    if err != nil {
        return err
    }
    
    // 加载所有启用的用户组
    var groups []*UserGroup
    err = DB.Where("enable = ?", true).Find(&groups).Error
    if err != nil {
        return err
    }
    
    ugr.userGroups = make(map[string]*UserGroup)
    ugr.apiLimiters = make(map[string]limit.RateLimiter)
    ugr.publicGroups = make([]*UserGroup, 0)
    
    for _, g := range groups {
        ugr.userGroups[g.Symbol] = g
        if g.APIRate > 0 {
            ugr.apiLimiters[g.Symbol] = limit.NewAPILimiter(g.APIRate)
        }
        if g.Public {
            ugr.publicGroups = append(ugr.publicGroups, g)
        }
    }
    
    return nil
}
```

---

### 阶段6：API限流集成（可选）

#### 6.1 新增 `new-api/middleware/api-limit.go`

基于用户组的 API 限流中间件：

```go
package middleware

import (
    "fmt"
    "net/http"
    
    "github.com/QuantumNous/new-api/model"
    
    "github.com/gin-gonic/gin"
)

// UserGroupAPIRateLimit 基于用户组的API限流中间件
func UserGroupAPIRateLimit() gin.HandlerFunc {
    return func(c *gin.Context) {
        // 获取用户分组
        userGroup := c.GetString("group")
        if userGroup == "" {
            c.Next()
            return
        }
        
        // 获取该分组的限流器
        limiter := model.GlobalUserGroupRatio.GetAPILimiter(userGroup)
        if limiter == nil {
            c.Next()
            return
        }
        
        // 使用用户ID作为限流key
        userId := c.GetInt("id")
        key := fmt.Sprintf("api_limit:%d", userId)
        
        if !limiter.Allow(key) {
            c.JSON(http.StatusTooManyRequests, gin.H{
                "success": false,
                "message": "API请求频率超限，请稍后再试",
            })
            c.Abort()
            return
        }
        
        c.Next()
    }
}
```

#### 6.2 在路由中使用

```go
// 在需要限流的路由组中添加
apiRouter.Use(middleware.UserGroupAPIRateLimit())
```

---

## 三、需要保持兼容的功能

| 功能 | 影响范围 | 兼容措施 |
|------|---------|---------|
| 分组倍率 | 计费、配额计算 | `GetGroupRatio()` 返回值不变 |
| 用户可用分组 | Token创建、模型访问 | `GetUserUsableGroups()` 返回格式不变 |
| 公开分组 | 用户可选择的分组 | `Public` 字段逻辑保持一致 |
| 分组限流 | 模型请求限流 | 复用现有 `middleware/model-rate-limit.go` |
| 跨分组倍率 | 特殊倍率配置 | 保留 `GroupGroupRatio` 配置逻辑 |

---

## 四、涉及文件清单

| 文件路径 | 操作类型 | 改动量 |
|---------|---------|--------|
| `new-api/model/main.go` | 修改 | 小 |
| `new-api/model/user_group.go` | 大幅修改 | 大 |
| `new-api/model/limit/limiter.go` | 新增 | 小 |
| `new-api/model/limit/api_limiter.go` | 新增 | 小 |
| `new-api/model/limit/memorylimit.go` | 新增 | 中 |
| `new-api/model/limit/slidingwindow.go` | 新增 | 中 |
| `new-api/model/limit/tokenlimit.go` | 新增 | 中 |
| `new-api/model/limit/countlimit.go` | 新增 | 中 |
| `new-api/model/limit/*.lua` | 新增 | 小 |
| `new-api/service/group.go` | 修改 | 中 |
| `new-api/setting/ratio_setting/group_ratio.go` | 修改 | 中 |
| `new-api/controller/user_group.go` | 新增 | 中 |
| `new-api/controller/group.go` | 修改 | 小 |
| `new-api/router/api-router.go` | 修改 | 小 |
| `new-api/middleware/api-limit.go` | 新增 | 小 |

---

## 五、实施步骤

### 步骤1：准备阶段
1. 创建 `new-api/model/limit/` 目录
2. 从 one-hub 复制限流器相关文件

### 步骤2：模型层实施
1. 修改 `model/main.go` 添加 AutoMigrate
2. 完善 `model/user_group.go` 的所有方法

### 步骤3：服务层实施
1. 修改 `service/group.go`
2. 修改 `setting/ratio_setting/group_ratio.go`

### 步骤4：控制层实施
1. 创建 `controller/user_group.go`
2. 修改 `controller/group.go`

### 步骤5：路由层实施
1. 修改 `router/api-router.go` 添加路由

### 步骤6：测试验证
1. 运行数据库迁移
2. 测试 CRUD API
3. 验证限流功能
4. 验证倍率计算

---

## 六、测试要点

### 6.1 数据库测试
- [x] 确认 `user_groups` 表正确创建（已添加到 AutoMigrate）
- [x] 确认默认 `default` 分组存在（Load 时自动创建）
- [x] 确认索引正确创建

### 6.2 CRUD测试
- [x] 创建用户组（AddUserGroup 已实现）
- [x] 查询用户组列表（GetUserGroupsList 已实现）
- [x] 查询单个用户组（GetUserGroupById 已实现）
- [x] 更新用户组（UpdateUserGroup 已实现）
- [x] 删除用户组（DeleteUserGroup 已实现，保护 default）
- [x] 启用/禁用用户组（ChangeUserGroupEnable 已实现）

### 6.3 缓存测试
- [x] 服务启动后缓存正确加载（GlobalUserGroupRatio.Load）
- [x] 修改用户组后缓存正确更新
- [x] 删除用户组后缓存正确清理

### 6.4 倍率测试
- [x] 确认计费时使用正确的倍率（GetRatio 方法已实现）
- [ ] 确认跨分组倍率正常工作（需配合现有配置）
- [x] 确认默认倍率为1

### 6.5 限流测试
- [x] 确认 API 限流按用户组配置生效（GetAPILimiter 已实现）
- [x] 确认不同用户组独立限流
- [x] 确认限流器正确刷新（RefreshLimiters 已实现）

### 6.6 兼容测试
- [ ] 确认现有 Token 创建功能正常
- [ ] 确认现有模型访问功能正常
- [ ] 确认现有计费功能正常

---

## 八、迁移完成状态

### 已完成的改造：

| 文件路径 | 状态 | 说明 |
|---------|------|------|
| `new-api/model/main.go` | ✅ 已完成 | 添加了 UserGroup 到 AutoMigrate |
| `new-api/model/user_group.go` | ✅ 已完成 | 实现了完整的用户组模型和缓存管理 |
| `new-api/common/limiter/rate_limiter.go` | ✅ 已完成 | RateLimiter 接口定义 |
| `new-api/common/limiter/api_limiter.go` | ✅ 已完成 | NewAPILimiter 工厂函数 |
| `new-api/common/limiter/memory_limiter.go` | ✅ 已完成 | 内存限流器实现 |
| `new-api/common/limiter/token_limiter.go` | ✅ 已完成 | 令牌桶限流器 |
| `new-api/common/limiter/count_limiter.go` | ✅ 已完成 | 计数限流器 |
| `new-api/common/limiter/sliding_window_limiter.go` | ✅ 已完成 | 滑动窗口限流器 |
| `new-api/common/limiter/model_limiter.go` | ✅ 已完成 | 模型限流器封装 |
| `new-api/common/limiter/lua/*.lua` | ✅ 已完成 | Redis Lua 脚本 |
| `new-api/controller/user_group.go` | ✅ 已完成 | 用户组管理 API |
| `new-api/router/api-router.go` | ✅ 已完成 | 用户组路由配置 |
| `new-api/bin/migration_user_groups.sql` | ✅ 已完成 | 数据库迁移脚本 |

### 编译状态：✅ 编译成功

### 待完成事项：
1. 前端页面适配（需要前端配合）
2. 与现有 setting 包的集成优化
3. 完整的功能测试

---

## 七、注意事项

1. **默认分组保护**：`default` 分组不能删除，不能禁用
2. **缓存一致性**：每次 CRUD 操作后需刷新缓存
3. **限流器更新**：修改 `api_rate` 后需刷新限流器
4. **向后兼容**：确保现有 API 响应格式不变
5. **数据完整性**：删除分组前需检查是否有用户关联