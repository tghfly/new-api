package setting

import (
	"encoding/json"
	"sync"

	"github.com/QuantumNous/new-api/common"
	"github.com/QuantumNous/new-api/setting/ratio_setting"
)

var userUsableGroups = map[string]string{
	"default": "默认分组",
	"vip":     "vip分组",
}
var userUsableGroupsMutex sync.RWMutex

// 数据库用户组回调函数（由 model 包注册）
var (
	dbUserGroupPublicListProvider func() map[string]string
	dbUserGroupNameProvider       func(symbol string) string
)

// RegisterDBUserGroupProviders 注册数据库用户组回调函数
func RegisterDBUserGroupProviders(
	publicListProvider func() map[string]string,
	nameProvider func(symbol string) string,
	ratioProvider func(symbol string) float64,
	ratioMapProvider func() map[string]float64,
	symbolChecker func(symbol string) bool,
) {
	dbUserGroupPublicListProvider = publicListProvider
	dbUserGroupNameProvider = nameProvider
	// 同时注册到 ratio_setting 包
	ratio_setting.RegisterDBUserGroupCallbacks(ratioProvider, ratioMapProvider, symbolChecker)
}

func GetUserUsableGroupsCopy() map[string]string {
	// 优先从数据库缓存读取公开分组（通过回调）
	if dbUserGroupPublicListProvider != nil {
		dbGroups := dbUserGroupPublicListProvider()
		if len(dbGroups) > 0 {
			return dbGroups
		}
	}
	// 回退到内存配置
	userUsableGroupsMutex.RLock()
	defer userUsableGroupsMutex.RUnlock()

	copyUserUsableGroups := make(map[string]string)
	for k, v := range userUsableGroups {
		copyUserUsableGroups[k] = v
	}
	return copyUserUsableGroups
}

func UserUsableGroups2JSONString() string {
	userUsableGroupsMutex.RLock()
	defer userUsableGroupsMutex.RUnlock()

	jsonBytes, err := json.Marshal(userUsableGroups)
	if err != nil {
		common.SysLog("error marshalling user groups: " + err.Error())
	}
	return string(jsonBytes)
}

func UpdateUserUsableGroupsByJSONString(jsonStr string) error {
	userUsableGroupsMutex.Lock()
	defer userUsableGroupsMutex.Unlock()

	userUsableGroups = make(map[string]string)
	return json.Unmarshal([]byte(jsonStr), &userUsableGroups)
}

func GetUsableGroupDescription(groupName string) string {
	// 优先从数据库缓存读取（通过回调）
	if dbUserGroupNameProvider != nil {
		if name := dbUserGroupNameProvider(groupName); name != "" {
			return name
		}
	}
	// 回退到内存配置
	userUsableGroupsMutex.RLock()
	defer userUsableGroupsMutex.RUnlock()

	if desc, ok := userUsableGroups[groupName]; ok {
		return desc
	}
	return groupName
}
