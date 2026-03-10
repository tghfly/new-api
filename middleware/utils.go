package middleware

import (
	"fmt"
	"time"

	"github.com/QuantumNous/new-api/common"
	"github.com/QuantumNous/new-api/constant"
	"github.com/QuantumNous/new-api/logger"
	"github.com/QuantumNous/new-api/model"
	"github.com/QuantumNous/new-api/types"
	"github.com/gin-gonic/gin"
)

func abortWithOpenAiMessage(c *gin.Context, statusCode int, message string, code ...types.ErrorCode) {
	codeStr := ""
	if len(code) > 0 {
		codeStr = string(code[0])
	}
	userId := c.GetInt("id")
	c.JSON(statusCode, gin.H{
		"error": gin.H{
			"message": common.MessageWithRequestId(message, c.GetString(common.RequestIdKey)),
			"type":    "new_api_error",
			"code":    codeStr,
		},
	})
	c.Abort()
	logger.LogError(c.Request.Context(), fmt.Sprintf("user %d | %s", userId, message))

	// 如果启用了 distributor 错误日志记录，则将错误记录到 MySQL
	if constant.ErrorLogEnabled && constant.ErrorLogDistributorEnabled {
		recordDistributorErrorLog(c, message, codeStr)
	}
}

// recordDistributorErrorLog 记录 distributor 阶段的错误日志到 MySQL
func recordDistributorErrorLog(c *gin.Context, message string, errorCode string) {
	userId := c.GetInt("id")
	tokenName := c.GetString("token_name")
	modelName := c.GetString("original_model")
	if modelName == "" {
		modelName = "未知模型"
	}
	tokenId := c.GetInt("token_id")
	userGroup := c.GetString("group")

	other := make(map[string]interface{})
	if c.Request != nil && c.Request.URL != nil {
		other["request_path"] = c.Request.URL.Path
	}
	other["error_type"] = "new_api_error"
	other["error_code"] = errorCode
	other["status_code"] = c.Writer.Status()
	other["channel_id"] = 0 // distributor 阶段还没有选择渠道
	other["channel_name"] = ""
	other["channel_type"] = 0

	adminInfo := make(map[string]interface{})
	adminInfo["use_channel"] = []string{}
	other["admin_info"] = adminInfo

	startTime := common.GetContextKeyTime(c, constant.ContextKeyRequestStartTime)
	if startTime.IsZero() {
		startTime = time.Now()
	}
	useTimeSeconds := int(time.Since(startTime).Seconds())

	model.RecordErrorLog(c, userId, 0, modelName, tokenName, message, tokenId, useTimeSeconds, false, userGroup, other)
}

func abortWithMidjourneyMessage(c *gin.Context, statusCode int, code int, description string) {
	c.JSON(statusCode, gin.H{
		"description": description,
		"type":        "new_api_error",
		"code":        code,
	})
	c.Abort()
	logger.LogError(c.Request.Context(), description)
}
