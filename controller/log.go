package controller

import (
	"fmt"
	"net/http"
	"strconv"

	"github.com/QuantumNous/new-api/common"
	"github.com/QuantumNous/new-api/logger"
	"github.com/QuantumNous/new-api/model"
	"github.com/QuantumNous/new-api/pkg/permission"

	"github.com/gin-gonic/gin"
)

// handleGetAllLogs is a helper to fetch logs with optional group filter
func handleGetAllLogs(c *gin.Context, groupFilter *permission.GroupFilterData) {
	pageInfo := common.GetPageQuery(c)
	logType, _ := strconv.Atoi(c.Query("type"))
	startTimestamp, _ := strconv.ParseInt(c.Query("start_timestamp"), 10, 64)
	endTimestamp, _ := strconv.ParseInt(c.Query("end_timestamp"), 10, 64)
	username := c.Query("username")
	tokenName := c.Query("token_name")
	modelName := c.Query("model_name")
	channel, _ := strconv.Atoi(c.Query("channel"))
	group := c.Query("group")
	requestId := c.Query("request_id")

	logs, total, err := model.GetAllLogs(logType, startTimestamp, endTimestamp, modelName, username, tokenName, pageInfo.GetStartIdx(), pageInfo.GetPageSize(), channel, group, requestId, groupFilter)
	if err != nil {
		common.ApiError(c, err)
		return
	}
	pageInfo.SetTotal(int(total))
	pageInfo.SetItems(logs)
	common.ApiSuccess(c, pageInfo)
}

// handleGetUserLogs is a helper to fetch user logs with optional group filter
func handleGetUserLogs(c *gin.Context, userId int, groupFilter *permission.GroupFilterData) {
	pageInfo := common.GetPageQuery(c)
	logType, _ := strconv.Atoi(c.Query("type"))
	startTimestamp, _ := strconv.ParseInt(c.Query("start_timestamp"), 10, 64)
	endTimestamp, _ := strconv.ParseInt(c.Query("end_timestamp"), 10, 64)
	tokenName := c.Query("token_name")
	modelName := c.Query("model_name")
	group := c.Query("group")
	requestId := c.Query("request_id")

	logs, total, err := model.GetUserLogs(userId, logType, startTimestamp, endTimestamp, modelName, tokenName, pageInfo.GetStartIdx(), pageInfo.GetPageSize(), group, requestId, groupFilter)
	if err != nil {
		common.ApiError(c, err)
		return
	}
	pageInfo.SetTotal(int(total))
	pageInfo.SetItems(logs)
	common.ApiSuccess(c, pageInfo)
}

// handleGetLogsStat is a helper to fetch log statistics with optional group filter
func handleGetLogsStat(c *gin.Context, username string, groupFilter *permission.GroupFilterData) {
	logType, _ := strconv.Atoi(c.Query("type"))
	startTimestamp, _ := strconv.ParseInt(c.Query("start_timestamp"), 10, 64)
	endTimestamp, _ := strconv.ParseInt(c.Query("end_timestamp"), 10, 64)
	tokenName := c.Query("token_name")
	modelName := c.Query("model_name")
	channel, _ := strconv.Atoi(c.Query("channel"))
	group := c.Query("group")

	stat, err := model.SumUsedQuota(logType, startTimestamp, endTimestamp, modelName, username, tokenName, channel, group, groupFilter)
	if err != nil {
		common.ApiError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data": gin.H{
			"quota": stat.Quota,
			"rpm":   stat.Rpm,
			"tpm":   stat.Tpm,
		},
	})
}

// resolveDCloudLogAuth resolves DCloud log permission from context
func resolveDCloudLogAuth(c *gin.Context) permission.Result {
	if !common.DCloudIntegrationEnabled {
		return permission.Result{HasAuth: false}
	}
	return permission.LogsAuth.Resolve(c)
}

func GetAllLogs(c *gin.Context) {
	role := c.GetInt("role")

	// DCloud 认证用户走分权分域逻辑
	dcloudAuth := resolveDCloudLogAuth(c)
	logger.LogInfo(c, fmt.Sprintf("[GetAllLogs] DCloud auth result: hasAuth=%v, scope=%s, data=%v", dcloudAuth.HasAuth, permission.GetScope(dcloudAuth.Data), dcloudAuth.Data))
	if dcloudAuth.HasAuth {
		scope := permission.GetScope(dcloudAuth.Data)
		userId := c.GetInt("id")
		logger.LogInfo(c, fmt.Sprintf("[GetAllLogs] DCloud mode: scope=%s, userId=%d", scope, userId))

		// me 模式下，只能查看自己的日志（通过 GetUserLogs）
		if scope == permission.ScopeMe {
			logger.LogInfo(c, "[GetAllLogs] DCloud me mode - calling handleGetUserLogs")
			handleGetUserLogs(c, userId, nil)
			return
		}

		// 非 me 模式下，使用 groupFilter 限制查询范围
		groupFilter := permission.ExtractGroupFilterData(dcloudAuth, userId)
		logger.LogInfo(c, fmt.Sprintf("[GetAllLogs] DCloud non-me mode - groupFilter=%v", groupFilter))
		handleGetAllLogs(c, groupFilter)
		return
	}

	logger.LogInfo(c, fmt.Sprintf("[GetAllLogs] Non-DCloud mode: role=%d", role))
	// 原有的角色权限检查
	if role == common.RoleAdminUser {
		pageInfo := common.GetPageQuery(c)
		userId := c.GetInt("id")
		logType, _ := strconv.Atoi(c.Query("type"))
		startTimestamp, _ := strconv.ParseInt(c.Query("start_timestamp"), 10, 64)
		endTimestamp, _ := strconv.ParseInt(c.Query("end_timestamp"), 10, 64)
		tokenName := c.Query("token_name")
		modelName := c.Query("model_name")
		group := c.Query("group")
		requestId := c.Query("request_id")
		logger.LogInfo(c, fmt.Sprintf("[GetAllLogs] Admin mode: userId=%d, logType=%d, group=%s", userId, logType, group))
		logs, total, err := model.GetUserLogs(userId, logType, startTimestamp, endTimestamp, modelName, tokenName, pageInfo.GetStartIdx(), pageInfo.GetPageSize(), group, requestId, nil)
		if err != nil {
			common.ApiError(c, err)
			return
		}
		pageInfo.SetTotal(int(total))
		pageInfo.SetItems(logs)
		common.ApiSuccess(c, pageInfo)
		return
	}

	// Root 用户：可以查看所有日志
	logger.LogInfo(c, "[GetAllLogs] Root mode - calling handleGetAllLogs with nil filter")
	handleGetAllLogs(c, nil)
}

func GetUserLogs(c *gin.Context) {
	// DCloud 认证用户走分权分域逻辑
	dcloudAuth := resolveDCloudLogAuth(c)
	if dcloudAuth.HasAuth {
		scope := permission.GetScope(dcloudAuth.Data)
		userId := c.GetInt("id")

		// me 模式下，只能查看自己的日志
		if scope == permission.ScopeMe {
			handleGetUserLogs(c, userId, nil)
			return
		}

		// 非 me 模式下，使用 groupFilter 限制查询范围
		groupFilter := permission.ExtractGroupFilterData(dcloudAuth, userId)
		handleGetUserLogs(c, userId, groupFilter)
		return
	}

	// 原有的用户日志查询
	pageInfo := common.GetPageQuery(c)
	userId := c.GetInt("id")
	logType, _ := strconv.Atoi(c.Query("type"))
	startTimestamp, _ := strconv.ParseInt(c.Query("start_timestamp"), 10, 64)
	endTimestamp, _ := strconv.ParseInt(c.Query("end_timestamp"), 10, 64)
	tokenName := c.Query("token_name")
	modelName := c.Query("model_name")
	group := c.Query("group")
	requestId := c.Query("request_id")
	logs, total, err := model.GetUserLogs(userId, logType, startTimestamp, endTimestamp, modelName, tokenName, pageInfo.GetStartIdx(), pageInfo.GetPageSize(), group, requestId, nil)
	if err != nil {
		common.ApiError(c, err)
		return
	}
	pageInfo.SetTotal(int(total))
	pageInfo.SetItems(logs)
	common.ApiSuccess(c, pageInfo)
}

// Deprecated: SearchAllLogs 已废弃，前端未使用该接口。
func SearchAllLogs(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"success": false,
		"message": "该接口已废弃",
	})
}

// Deprecated: SearchUserLogs 已废弃，前端未使用该接口。
func SearchUserLogs(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"success": false,
		"message": "该接口已废弃",
	})
}

func GetLogByKey(c *gin.Context) {
	tokenId := c.GetInt("token_id")
	if tokenId == 0 {
		c.JSON(200, gin.H{
			"success": false,
			"message": "无效的令牌",
		})
		return
	}
	logs, err := model.GetLogByTokenId(tokenId)
	if err != nil {
		c.JSON(200, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}
	c.JSON(200, gin.H{
		"success": true,
		"message": "",
		"data":    logs,
	})
}

func GetLogsStat(c *gin.Context) {
	// DCloud 认证用户走分权分域逻辑
	dcloudAuth := resolveDCloudLogAuth(c)
	if dcloudAuth.HasAuth {
		scope := permission.GetScope(dcloudAuth.Data)
		username := c.GetString("username")
		userId := c.GetInt("id")

		// me 模式下，只能查看自己的统计
		if scope == permission.ScopeMe {
			handleGetLogsStat(c, username, nil)
			return
		}

		// 非 me 模式下，使用 groupFilter 限制查询范围
		groupFilter := permission.ExtractGroupFilterData(dcloudAuth, userId)
		handleGetLogsStat(c, username, groupFilter)
		return
	}

	// 原有的日志统计查询
	logType, _ := strconv.Atoi(c.Query("type"))
	startTimestamp, _ := strconv.ParseInt(c.Query("start_timestamp"), 10, 64)
	endTimestamp, _ := strconv.ParseInt(c.Query("end_timestamp"), 10, 64)
	tokenName := c.Query("token_name")
	username := c.Query("username")
	modelName := c.Query("model_name")
	channel, _ := strconv.Atoi(c.Query("channel"))
	group := c.Query("group")
	stat, err := model.SumUsedQuota(logType, startTimestamp, endTimestamp, modelName, username, tokenName, channel, group, nil)
	if err != nil {
		common.ApiError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data": gin.H{
			"quota": stat.Quota,
			"rpm":   stat.Rpm,
			"tpm":   stat.Tpm,
		},
	})
}

func GetLogsSelfStat(c *gin.Context) {
	username := c.GetString("username")
	logType, _ := strconv.Atoi(c.Query("type"))
	startTimestamp, _ := strconv.ParseInt(c.Query("start_timestamp"), 10, 64)
	endTimestamp, _ := strconv.ParseInt(c.Query("end_timestamp"), 10, 64)
	tokenName := c.Query("token_name")
	modelName := c.Query("model_name")
	channel, _ := strconv.Atoi(c.Query("channel"))
	group := c.Query("group")
	quotaNum, err := model.SumUsedQuota(logType, startTimestamp, endTimestamp, modelName, username, tokenName, channel, group, nil)
	if err != nil {
		common.ApiError(c, err)
		return
	}
	c.JSON(200, gin.H{
		"success": true,
		"message": "",
		"data": gin.H{
			"quota": quotaNum.Quota,
			"rpm":   quotaNum.Rpm,
			"tpm":   quotaNum.Tpm,
		},
	})
}

func DeleteHistoryLogs(c *gin.Context) {
	// DCloud 认证用户走分权分域逻辑
	dcloudAuth := resolveDCloudLogAuth(c)
	if dcloudAuth.HasAuth {
		scope := permission.GetScope(dcloudAuth.Data)
		userId := c.GetInt("id")
		// me 模式下，不允许删除历史日志
		if scope == permission.ScopeMe {
			c.JSON(http.StatusOK, gin.H{
				"success": false,
				"message": "me 模式下不允许删除历史日志",
			})
			return
		}

		// 非 me 模式下，使用 groupFilter 限制删除范围
		groupFilter := permission.ExtractGroupFilterData(dcloudAuth, userId)
		targetTimestamp, _ := strconv.ParseInt(c.Query("target_timestamp"), 10, 64)
		if targetTimestamp == 0 {
			c.JSON(http.StatusOK, gin.H{
				"success": false,
				"message": "target timestamp is required",
			})
			return
		}
		count, err := model.DeleteOldLog(c.Request.Context(), targetTimestamp, 100, groupFilter)
		if err != nil {
			common.ApiError(c, err)
			return
		}
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": "",
			"data":    count,
		})
		return
	}

	// 仅有 Root 用户有权限删除历史日志（已在 middleware 权限检查中确保）
	// 此处不再做额外角色检查，直接执行删除
	targetTimestamp, _ := strconv.ParseInt(c.Query("target_timestamp"), 10, 64)
	if targetTimestamp == 0 {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "target timestamp is required",
		})
		return
	}
	count, err := model.DeleteOldLog(c.Request.Context(), targetTimestamp, 100, nil)
	if err != nil {
		common.ApiError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "",
		"data":    count,
	})
}
