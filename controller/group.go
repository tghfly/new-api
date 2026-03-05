package controller

import (
	"net/http"

	"github.com/QuantumNous/new-api/model"
	"github.com/QuantumNous/new-api/service"
	"github.com/QuantumNous/new-api/setting"
	"github.com/QuantumNous/new-api/setting/ratio_setting"

	"github.com/gin-gonic/gin"
)

// GroupInfo 用户组信息
// swagger:model GroupInfo
type GroupInfo struct {
	Symbol string `json:"symbol"` // 用户组标识（如 project_code）
	Name   string `json:"name"`   // 用户组名称（可读性更好）
}

func GetGroups(c *gin.Context) {
	groups := make([]GroupInfo, 0)
	for symbol := range ratio_setting.GetGroupRatioCopy() {
		// 获取用户组的名称
		name := setting.GetUsableGroupDescription(symbol)
		if name == "" {
			name = symbol
		}
		groups = append(groups, GroupInfo{
			Symbol: symbol,
			Name:   name,
		})
	}
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data":    groups,
	})
}

// UserGroupInfo 用户组详细信息
// swagger:model UserGroupInfo
type UserGroupInfo struct {
	Symbol string      `json:"symbol"` // 用户组标识
	Name   string      `json:"name"`   // 用户组名称（可读性更好）
	Desc   string      `json:"desc"`   // 描述
	Ratio  interface{} `json:"ratio"`  // 倍率
}

func GetUserGroups(c *gin.Context) {
	usableGroups := make([]UserGroupInfo, 0)
	userGroup := ""
	userId := c.GetInt("id")
	userGroup, _ = model.GetUserGroup(userId, false)
	// 传入 userId 以查询 user_group_mappings 表获取用户关联的所有用户组
	userUsableGroups := service.GetUserUsableGroups(userGroup, userId)
	for groupSymbol := range ratio_setting.GetGroupRatioCopy() {
		// UserUsableGroups contains the groups that the user can use
		if desc, ok := userUsableGroups[groupSymbol]; ok {
			// 获取用户组的友好名称
			name := setting.GetUsableGroupDescription(groupSymbol)
			if name == "" {
				name = groupSymbol
			}
			usableGroups = append(usableGroups, UserGroupInfo{
				Symbol: groupSymbol,
				Name:   name,
				Desc:   desc,
				Ratio:  service.GetUserGroupRatio(userGroup, groupSymbol),
			})
		}
	}
	if _, ok := userUsableGroups["auto"]; ok {
		usableGroups = append(usableGroups, UserGroupInfo{
			Symbol: "auto",
			Name:   "自动",
			Desc:   setting.GetUsableGroupDescription("auto"),
			Ratio:  "自动",
		})
	}
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data":    usableGroups,
	})
}
