package permission

// 日志权限 scope 值
const (
	LogScopeAll       = "all"
	LogScopeSpecDown  = "spec_down"
	LogScopeSpec      = "spec"
	LogScopeLocalDown = "local_down"
	LogScopeLocal     = "local"
	LogScopeMe        = "me"
)

// parseLogAuthValue 解析日志权限 value。
// 支持的格式：
//
//	"all" → {scope: "all"}
//	"spec_down:020,021" → {scope: "spec_down", orgs: ["020","021"]}
//	"spec:020" → {scope: "spec", orgs: ["020"]}
//	"local_down" → {scope: "local_down"}
//	"local" → {scope: "local"}
//	"me" → {scope: "me"}
func parseLogAuthValue(value string) (map[string]interface{}, bool) {
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

// LogsAuth 日志权限解析器
var LogsAuth = NewResolver("new-api:logs:auth", "new-api:auth", parseLogAuthValue)
