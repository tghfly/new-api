package permission

import (
	"github.com/gin-gonic/gin"
)

// Result 权限解析结果。
// HasAuth 表示是否持有有效权限。
// Data 包含具体的权限数据，keys 由各权限类型的 ParseFunc 定义。
type Result struct {
	HasAuth bool
	Data    map[string]interface{}
}

// ParseFunc 权限 value 解析函数。
// 输入: other_role_map 中的 value 字符串
// 输出: data — 解析后的数据 map，keys 由具体权限类型定义
//
//	ok   — false 表示格式不合法，视为该 key 不存在
type ParseFunc func(value string) (data map[string]interface{}, ok bool)

// Resolver 权限解析器，用于从 other_role_map 解析指定资源的权限。
type Resolver struct {
	primaryKey  string
	fallbackKey string
	parseFunc   ParseFunc
}

// NewResolver 创建权限解析器。
func NewResolver(primaryKey, fallbackKey string, parseFunc ParseFunc) *Resolver {
	return &Resolver{
		primaryKey:  primaryKey,
		fallbackKey: fallbackKey,
		parseFunc:   parseFunc,
	}
}

// Resolve 从 gin context 中解析权限。
// 1. 从 context 获取 other_role_map
// 2. 优先查 primaryKey，调用 parseFunc 解析 value
// 3. primaryKey 不存在或格式错误时查 fallbackKey
// 4. 均不存在或格式错误时返回 HasAuth=false
// 5. 解析成功时自动注入 dept_id 到 Data（从 context 获取）
//
// 格式错误的 value 视为该 key 不存在，继续兜底逻辑。
func (r *Resolver) Resolve(c *gin.Context) Result {
	otherRoleMapRaw, exists := c.Get("other_role_map")
	if !exists {
		return Result{HasAuth: false}
	}
	otherRoleMap, ok := otherRoleMapRaw.(map[string]string)
	if !ok || len(otherRoleMap) == 0 {
		return Result{HasAuth: false}
	}

	data := r.tryResolve(otherRoleMap)
	if data == nil {
		return Result{HasAuth: false}
	}

	if deptId := getDeptId(c); deptId != "" {
		data["dept_id"] = deptId
	}

	return Result{HasAuth: true, Data: data}
}

// tryResolve 尝试从 other_role_map 中按优先级查找并解析 value。
func (r *Resolver) tryResolve(otherRoleMap map[string]string) map[string]interface{} {
	// 1. 优先查 primaryKey
	if r.primaryKey != "" {
		if value, exists := otherRoleMap[r.primaryKey]; exists && value != "" {
			if data, ok := r.parseFunc(value); ok {
				return data
			}
		}
	}

	// 2. 查 fallbackKey
	if r.fallbackKey != "" {
		if value, exists := otherRoleMap[r.fallbackKey]; exists && value != "" {
			if data, ok := r.parseFunc(value); ok {
				return data
			}
		}
	}

	return nil
}

// getDeptId 从 context 获取 dept_id（vdc_code）
func getDeptId(c *gin.Context) string {
	if deptId, exists := c.Get("vdc_code"); exists {
		if str, ok := deptId.(string); ok {
			return str
		}
	}
	return ""
}
