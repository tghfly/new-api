package permission

import "strings"

// parseScopeValue 解析 "scope" 或 "scope:org1,org2" 格式的 value。
// 返回 scope、orgs 和是否解析成功。
func parseScopeValue(value string) (scope string, orgs []string, ok bool) {
	if value == "" {
		return "", nil, false
	}

	value = strings.TrimSpace(value)
	if value == "" {
		return "", nil, false
	}

	colonIdx := strings.Index(value, ":")
	var scopePart, orgsPart string

	if colonIdx == -1 {
		scopePart = value
		orgsPart = ""
	} else if colonIdx == 0 {
		return "", nil, false
	} else {
		scopePart = value[:colonIdx]
		orgsPart = value[colonIdx+1:]
	}

	scope = scopePart

	switch scope {
	case "all", "local_down", "local", "me":
		if orgsPart != "" {
			return "", nil, false
		}
		return scope, nil, true

	case "spec_down", "spec":
		if orgsPart == "" {
			return "", nil, false
		}
		orgsPart = strings.TrimSpace(orgsPart)
		if orgsPart == "" {
			return "", nil, false
		}
		orgList := strings.Split(orgsPart, ",")
		result := make([]string, 0, len(orgList))
		for _, org := range orgList {
			org = strings.TrimSpace(org)
			if org == "" {
				return "", nil, false
			}
			result = append(result, org)
		}
		if len(result) == 0 {
			return "", nil, false
		}
		return scope, result, true

	default:
		return "", nil, false
	}
}
