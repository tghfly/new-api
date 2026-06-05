package controller

import (
	"errors"
	"fmt"
	"log"
	"net/http"
	"strconv"

	"github.com/QuantumNous/new-api/common"
	"github.com/QuantumNous/new-api/i18n"
	"github.com/QuantumNous/new-api/model"
	"github.com/QuantumNous/new-api/pkg/permission"
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

// FullSyncUserGroupsFromExternal 全部同步用户组（替换模式）
// 将传入的所有项目完整替换系统中同步来源的用户组（保留非同步来源的用户组）
// 1. 查询当前租户下所有用户组，建立 external_id 和 project_code 索引
// 2. 遍历传入项目：存在则更新，不存在则创建
// 3. 传入项目中没有的现有用户组，enable 设为 false
func FullSyncUserGroupsFromExternal(c *gin.Context) {
	common.SysLog("FullSyncUserGroupsFromExternal: 开始同步用户组")

	var req struct {
		TenantId string                   `json:"tenant_id" binding:"required"`
		Projects []map[string]interface{} `json:"projects" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		common.SysError("FullSyncUserGroupsFromExternal bind failed: " + err.Error())
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	common.SysLog(fmt.Sprintf("FullSyncUserGroupsFromExternal: tenant_id=%s, projects_count=%d", req.TenantId, len(req.Projects)))

	// 1. 查询当前租户下所有 synced 来源的用户组
	existingGroups, err := model.GetUserGroupsByTenantId(req.TenantId)
	if err != nil {
		common.SysError("FullSyncUserGroupsFromExternal: 查询现有用户组失败, " + err.Error())
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "查询现有用户组失败: " + err.Error(),
		})
		return
	}

	common.SysLog(fmt.Sprintf("FullSyncUserGroupsFromExternal: 查询到现有用户组数量=%d", len(existingGroups)))

	// 2. 构建索引 map
	byExternalId := make(map[int64]*model.UserGroup)
	byProjectCode := make(map[string]*model.UserGroup)
	for _, group := range existingGroups {
		if group.ExternalId > 0 {
			byExternalId[group.ExternalId] = group
		}
		if group.ProjectCode != "" {
			byProjectCode[group.ProjectCode] = group
		}
	}

	created := 0
	updated := 0
	disabled := 0

	// 标记哪些用户组应该在本次同步中被保留
	handledIds := make(map[int]bool)

	// 3. 遍历传入的项目，同步用户组
	for _, project := range req.Projects {
		externalIdFloat, ok := project["external_id"].(float64)
		if !ok {
			continue
		}
		externalId := int64(externalIdFloat)
		projectCode, _ := project["project_code"].(string)
		projectName, _ := project["project_name"].(string)
		vdcCode, _ := project["vdc_code"].(string)
		isDelete, _ := project["is_delete"].(bool)

		common.SysLog(fmt.Sprintf("FullSyncUserGroupsFromExternal: 处理项目 external_id=%d, project_code=%s, project_name=%s, is_delete=%v", externalId, projectCode, projectName, isDelete))

		var userGroup *model.UserGroup

		// 查找是否已存在
		if existing, exists := byExternalId[externalId]; exists {
			userGroup = existing
			common.SysLog(fmt.Sprintf("FullSyncUserGroupsFromExternal: 通过 external_id 找到已有用户组 id=%d", userGroup.Id))
		} else if projectCode != "" {
			if existing, exists := byProjectCode[projectCode]; exists {
				userGroup = existing
				// 如果 external_id 不同，更新 external_id
				userGroup.ExternalId = externalId
				common.SysLog(fmt.Sprintf("FullSyncUserGroupsFromExternal: 通过 project_code 找到已有用户组 id=%d, 更新 external_id=%d", userGroup.Id, externalId))
			}
		}

		enable := !isDelete

		if userGroup == nil {
			// 不存在，创建新的
			common.SysLog(fmt.Sprintf("FullSyncUserGroupsFromExternal: 创建新用户组 external_id=%d, project_code=%s", externalId, projectCode))
			userGroup = &model.UserGroup{
				ExternalId:  externalId,
				Symbol:      projectCode,
				Name:        projectName,
				Ratio:       1.0,
				APIRate:     1000,
				Public:      false,
				Promotion:   false,
				Min:         0,
				Max:         0,
				Enable:      &enable,
				TenantId:    req.TenantId,
				DeptId:      vdcCode,
				ProjectCode: projectCode,
				Source:      "synced",
			}
			err = userGroup.Create()
			if err != nil {
				common.SysError("FullSyncUserGroupsFromExternal create failed: " + err.Error())
				continue
			}
			created++
			common.SysLog(fmt.Sprintf("FullSyncUserGroupsFromExternal: 创建成功, 新用户组 id=%d", userGroup.Id))
		} else {
			// 已存在，更新
			handledIds[userGroup.Id] = true
			userGroup.Symbol = projectCode
			userGroup.Name = projectName
			userGroup.TenantId = req.TenantId
			userGroup.DeptId = vdcCode
			userGroup.ProjectCode = projectCode
			userGroup.Enable = &enable
			err = model.DB.Model(userGroup).Select("symbol", "name", "tenant_id", "dept_id", "project_code", "external_id", "enable").Updates(userGroup).Error
			if err != nil {
				common.SysError("FullSyncUserGroupsFromExternal update failed: " + err.Error())
				continue
			}
			updated++
			common.SysLog(fmt.Sprintf("FullSyncUserGroupsFromExternal: 更新成功, 用户组 id=%d", userGroup.Id))
		}
	}

	// 4. 处理传入项目中没有的现有用户组，禁用它们
	for _, group := range existingGroups {
		if !handledIds[group.Id] {
			enable := false
			group.Enable = &enable
			err = model.DB.Model(group).Update("enable", false).Error
			if err != nil {
				common.SysError("FullSyncUserGroupsFromExternal disable group failed: " + err.Error())
				continue
			}
			disabled++
			common.SysLog(fmt.Sprintf("FullSyncUserGroupsFromExternal: 禁用用户组 id=%d, symbol=%s", group.Id, group.Symbol))
		}
	}

	// 重新加载缓存
	model.GlobalUserGroupRatio.Load()

	common.SysLog(fmt.Sprintf("FullSyncUserGroupsFromExternal: 同步完成, created=%d, updated=%d, disabled=%d", created, updated, disabled))

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data": gin.H{
			"created":  created,
			"updated":  updated,
			"disabled": disabled,
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

// resolveDCloudUserGroupsAuth resolves DCloud user groups permission from context
func resolveDCloudUserGroupsAuth(c *gin.Context) permission.Result {
	if !common.DCloudIntegrationEnabled {
		return permission.Result{HasAuth: false}
	}
	return permission.UserGroupsAuth.Resolve(c)
}

// GetAllUserGroupsWithAuth 获取所有用户组（支持分权分域）
func GetAllUserGroupsWithAuth(c *gin.Context) {
	dcloudAuth := resolveDCloudUserGroupsAuth(c)
	log.Printf("GetAllUserGroupsWithAuth - HasAuth: %v, DCloudEnabled: %v", dcloudAuth.HasAuth, common.DCloudIntegrationEnabled)
	if dcloudAuth.HasAuth {
		scope := permission.GetScope(dcloudAuth.Data)
		userId := c.GetInt("id")
		log.Printf("GetAllUserGroupsWithAuth - scope: %s, userId: %d", scope, userId)

		var userGroups []*model.UserGroup
		var err error
		// me 模式下，只能查看自己的用户组
		if scope == permission.ScopeMe {
			userGroups, err = model.GetUserGroupsByUserId(userId)
		} else {
			// 非 me 模式下，使用 groupFilter 限制查询范围
			groupFilter := permission.ExtractGroupFilterData(dcloudAuth, userId)
			userGroups, err = model.GetUserGroupsWithFilter(groupFilter)

		}

		if err != nil {
			c.JSON(http.StatusOK, gin.H{
				"success": false,
				"message": err.Error(),
			})
			return
		}
		// 公共用户组
		publicGroups, publicErr := model.GetUserGroupsWithPublic()
		if publicErr != nil {
			c.JSON(http.StatusOK, gin.H{
				"success": false,
				"message": publicErr.Error(),
			})
			return
		}

		// 核心：symbol 去重（用 map 记录已存在的 symbol）
		existsMap := make(map[string]struct{})
		list := make([]map[string]string, 0, len(userGroups)+len(publicGroups))

		// 1. 添加公共用户组（自动跳过已存在的 symbol）
		for _, ug := range publicGroups {
			symbol := ug.Symbol
			if _, exists := existsMap[symbol]; !exists {
				existsMap[symbol] = struct{}{}
				list = append(list, map[string]string{
					"symbol": symbol,
					"name":   ug.Name,
				})
			}
		}

		// 2. 添加自己的用户组（去重）
		for _, ug := range userGroups {
			symbol := ug.Symbol
			if _, exists := existsMap[symbol]; !exists {
				existsMap[symbol] = struct{}{}
				list = append(list, map[string]string{
					"symbol": symbol,
					"name":   ug.Name,
				})
			}
		}

		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": "",
			"data":    list,
		})
		return
	}
	log.Printf("GetAllUserGroupsWithAuth - no dcloud auth, falling back to GetGroups")
	GetGroups(c)
	return
}
