package permission

import (
	"strings"

	"gorm.io/gorm"
)

// scope 值（logs、tokens、tokengroup 共用同一套 scope）
const (
	ScopeAll       = "all"
	ScopeSpecDown  = "spec_down"
	ScopeSpec      = "spec"
	ScopeLocalDown = "local_down"
	ScopeLocal     = "local"
	ScopeProject   = "project"
	ScopeMe        = "me"
)

// parseAuthValue 解析日志权限 value。
// 支持的格式：
//
//	"all" → {scope: "all"}
//	"spec_down:020,021" → {scope: "spec_down", orgs: ["020","021"]}
//	"spec:020" → {scope: "spec", orgs: ["020"]}
//	"local_down" → {scope: "local_down"}
//	"local" → {scope: "local"}
//	"me" → {scope: "me"}
func parseAuthValue(value string) (map[string]interface{}, bool) {
	scope, orgs, ok := parseScopeValue(value)
	if !ok {
		return nil, false
	}
	data := map[string]interface{}{
		"scope": scope,
	}
	if len(orgs) > 0 {
		data["orgs"] = orgs
	}
	return data, true
}

var LogsAuth = NewResolver("new-api:logs:auth", "new-api:auth", parseAuthValue)

var TokensAuth = NewResolver("new-api:tokens:auth", "new-api:auth", parseAuthValue)

var UserGroupsAuth = NewResolver("new-api:usergroups:auth", "new-api:auth", parseAuthValue)

var ChannelAuth = NewResolver("new-api:channel:auth", "new-api:auth", parseAuthValue)

var GroupsAuth = NewResolver("new-api:groups:auth", "new-api:auth", parseAuthValue)

// GetScope extracts scope string from permission data
func GetScope(data map[string]interface{}) string {
	if scope, ok := data["scope"].(string); ok {
		return scope
	}
	return ""
}

// GetOrgs extracts org list from permission data
func GetOrgs(data map[string]interface{}) []string {
	if orgs, ok := data["orgs"].([]string); ok {
		return orgs
	}
	return nil
}

// GetDeptId extracts dept_id string from permission data
func GetDeptId(data map[string]interface{}) string {
	if deptId, ok := data["dept_id"].(string); ok {
		return deptId
	}
	return ""
}

// GetDeptId extracts dept_id string from permission data
func GetProjectId(data map[string]interface{}) string {
	if projectId, ok := data["group"].(string); ok {
		return projectId
	}
	return ""
}

// GroupFilterData holds the raw filter parameters extracted from permission data
type GroupFilterData struct {
	Mode   string
	Orgs   []string
	UserId int // 当 scope 为 spec_down/spec/local_down/local 时，过滤该用户创建的记录
}

// tableName: 表名，用于列名前缀，如 "logs"，为空时直接使用列名。
func (gfd *GroupFilterData) Apply(tx *gorm.DB, groupCol string, userCol string) *gorm.DB {
	if gfd == nil {
		return tx
	}

	// 收集 OR 条件两边的语句和参数
	var orConditions []string
	var orArgs []interface{}

	// 1. 添加用户ID过滤条件（作为 OR 的一边）
	if gfd.UserId > 0 {
		orConditions = append(orConditions, userCol+" = ?")
		orArgs = append(orArgs, gfd.UserId)
	}

	// 2. 添加组织过滤条件（作为 OR 的另一边）
	if len(gfd.Orgs) > 0 {
		switch gfd.Mode {
		case "prefix":
			for _, org := range gfd.Orgs {
				orConditions = append(orConditions, groupCol+" LIKE ?")
				orArgs = append(orArgs, org+"%")
			}
		case "exact", "in":
			orConditions = append(orConditions, groupCol+" IN ?")
			orArgs = append(orArgs, gfd.Orgs)
		}
	}

	// 3. 如果有 OR 条件，统一拼接并加到 Where 中
	if len(orConditions) > 0 {
		tx = tx.Where(strings.Join(orConditions, " OR "), orArgs...)
	}

	return tx
}

// tableName: 表名，用于列名前缀，如 "logs"，为空时直接使用列名。
func (gfd *GroupFilterData) ApplyGroup(tx *gorm.DB, groupCol string, userCol string) *gorm.DB {
	if gfd == nil {
		return tx
	}

	// 收集 OR 条件两边的语句和参数
	var orConditions []string
	var orArgs []interface{}

	// 1. 添加用户ID过滤条件（作为 OR 的一边）
	if gfd.UserId > 0 {
		orConditions = append(orConditions, userCol+" = ?")
		orArgs = append(orArgs, gfd.UserId)
	}

	// 2. 添加组织过滤条件（作为 OR 的另一边）
	if len(gfd.Orgs) > 0 {
		switch gfd.Mode {
		case "prefix":
			// 🔥 前缀匹配：REGEXP (^|,)org
			for _, org := range gfd.Orgs {
				// 生成正则：(^|,)xxx  匹配逗号开头或字符串开头 + 前缀
				regex := "(^|,)" + org
				orConditions = append(orConditions, groupCol+" REGEXP ?")
				orArgs = append(orArgs, regex)
			}

		case "exact", "in":
			// 🔥 精准包含：FIND_IN_SET(org, groupCol) > 0
			for _, org := range gfd.Orgs {
				orConditions = append(orConditions, "FIND_IN_SET(?, "+groupCol+") > 0")
				orArgs = append(orArgs, org)
			}
		}
	}

	// 3. 如果有 OR 条件，统一拼接并加到 Where 中
	if len(orConditions) > 0 {
		tx = tx.Where(strings.Join(orConditions, " OR "), orArgs...)
	}

	return tx
}

// ExtractGroupFilterData extracts group filter parameters from a Result.
// userId is used to filter records created by the specified user.
func ExtractGroupFilterData(auth Result, userId int) *GroupFilterData {
	if !auth.HasAuth {
		return nil
	}
	scope := GetScope(auth.Data)
	orgs := GetOrgs(auth.Data)
	deptId := GetDeptId(auth.Data)
	projectId := GetProjectId(auth.Data)

	switch scope {
	case ScopeAll:
		return nil
	case ScopeSpecDown:
		return &GroupFilterData{Mode: "prefix", Orgs: orgs, UserId: userId}
	case ScopeSpec:
		return &GroupFilterData{Mode: "in", Orgs: orgs, UserId: userId}
	case ScopeLocalDown:
		return &GroupFilterData{Mode: "prefix", Orgs: []string{deptId}, UserId: userId}
	case ScopeLocal:
		return &GroupFilterData{Mode: "in", Orgs: []string{deptId}, UserId: userId}
	case ScopeProject:
		return &GroupFilterData{Mode: "in", Orgs: []string{projectId}, UserId: userId}
	case ScopeMe:
		return nil
	default:
		return nil
	}
}
