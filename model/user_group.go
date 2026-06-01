package model

import (
	"fmt"
	"sync"

	"github.com/QuantumNous/new-api/common"
	"github.com/QuantumNous/new-api/common/limiter"
	"github.com/QuantumNous/new-api/setting"
	"github.com/go-redis/redis/v8"
)

// UserGroupCacheKey 用户组缓存键模板
const UserGroupCacheKey = "user_group:%d"

// GetUserGroupCacheKey 获取用户组的缓存键
func GetUserGroupCacheKey(userId int) string {
	return fmt.Sprintf(UserGroupCacheKey, userId)
}

type UserGroup struct {
	Id             int     `json:"id"`
	Symbol         string  `json:"symbol" gorm:"type:varchar(128);uniqueIndex"` // 扩展长度以支持 tenant_dept_project 格式
	Name           string  `json:"name" gorm:"type:varchar(100)"`
	Ratio          float64 `json:"ratio" gorm:"type:decimal(10,2); default:1"`      // 倍率
	APIRate        int     `json:"api_rate" gorm:"default:1000"`                    // 每分组允许的请求数（已废弃，使用 APIRateTotal 和 APIRateSuccess）
	APIRateTotal   int     `json:"api_rate_total" gorm:"default:0"`                 // 每周期最多请求次数（包括失败请求，0代表不限制）
	APIRateSuccess int     `json:"api_rate_success" gorm:"default:1000"`            // 每周期最多请求完成次数（只包括成功的）
	Public         bool    `json:"public" form:"public" gorm:"default:false"`       // 是否为公开分组，如果是，则可以被用户在令牌中选择
	Promotion      bool    `json:"promotion" form:"promotion" gorm:"default:false"` // 是否是自动升级用户组， 如果是则用户充值金额满足条件自动升级
	Min            int     `json:"min" form:"min" gorm:"default:0"`                 // 晋级条件最小值
	Max            int     `json:"max" form:"max" gorm:"default:0"`                 // 晋级条件最大值
	Enable         *bool   `json:"enable" form:"enable" gorm:"default:true"`        // 是否启用
	// Cloud-Web 集成字段
	TenantId    string `json:"tenant_id" gorm:"type:varchar(12);index;default:''"`    // 租户ID
	DeptId      string `json:"dept_id" gorm:"type:varchar(64);index;default:''"`      // 部门ID
	ProjectCode string `json:"project_code" gorm:"type:varchar(64);index;default:''"` // 原始项目代码
	ExternalId  int64  `json:"external_id" gorm:"index;default:0"`                    // cloud-web 项目ID
	Source      string `json:"source" gorm:"type:varchar(20);default:'local'"`        // 来源: local/synced
}

type SearchUserGroupParams struct {
	UserGroup
	PaginationParams
}

var allowedUserGroupOrderFields = map[string]bool{
	"id":     true,
	"name":   true,
	"enable": true,
}

func GetUserGroupsList(params *SearchUserGroupParams) (*DataResult[UserGroup], error) {
	var userGroups []*UserGroup
	db := DB

	if params.Name != "" {
		db = db.Where("name LIKE ?", params.Name+"%")
	}

	if params.Enable != nil {
		db = db.Where("enable = ?", *params.Enable)
	}

	return PaginateAndOrder(db, &params.PaginationParams, &userGroups, allowedUserGroupOrderFields)
}

func GetUserGroupsById(id int) (*UserGroup, error) {
	var userGroup UserGroup
	err := DB.Where("id = ?", id).First(&userGroup).Error
	return &userGroup, err
}

func GetUserGroupsAll(isPublic bool) ([]*UserGroup, error) {
	var userGroups []*UserGroup

	db := DB.Where("enable = ?", true)
	if isPublic {
		db = db.Where("public = ?", true)
	}

	err := db.Find(&userGroups).Error
	return userGroups, err
}

func (c *UserGroup) Create() error {
	err := DB.Create(c).Error
	if err == nil {
		GlobalUserGroupRatio.Load()
	}
	return err
}

func (c *UserGroup) Update() error {
	err := DB.Select("name", "ratio", "public", "api_rate", "api_rate_total", "api_rate_success", "promotion", "min", "max").Updates(c).Error
	if err == nil {
		GlobalUserGroupRatio.Load()
	}

	return err
}

func (c *UserGroup) Delete() error {
	err := DB.Delete(c).Error

	if err == nil {
		GlobalUserGroupRatio.Load()
	}
	return err
}

func ChangeUserGroupEnable(id int, enable bool) error {
	err := DB.Model(&UserGroup{}).Where("id = ?", id).Update("enable", enable).Error
	if err == nil {
		GlobalUserGroupRatio.Load()
	}
	return err
}

// GetUserGroupByExternalId 根据外部ID获取用户组（cloud-web项目同步）
func GetUserGroupByExternalId(externalId int64) (*UserGroup, error) {
	var userGroup UserGroup
	err := DB.Where("external_id = ?", externalId).First(&userGroup).Error
	if err != nil {
		return nil, err
	}
	return &userGroup, nil
}

// GetUserGroupByTenantAndProjectCode 根据租户ID和项目代码获取用户组
func GetUserGroupByTenantAndProjectCode(tenantId, projectCode string) (*UserGroup, error) {
	var userGroup UserGroup
	err := DB.Where("tenant_id = ? AND project_code = ?", tenantId, projectCode).First(&userGroup).Error
	if err != nil {
		return nil, err
	}
	return &userGroup, nil
}

// SyncUserGroup 同步用户组（来自cloud-web项目）
func SyncUserGroup(externalId int64, tenantId, deptId, projectCode, name string, ratio float64, apiRate int) (*UserGroup, error) {
	var userGroup *UserGroup
	var err error

	// Symbol 直接使用 projectCode
	symbol := projectCode

	// 先尝试按外部ID查找
	userGroup, err = GetUserGroupByExternalId(externalId)
	if err != nil && err.Error() != "record not found" {
		return nil, err
	}

	if userGroup == nil || userGroup.Id == 0 {
		// 新建用户组
		enable := true
		userGroup = &UserGroup{
			Symbol:      symbol,
			Name:        name,
			Ratio:       ratio,
			APIRate:     apiRate,
			Public:      false, // 同步的用户组默认不公开，让管理员选择是否公开
			Promotion:   false,
			Min:         0,
			Max:         0,
			Enable:      &enable,
			TenantId:    tenantId,
			DeptId:      deptId,
			ProjectCode: projectCode,
			ExternalId:  externalId,
			Source:      "synced",
		}
		err = userGroup.Create()
	} else {
		// 更新用户组
		userGroup.Symbol = symbol
		userGroup.Name = name
		userGroup.TenantId = tenantId
		userGroup.DeptId = deptId
		userGroup.ProjectCode = projectCode
		if ratio > 0 {
			userGroup.Ratio = ratio
		}
		if apiRate > 0 {
			userGroup.APIRate = apiRate
		}
		err = DB.Model(userGroup).Select("symbol", "name", "tenant_id", "dept_id", "project_code", "ratio", "api_rate").Updates(userGroup).Error
		if err == nil {
			GlobalUserGroupRatio.Load()
		}
	}

	return userGroup, err
}

// BatchSyncUserGroups 批量同步用户组（来自cloud-web项目列表）
// 返回: (创建数量, 更新数量, 错误)
func BatchSyncUserGroups(tenantId, vdcCode string, projects []map[string]interface{}) (int, int, error) {
	created := 0
	updated := 0

	for _, project := range projects {
		externalId, ok1 := project["external_id"].(float64)
		projectCode, ok2 := project["project_code"].(string)
		projectName, ok3 := project["project_name"].(string)

		if !ok1 || !ok2 || !ok3 {
			continue
		}

		// 检查是否已存在
		existing, err := GetUserGroupByExternalId(int64(externalId))
		if err != nil && err.Error() != "record not found" {
			return created, updated, err
		}

		if existing == nil || existing.Id == 0 {
			// 创建新用户组
			enable := true
			userGroup := &UserGroup{
				Symbol:      projectCode,
				Name:        projectName,
				Ratio:       1.0,   // 默认倍率
				APIRate:     1000,  // 默认限速
				Public:      false, // 同步的用户组默认不公开
				Promotion:   false,
				Min:         0,
				Max:         0,
				Enable:      &enable,
				TenantId:    tenantId,
				DeptId:      vdcCode,
				ProjectCode: projectCode,
				ExternalId:  int64(externalId),
				Source:      "synced",
			}
			err = userGroup.Create()
			if err != nil {
				return created, updated, err
			}
			created++
		} else {
			// 更新现有用户组
			existing.Symbol = projectCode
			existing.Name = projectName
			existing.TenantId = tenantId
			existing.DeptId = vdcCode
			existing.ProjectCode = projectCode
			err = DB.Model(existing).Select("symbol", "name", "tenant_id", "dept_id", "project_code").Updates(existing).Error
			if err != nil {
				return created, updated, err
			}
			updated++
		}
	}

	// 重新加载缓存
	GlobalUserGroupRatio.Load()
	return created, updated, nil
}

// BatchSyncUserGroupsWithVdcCode 批量同步用户组（vdc_code 在每个 project 中）
// 返回: (创建数量, 更新数量, 错误)
func BatchSyncUserGroupsWithVdcCode(tenantId string, vdcCodes map[int64]string, projects []map[string]interface{}) (int, int, error) {
	created := 0
	updated := 0

	for _, project := range projects {
		externalId, ok1 := project["external_id"].(float64)
		projectCode, ok2 := project["project_code"].(string)
		projectName, ok3 := project["project_name"].(string)

		if !ok1 || !ok2 || !ok3 {
			continue
		}

		vdcCode := vdcCodes[int64(externalId)]

		// 检查是否已存在
		existing, err := GetUserGroupByExternalId(int64(externalId))
		if err != nil && err.Error() != "record not found" {
			return created, updated, err
		}

		if existing == nil || existing.Id == 0 {
			// 创建新用户组
			enable := true
			userGroup := &UserGroup{
				Symbol:      projectCode,
				Name:        projectName,
				Ratio:       1.0,
				APIRate:     1000,
				Public:      false,
				Promotion:   false,
				Min:         0,
				Max:         0,
				Enable:      &enable,
				TenantId:    tenantId,
				DeptId:      vdcCode,
				ProjectCode: projectCode,
				ExternalId:  int64(externalId),
				Source:      "synced",
			}
			err = userGroup.Create()
			if err != nil {
				return created, updated, err
			}
			created++
		} else {
			// 更新现有用户组
			existing.Symbol = projectCode
			existing.Name = projectName
			existing.TenantId = tenantId
			existing.DeptId = vdcCode
			existing.ProjectCode = projectCode
			err = DB.Model(existing).Select("symbol", "name", "tenant_id", "dept_id", "project_code").Updates(existing).Error
			if err != nil {
				return created, updated, err
			}
			updated++
		}
	}

	// 重新加载缓存
	GlobalUserGroupRatio.Load()
	return created, updated, nil
}

// DeleteUserGroupsNotInExternalIds 删除不在新列表中的同步来源用户组
// 仅删除 tenant_id 匹配且 source='synced' 的用户组，且 external_id 不在 newExternalIds 中的记录
func DeleteUserGroupsNotInExternalIds(tenantId string, newExternalIds []int64) (int64, error) {
	if tenantId == "" {
		return 0, nil
	}
	// 如果 newExternalIds 为空，删除该租户下所有 synced 用户组
	if len(newExternalIds) == 0 {
		result := DB.Where("tenant_id = ? AND source = ?", tenantId, "synced").Delete(&UserGroup{})
		return result.RowsAffected, result.Error
	}
	result := DB.Where("tenant_id = ? AND source = ? AND external_id NOT IN ?", tenantId, "synced", newExternalIds).Delete(&UserGroup{})
	return result.RowsAffected, result.Error
}

// GetUserGroupsByTenantAndExternalUserId 根据租户ID和外部用户ID获取用户所属的所有用户组
// 通过查询该租户下所有 synced 的用户组，因为用户可能属于多个项目
func GetUserGroupsByTenantAndExternalUserId(tenantId, externalUserId string) ([]*UserGroup, error) {
	var userGroups []*UserGroup
	// 查询该租户下的所有 synced 用户组
	err := DB.Where("tenant_id = ? AND source = ?", tenantId, "synced").Find(&userGroups).Error
	return userGroups, err
}

// DeleteUserGroupByExternalId 根据外部ID删除用户组
func DeleteUserGroupByExternalId(externalId int64) error {
	var userGroup UserGroup
	err := DB.Where("external_id = ?", externalId).First(&userGroup).Error
	if err != nil {
		return err
	}
	return userGroup.Delete()
}

// GetUserGroupsByTenantId 根据租户ID获取所有用户组
func GetUserGroupsByTenantId(tenantId string) ([]*UserGroup, error) {
	var userGroups []*UserGroup
	err := DB.Where("tenant_id = ?", tenantId).Find(&userGroups).Error
	return userGroups, err
}

// UserGroupRatio 用户组倍率管理结构
type UserGroupRatio struct {
	sync.RWMutex
	UserGroup   map[string]*UserGroup
	APILimiter  map[string]limiter.RateLimiter
	PublicGroup []string
}

var GlobalUserGroupRatio = UserGroupRatio{}

func init() {
	// 注册回调函数到 setting 包，避免循环依赖
	// 这些回调函数允许 setting 包从数据库获取用户组数据
	setting.RegisterDBUserGroupProviders(
		// 公开用户组列表提供者
		func() map[string]string {
			result := make(map[string]string)
			groups := GlobalUserGroupRatio.GetPublicGroupList()
			for _, symbol := range groups {
				if ug := GlobalUserGroupRatio.GetBySymbol(symbol); ug != nil {
					result[symbol] = ug.Name
				}
			}
			return result
		},
		// 用户组名称提供者
		func(symbol string) string {
			if ug := GlobalUserGroupRatio.GetBySymbol(symbol); ug != nil {
				return ug.Name
			}
			return ""
		},
		// 用户组倍率提供者
		func(symbol string) float64 {
			if ug := GlobalUserGroupRatio.GetBySymbol(symbol); ug != nil {
				return ug.Ratio
			}
			return 0
		},
		// 所有用户组倍率提供者
		func() map[string]float64 {
			result := make(map[string]float64)
			groups := GlobalUserGroupRatio.GetAll()
			for symbol, ug := range groups {
				result[symbol] = ug.Ratio
			}
			return result
		},
		// 用户组存在检查器
		func(symbol string) bool {
			return GlobalUserGroupRatio.GetBySymbol(symbol) != nil
		},
	)

	// 注册用户组限速相关的回调函数
	setting.RegisterDBUserGroupRateProviders(
		// 获取指定用户组的限速配置
		func(symbol string) (total, success int, found bool) {
			userGroup := GlobalUserGroupRatio.GetBySymbol(symbol)
			if userGroup == nil {
				return 0, 0, false
			}
			return userGroup.APIRateTotal, userGroup.APIRateSuccess, true
		},
		// 获取所有用户组的限速配置
		func() map[string][2]int {
			result := make(map[string][2]int)
			groups := GlobalUserGroupRatio.GetAll()
			for symbol, ug := range groups {
				result[symbol] = [2]int{ug.APIRateTotal, ug.APIRateSuccess}
			}
			return result
		},
		// 更新用户组限速配置
		func(symbol string, total, success int) error {
			userGroup := GlobalUserGroupRatio.GetBySymbol(symbol)
			if userGroup == nil {
				return fmt.Errorf("user group %s not found", symbol)
			}
			userGroup.APIRateTotal = total
			userGroup.APIRateSuccess = success
			// 只更新限速相关字段
			return DB.Model(userGroup).Select("api_rate_total", "api_rate_success").Updates(userGroup).Error
		},
		// 重新加载用户组数据
		func() {
			GlobalUserGroupRatio.Load()
		},
	)

	// 注册用户限速提供者
	setting.RegisterDBUserRateProvider(
		// 获取指定用户的限速配置
		func(userId int) (total, success int, found bool) {
			user, err := GetUserById(userId, false)
			if err != nil {
				return 0, 0, false
			}
			hasLimit, totalRate, successRate := user.GetUserRateLimit()
			return totalRate, successRate, hasLimit
		},
	)
}

// Load 加载所有用户组数据到内存
func (cgrm *UserGroupRatio) Load() {
	userGroups, err := GetUserGroupsAll(false)
	if err != nil {
		return
	}

	newUserGroups := make(map[string]*UserGroup, len(userGroups))
	newAPILimiter := make(map[string]limiter.RateLimiter, len(userGroups))
	publicGroup := make([]string, 0)

	for _, userGroup := range userGroups {
		newUserGroups[userGroup.Symbol] = userGroup
		// 获取 Redis 客户端
		var client *redis.Client
		if common.RedisEnabled && common.RDB != nil {
			client = common.RDB
		}
		newAPILimiter[userGroup.Symbol] = limiter.NewAPILimiter(client, userGroup.APIRate)
		if userGroup.Public {
			publicGroup = append(publicGroup, userGroup.Symbol)
		}
	}

	cgrm.Lock()
	defer cgrm.Unlock()

	cgrm.UserGroup = newUserGroups
	cgrm.APILimiter = newAPILimiter
	cgrm.PublicGroup = publicGroup
}

// GetBySymbol 根据 Symbol 获取用户组
func (cgrm *UserGroupRatio) GetBySymbol(symbol string) *UserGroup {
	cgrm.RLock()
	defer cgrm.RUnlock()

	if symbol == "" {
		return nil
	}

	userGroupRatio, ok := cgrm.UserGroup[symbol]
	if !ok {
		return nil
	}

	return userGroupRatio
}

// GetByTokenUserGroup 根据令牌用户组和用户所属用户组获取用户组
func (cgrm *UserGroupRatio) GetByTokenUserGroup(tokenGroup, userGroup string) *UserGroup {
	if tokenGroup != "" {
		return cgrm.GetBySymbol(tokenGroup)
	}

	return cgrm.GetBySymbol(userGroup)
}

// GetAll 获取所有用户组
func (cgrm *UserGroupRatio) GetAll() map[string]*UserGroup {
	cgrm.RLock()
	defer cgrm.RUnlock()

	return cgrm.UserGroup
}

// GetAPIRate 获取用户组的 API 速率限制
func (cgrm *UserGroupRatio) GetAPIRate(symbol string) int {
	userGroup := cgrm.GetBySymbol(symbol)
	if userGroup == nil {
		return 0
	}

	return userGroup.APIRate
}

// GetPublicGroupList 获取公开用户组列表
func (cgrm *UserGroupRatio) GetPublicGroupList() []string {
	cgrm.RLock()
	defer cgrm.RUnlock()

	return cgrm.PublicGroup
}

// GetAPILimiter 获取用户组的 API 限流器
func (cgrm *UserGroupRatio) GetAPILimiter(symbol string) limiter.RateLimiter {
	cgrm.RLock()
	defer cgrm.RUnlock()

	limiter, ok := cgrm.APILimiter[symbol]
	if !ok {
		return nil
	}

	return limiter
}

// CheckAndUpgradeUserGroup 检查用户的累计充值金额是否在晋级范围内，并升级用户组
// 累计充值金额 = Quota + UsedQuota + rechargeAmount
func CheckAndUpgradeUserGroup(userId int, rechargeAmount int) error {
	// 获取用户当前的额度和已使用额度
	user := &User{}
	err := DB.Where("id = ?", userId).First(user).Error
	if err != nil {
		return err
	}

	// 计算累计充值金额
	cumulativeAmount := user.Quota + user.UsedQuota + rechargeAmount

	// 获取所有启用晋级的用户组
	var promotionGroups []*UserGroup
	err = DB.Where("promotion = ? AND enable = ?", true, true).Find(&promotionGroups).Error
	if err != nil {
		return err
	}

	// 查找匹配的用户组 (min <= cumulativeAmount < max)
	var targetGroup *UserGroup
	for _, group := range promotionGroups {
		var minQuota = float64(group.Min) * common.QuotaPerUnit
		var maxQuota = float64(group.Max) * common.QuotaPerUnit
		if float64(cumulativeAmount) >= minQuota && (group.Max == 0 || float64(cumulativeAmount) < maxQuota) {
			// 如果有多个用户组匹配，选择 min 值更高的
			if targetGroup == nil || group.Min > targetGroup.Min {
				targetGroup = group
			}
		}
	}

	// 如果找到匹配的用户组，升级用户
	if targetGroup != nil && targetGroup.Symbol != user.Group {
		// 更新用户的用户组
		err = DB.Model(&User{}).Where("id = ?", userId).Update("group", targetGroup.Symbol).Error
		if err != nil {
			return err
		}

		// 如果 Redis 启用，删除缓存
		if common.RedisEnabled {
			common.RedisDel(fmt.Sprintf(UserGroupCacheKey, userId))
		}
	}

	return nil
}

// GetSymbol 获取用户组的 Symbol
// 如果 Symbol 为空，根据 Source 生成默认 Symbol
func (group *UserGroup) GetSymbol() string {
	if group.Symbol != "" {
		return group.Symbol
	}
	// 如果 Symbol 为空，根据 Source 生成默认 Symbol
	if group.Source == "dcloud" && group.ProjectCode != "" {
		return fmt.Sprintf("project_%s", group.ProjectCode)
	}
	return group.Symbol
}
