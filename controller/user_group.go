package controller

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/QuantumNous/new-api/common"
	"github.com/QuantumNous/new-api/i18n"
	"github.com/QuantumNous/new-api/model"
	"github.com/gin-gonic/gin"
)

func GetUserGroupsList(c *gin.Context) {
	var params model.SearchUserGroupParams
	if err := c.ShouldBindQuery(&params); err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	userGroups, err := model.GetUserGroupsList(&params)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data":    userGroups,
	})
}

func GetUserGroupById(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))

	userGroup, err := model.GetUserGroupsById(id)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data":    userGroup,
	})
}

func AddUserGroup(c *gin.Context) {
	userGroup := model.UserGroup{}
	if err := c.ShouldBindJSON(&userGroup); err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}
	myRole := c.GetInt("role")
	if myRole != common.RoleRootUser {
		common.ApiErrorI18n(c, i18n.MsgUserNoPermissionHigherLevel)
		return
	}
	if err := userGroup.Create(); err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
	})
}

func UpdateUserGroup(c *gin.Context) {
	userGroup := model.UserGroup{}
	err := c.ShouldBindJSON(&userGroup)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}
	myRole := c.GetInt("role")
	if myRole != common.RoleRootUser {
		common.ApiErrorI18n(c, i18n.MsgUserNoPermissionHigherLevel)
		return
	}
	if err := userGroup.Update(); err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
	})
}

func DeleteUserGroup(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))

	userGroup, err := model.GetUserGroupsById(id)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}
	myRole := c.GetInt("role")
	if myRole != common.RoleRootUser {
		common.ApiErrorI18n(c, i18n.MsgUserNoPermissionHigherLevel)
		return
	}
	if userGroup.Symbol == "default" {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "默认用户组不能删除",
		})
		return
	}

	if err := userGroup.Delete(); err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
	})
}

func ChangeUserGroupEnable(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	userGroup, err := model.GetUserGroupsById(id)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}
	myRole := c.GetInt("role")
	if myRole != common.RoleRootUser {
		common.ApiErrorI18n(c, i18n.MsgUserNoPermissionHigherLevel)
		return
	}
	if *userGroup.Enable && userGroup.Symbol == "default" {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "不能关闭默认的用户组,请设置一个默认组后，再关闭",
		})
		return
	}

	err = model.ChangeUserGroupEnable(id, !*userGroup.Enable)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
	})
}

// GetPublicUserGroups 获取公开的用户组列表（供令牌选择）
func GetPublicUserGroups(c *gin.Context) {
	userGroups, err := model.GetUserGroupsAll(true)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	// 只返回必要字段
	type PublicUserGroup struct {
		Symbol string `json:"symbol"`
		Name   string `json:"name"`
	}

	publicGroups := make([]PublicUserGroup, 0, len(userGroups))
	for _, ug := range userGroups {
		publicGroups = append(publicGroups, PublicUserGroup{
			Symbol: ug.Symbol,
			Name:   ug.Name,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data":    publicGroups,
	})
}

// APIRespondWithError 统一错误响应
func APIRespondWithError(c *gin.Context, statusCode int, err error) {
	c.JSON(statusCode, gin.H{
		"success": false,
		"message": err.Error(),
	})
}

// GetUserGroupRatioBySymbol 根据Symbol获取用户组倍率
func GetUserGroupRatioBySymbol(c *gin.Context) {
	symbol := c.Param("symbol")

	userGroup := model.GlobalUserGroupRatio.GetBySymbol(symbol)
	if userGroup == nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "用户组不存在",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data": gin.H{
			"symbol":   userGroup.Symbol,
			"name":     userGroup.Name,
			"ratio":    userGroup.Ratio,
			"api_rate": userGroup.APIRate,
		},
	})
}

// CheckUserGroupLimit 检查用户组的API限制
func CheckUserGroupLimit(c *gin.Context) {
	symbol := c.Param("symbol")

	apiLimiter := model.GlobalUserGroupRatio.GetAPILimiter(symbol)
	if apiLimiter == nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "用户组不存在或未配置限流器",
		})
		return
	}

	// 使用固定key来检查当前限流状态
	count, err := apiLimiter.GetCurrentRate("api_limit_check")
	if err != nil {
		common.SysLog("检查用户组限流失败: " + err.Error())
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "检查限流失败: " + err.Error(),
		})
		return
	}

	// 尝试获取一个许可来检查是否允许
	allowed := apiLimiter.Allow("api_limit_check")

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data": gin.H{
			"allowed": allowed,
			"count":   count,
		},
	})
}

// SyncUserGroupFromExternal 从外部系统同步用户组（cloud-web集成）
func SyncUserGroupFromExternal(c *gin.Context) {
	var req struct {
		ExternalId  int64   `json:"external_id" binding:"required"`
		TenantId    string  `json:"tenant_id" binding:"required"`
		DeptId      string  `json:"dept_id"`
		ProjectCode string  `json:"project_code" binding:"required"`
		Name        string  `json:"name" binding:"required"`
		Ratio       float64 `json:"ratio"`
		APIRate     int     `json:"api_rate"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	userGroup, err := model.SyncUserGroup(req.ExternalId, req.TenantId, req.DeptId, req.ProjectCode, req.Name, req.Ratio, req.APIRate)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data":    userGroup,
	})
}

// DeleteUserGroupByExternalId 从外部系统删除用户组（cloud-web集成）
func DeleteUserGroupByExternalIdHandler(c *gin.Context) {
	externalId, err := strconv.ParseInt(c.Param("external_id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	if err := model.DeleteUserGroupByExternalId(externalId); err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
	})
}

// UpgradeUserGroup 手动升级用户组（管理员操作）
func UpgradeUserGroup(c *gin.Context) {
	var req struct {
		UserId      int    `json:"user_id" binding:"required"`
		GroupSymbol string `json:"group_symbol" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	// 验证用户组是否存在
	userGroup := model.GlobalUserGroupRatio.GetBySymbol(req.GroupSymbol)
	if userGroup == nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "用户组不存在",
		})
		return
	}
	myRole := c.GetInt("role")
	if myRole != common.RoleRootUser {
		common.ApiErrorI18n(c, i18n.MsgUserNoPermissionHigherLevel)
		return
	}
	// 更新用户的用户组
	err := model.DB.Model(&model.User{}).Where("id = ?", req.UserId).Update("group", req.GroupSymbol).Error
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	// 如果 Redis 启用，删除缓存
	if common.RedisEnabled {
		common.RedisDel(model.GetUserGroupCacheKey(req.UserId))
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
	})
}

// ValidateUserGroupSymbol 验证用户组Symbol是否有效
func ValidateUserGroupSymbol(symbol string) error {
	if symbol == "" {
		return errors.New("用户组标识不能为空")
	}

	userGroup := model.GlobalUserGroupRatio.GetBySymbol(symbol)
	if userGroup == nil {
		return errors.New("用户组不存在")
	}

	if !*userGroup.Enable {
		return errors.New("用户组已禁用")
	}

	return nil
}

// BatchSyncUserGroupsFromExternal 批量从外部系统同步用户组（cloud-web集成）
// 接收项目列表，批量创建或更新用户组，并建立当前用户与这些用户组的关联
func BatchSyncUserGroupsFromExternal(c *gin.Context) {
	var req struct {
		TenantId           string                   `json:"tenant_id" binding:"required"`
		VdcCode            string                   `json:"vdc_code" binding:"required"`
		Projects           []map[string]interface{} `json:"projects" binding:"required"`
		CurrentProjectCode string                   `json:"current_project_code"` // 当前项目 code，用于设置用户的默认分组
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		common.SysError("BatchSyncUserGroupsFromExternal bind failed: " + err.Error())
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	// 获取当前用户ID
	userId := c.GetInt("id")
	if userId == 0 {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "未登录",
		})
		return
	}

	// 获取用户信息以获取 external_user_id
	user, err := model.GetUserById(userId, false)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "获取用户信息失败: " + err.Error(),
		})
		return
	}

	created, updated, err := model.BatchSyncUserGroups(req.TenantId, req.VdcCode, req.Projects)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	// 建立用户与同步的用户组的关联
	for _, project := range req.Projects {
		externalIdFloat, ok := project["external_id"].(float64)
		if !ok {
			continue
		}
		externalId := int64(externalIdFloat)

		// 获取用户组
		userGroup, err := model.GetUserGroupByExternalId(externalId)
		if err != nil {
			common.SysLog("获取用户组失败: " + err.Error())
			continue
		}

		// 建立关联
		err = model.SaveUserGroupMapping(userId, userGroup.Id, user.ExternalUserId)
		if err != nil {
			common.SysLog("保存用户组映射失败: " + err.Error())
		}
	}

	// 更新用户的默认分组（只有当 group 为空或 "default" 时才更新）
	if req.CurrentProjectCode != "" && (user.Group == "" || user.Group == "default") {
		user.Group = req.CurrentProjectCode
		err = user.Update(false)
		if err != nil {
			common.SysLog("更新用户默认分组失败: " + err.Error())
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data": gin.H{
			"created": created,
			"updated": updated,
		},
	})
}

// GetMyUserGroups 获取当前用户所属的所有项目（用户组）
// 根据 user_group_mappings 表查询用户关联的所有用户组
func GetMyUserGroups(c *gin.Context) {
	// 从上下文中获取用户信息
	id := c.GetInt("id")
	if id == 0 {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "未登录",
		})
		return
	}

	// 通过 user_group_mappings 表获取用户关联的所有用户组
	userGroups, err := model.GetUserGroupsByUserId(id)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	// 如果没有关联的用户组，尝试获取用户信息并返回默认分组
	if len(userGroups) == 0 {
		user, err := model.GetUserById(id, false)
		if err == nil && user.Group != "" {
			// 获取用户的默认分组信息
			ug := model.GlobalUserGroupRatio.GetBySymbol(user.Group)
			if ug != nil {
				userGroups = append(userGroups, ug)
			}
		}
	}

	// 构建响应
	type UserGroupInfo struct {
		Symbol      string  `json:"symbol"`
		Name        string  `json:"name"`
		Ratio       float64 `json:"ratio"`
		APIRate     int     `json:"api_rate"`
		ProjectCode string  `json:"project_code"`
	}

	result := make([]UserGroupInfo, 0, len(userGroups))
	for _, ug := range userGroups {
		result = append(result, UserGroupInfo{
			Symbol:      ug.Symbol,
			Name:        ug.Name,
			Ratio:       ug.Ratio,
			APIRate:     ug.APIRate,
			ProjectCode: ug.ProjectCode,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data":    result,
	})
}

// GetAllUserGroupsMap 获取所有用户组的映射（仅管理员）
func GetAllUserGroupsMap(c *gin.Context) {
	// 检查权限
	role := c.GetInt("role")
	if role != common.RoleAdminUser && role != common.RoleRootUser {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "无权限访问",
		})
		return
	}

	// 获取所有用户组（包括私有的）
	userGroups, err := model.GetUserGroupsAll(false)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	// 构建映射
	groupMap := make(map[string]string)
	for _, ug := range userGroups {
		groupMap[ug.Symbol] = ug.Name
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data":    groupMap,
	})
}
