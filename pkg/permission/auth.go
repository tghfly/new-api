package permission

// scope 值（logs、tokens、tokengroup 共用同一套 scope）
const (
	ScopeAll       = "all"
	ScopeSpecDown  = "spec_down"
	ScopeSpec      = "spec"
	ScopeLocalDown = "local_down"
	ScopeLocal     = "local"
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

var TokenGroupAuth = NewResolver("new-api:tokengroup:auth", "new-api:auth", parseAuthValue)

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

// GroupFilterData holds the raw filter parameters extracted from permission data
type GroupFilterData struct {
	Mode string
	Orgs []string
}

// ExtractGroupFilterData extracts group filter parameters from a Result
func ExtractGroupFilterData(auth Result) *GroupFilterData {
	if !auth.HasAuth {
		return nil
	}
	scope := GetScope(auth.Data)
	orgs := GetOrgs(auth.Data)
	deptId := GetDeptId(auth.Data)

	switch scope {
	case ScopeAll:
		return nil
	case ScopeSpecDown:
		return &GroupFilterData{Mode: "prefix", Orgs: orgs}
	case ScopeSpec:
		return &GroupFilterData{Mode: "in", Orgs: orgs}
	case ScopeLocalDown:
		return &GroupFilterData{Mode: "prefix", Orgs: []string{deptId}}
	case ScopeLocal:
		return &GroupFilterData{Mode: "exact", Orgs: []string{deptId}}
	case ScopeMe:
		return nil
	default:
		return nil
	}
}
