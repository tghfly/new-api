package setting

import (
	"encoding/json"
	"fmt"
	"math"
	"sync"

	"github.com/QuantumNous/new-api/common"
)

var ModelRequestRateLimitEnabled = false
var ModelRequestRateLimitDurationMinutes = 1
var ModelRequestRateLimitCount = 0
var ModelRequestRateLimitSuccessCount = 1000
var ModelRequestRateLimitGroup = map[string][2]int{}
var ModelRequestRateLimitMutex sync.RWMutex

// DBUserGroupRateProvider 数据库用户组限速提供者函数类型
type DBUserGroupRateProvider func(symbol string) (total, success int, found bool)
type DBUserGroupRateMapProvider func() map[string][2]int
type DBUserGroupRateUpdater func(symbol string, total, success int) error
type DBUserGroupRateReloader func()

// 数据库用户组限速回调函数（由 model 包注册）
var (
	dbUserGroupRateProvider    DBUserGroupRateProvider
	dbUserGroupRateMapProvider DBUserGroupRateMapProvider
	dbUserGroupRateUpdater     DBUserGroupRateUpdater
	dbUserGroupRateReloader    DBUserGroupRateReloader
)

// RegisterDBUserGroupRateProviders 注册数据库用户组限速回调函数
func RegisterDBUserGroupRateProviders(
	provider DBUserGroupRateProvider,
	mapProvider DBUserGroupRateMapProvider,
	updater DBUserGroupRateUpdater,
	reloader DBUserGroupRateReloader,
) {
	dbUserGroupRateProvider = provider
	dbUserGroupRateMapProvider = mapProvider
	dbUserGroupRateUpdater = updater
	dbUserGroupRateReloader = reloader
}

func ModelRequestRateLimitGroup2JSONString() string {
	// 优先从数据库获取（通过回调）
	if dbUserGroupRateMapProvider != nil {
		dbLimits := dbUserGroupRateMapProvider()
		if len(dbLimits) > 0 {
			jsonBytes, err := json.Marshal(dbLimits)
			if err != nil {
				common.SysLog("error marshalling group rate limits from db: " + err.Error())
				return "{}"
			}
			return string(jsonBytes)
		}
	}

	// 回退到内存配置
	ModelRequestRateLimitMutex.RLock()
	defer ModelRequestRateLimitMutex.RUnlock()

	jsonBytes, err := json.Marshal(ModelRequestRateLimitGroup)
	if err != nil {
		common.SysLog("error marshalling group rate limits: " + err.Error())
		return "{}"
	}
	return string(jsonBytes)
}

func UpdateModelRequestRateLimitGroupByJSONString(jsonStr string) error {
	checkModelRequestRateLimitGroup := make(map[string][2]int)
	err := json.Unmarshal([]byte(jsonStr), &checkModelRequestRateLimitGroup)
	if err != nil {
		return err
	}
	if err := CheckModelRequestRateLimitGroup(jsonStr); err != nil {
		return err
	}

	// 同步更新到数据库（通过回调）
	if dbUserGroupRateUpdater != nil {
		for groupSymbol, limits := range checkModelRequestRateLimitGroup {
			err := dbUserGroupRateUpdater(groupSymbol, limits[0], limits[1])
			if err != nil {
				common.SysLog(fmt.Sprintf("error updating user group %s rate limit: %v", groupSymbol, err))
			}
		}
	}

	// 重新加载用户组数据
	if dbUserGroupRateReloader != nil {
		dbUserGroupRateReloader()
	}

	// 同时更新内存配置
	ModelRequestRateLimitMutex.Lock()
	defer ModelRequestRateLimitMutex.Unlock()
	ModelRequestRateLimitGroup = checkModelRequestRateLimitGroup

	return nil
}

func GetGroupRateLimit(group string) (totalCount, successCount int, found bool) {
	// 优先从数据库获取（通过回调）
	if dbUserGroupRateProvider != nil {
		return dbUserGroupRateProvider(group)
	}

	// 回退到内存配置
	ModelRequestRateLimitMutex.RLock()
	defer ModelRequestRateLimitMutex.RUnlock()

	limits, ok := ModelRequestRateLimitGroup[group]
	if !ok {
		return 0, 0, false
	}
	return limits[0], limits[1], true
}

func CheckModelRequestRateLimitGroup(jsonStr string) error {
	checkModelRequestRateLimitGroup := make(map[string][2]int)
	err := json.Unmarshal([]byte(jsonStr), &checkModelRequestRateLimitGroup)
	if err != nil {
		return err
	}
	for group, limits := range checkModelRequestRateLimitGroup {
		if limits[0] < 0 || limits[1] < 1 {
			return fmt.Errorf("group %s has negative rate limit values: [%d, %d]", group, limits[0], limits[1])
		}
		if limits[0] > math.MaxInt32 || limits[1] > math.MaxInt32 {
			return fmt.Errorf("group %s [%d, %d] has max rate limits value 2147483647", group, limits[0], limits[1])
		}
	}

	return nil
}

// DBUserRateProvider 数据库用户限速提供者函数类型
type DBUserRateProvider func(userId int) (total, success int, found bool)

// 数据库用户限速回调函数（由 model 包注册）
var dbUserRateProvider DBUserRateProvider

// RegisterDBUserRateProvider 注册数据库用户限速回调函数
func RegisterDBUserRateProvider(provider DBUserRateProvider) {
	dbUserRateProvider = provider
}

// GetUserRateLimit 获取用户的限速配置
// 参数: userId - 用户ID, group - 用户所属分组
// 返回值: totalCount, successCount, useUserLimit bool
// useUserLimit 为 true 表示使用了用户级别限速
func GetUserRateLimit(userId int, group string) (totalCount, successCount int, useUserLimit bool) {
	// 优先从数据库获取用户限速（通过回调）
	if dbUserRateProvider != nil {
		userTotal, userSuccess, hasUserLimit := dbUserRateProvider(userId)
		if hasUserLimit {
			// 使用用户级别限速
			return userTotal, userSuccess, true
		}
	}

	// 回退到用户组限速
	groupTotal, groupSuccess, found := GetGroupRateLimit(group)
	if found {
		return groupTotal, groupSuccess, false
	}

	// 使用全局默认配置
	return ModelRequestRateLimitCount, ModelRequestRateLimitSuccessCount, false
}
