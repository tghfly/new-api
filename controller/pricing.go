package controller

import (
	"github.com/QuantumNous/new-api/common"
	"github.com/QuantumNous/new-api/model"
	"github.com/QuantumNous/new-api/service"
	"github.com/QuantumNous/new-api/setting/ratio_setting"
	"log"

	"github.com/gin-gonic/gin"
)

func GetPricing(c *gin.Context) {
	pricing := model.GetPricing()
	userId, exists := c.Get("id")
	usableGroup := map[string]string{}
	groupRatio := map[string]float64{}
	for s, f := range ratio_setting.GetGroupRatioCopy() {
		groupRatio[s] = f
	}
	var group string
	if exists {
		user, err := model.GetUserCache(userId.(int))
		if err == nil {
			group = user.Group
			for g := range groupRatio {
				ratio, ok := ratio_setting.GetGroupGroupRatio(group, g)
				if ok {
					groupRatio[g] = ratio
				}
			}
		}
	}

	// 传入 userId 以查询 user_group_mappings 表获取用户关联的所有用户组
	userIdInt := 0
	if exists {
		userIdInt = userId.(int)
	}
	usableGroup = service.GetUserUsableGroups(group, userIdInt)
	// check groupRatio contains usableGroup
	for group := range ratio_setting.GetGroupRatioCopy() {
		if _, ok := usableGroup[group]; !ok {
			delete(groupRatio, group)
		}
	}

	role := c.GetInt("role")
	if role < 1 {
		c.JSON(200, gin.H{
			"success": false,
			"message": "未登录",
		})
		return
	}
	log.Printf("GetPricing - userId: %v, group: %s, role: %d, groupRatio keys: %d", userId, group, role, len(groupRatio))

	// 非管理员只返回自己可用分组的模型定价
	if role < common.RoleAdminUser {
		filtered := make([]model.Pricing, 0, len(pricing))
		for _, p := range pricing {
			if len(p.EnableGroup) == 0 {
				filtered = append(filtered, p)
				continue
			}
			for _, eg := range p.EnableGroup {
				if _, ok := usableGroup[eg]; ok {
					filtered = append(filtered, p)
					break
				}
			}
		}
		pricing = filtered
	}

	c.JSON(200, gin.H{
		"success":            true,
		"data":               pricing,
		"vendors":            model.GetVendors(),
		"group_ratio":        groupRatio,
		"usable_group":       usableGroup,
		"supported_endpoint": model.GetSupportedEndpointMap(),
		"auto_groups":        service.GetUserAutoGroup(group),
		"_":                  "a42d372ccf0b5dd13ecf71203521f9d2",
	})
}

func ResetModelRatio(c *gin.Context) {
	defaultStr := ratio_setting.DefaultModelRatio2JSONString()
	err := model.UpdateOption("ModelRatio", defaultStr)
	if err != nil {
		c.JSON(200, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}
	err = ratio_setting.UpdateModelRatioByJSONString(defaultStr)
	if err != nil {
		c.JSON(200, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}
	c.JSON(200, gin.H{
		"success": true,
		"message": "重置模型倍率成功",
	})
}
