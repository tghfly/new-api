package middleware

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/QuantumNous/new-api/common"
	"github.com/QuantumNous/new-api/model"
	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"gorm.io/gorm"
)

// DCloud JWT Claims 結構
type DCloudJWTClaims struct {
	TenantId     string            `json:"tenant_id"`
	RoleName     string            `json:"role_name"`
	VdcCode      string            `json:"vdc_code"`
	RoleId       string            `json:"role_id"`
	UserId       string            `json:"user_id"`
	UserName     string            `json:"user_name"`
	Exp          int64             `json:"exp"`
	Authorities  []string          `json:"authorities"`
	ClientId     string            `json:"client_id"`
	Account      string            `json:"account"`
	OtherRole    interface{}       `json:"other_role"`
	OtherRoleMap map[string]string `json:"-"`
}

// GetExpirationTime 返回 JWT 的過期時間
func (c *DCloudJWTClaims) GetExpirationTime() (*jwt.NumericDate, error) {
	if c.Exp == 0 {
		return nil, nil
	}
	return jwt.NewNumericDate(time.Unix(c.Exp, 0)), nil
}

// GetIssuedAt 返回 JWT 的簽發時間（未使用）
func (c *DCloudJWTClaims) GetIssuedAt() (*jwt.NumericDate, error) {
	return nil, nil
}

// GetNotBefore 返回 JWT 的生效時間（未使用）
func (c *DCloudJWTClaims) GetNotBefore() (*jwt.NumericDate, error) {
	return nil, nil
}

// GetIssuer 返回 JWT 的簽發者（未使用）
func (c *DCloudJWTClaims) GetIssuer() (string, error) {
	return "", nil
}

// GetSubject 返回 JWT 的主題（用戶ID）
func (c *DCloudJWTClaims) GetSubject() (string, error) {
	return c.UserId, nil
}

// GetAudience 返回 JWT 的受眾（未使用）
func (c *DCloudJWTClaims) GetAudience() (jwt.ClaimStrings, error) {
	return nil, nil
}

// DCloud 角色常量
const (
	DCloudRoleGuest  = "oneapiguestrole"
	DCloudRoleCommon = "oneapicommonrole"
	DCloudRoleAdmin  = "oneapiadminrole"
	DCloudRoleRoot   = "oneapirootrole"
)

// DCloudRoleMap 算力平台角色到 new-api 角色的映射
var DCloudRoleMap = map[string]int{
	DCloudRoleGuest:  common.RoleGuestUser,  // 0
	DCloudRoleCommon: common.RoleCommonUser, // 1
	DCloudRoleAdmin:  common.RoleAdminUser,  // 10
	DCloudRoleRoot:   common.RoleRootUser,   // 100
}

// DCloudRolePriority 角色優先級（從高到低）
var DCloudRolePriority = []string{
	DCloudRoleRoot,
	DCloudRoleAdmin,
	DCloudRoleCommon,
	DCloudRoleGuest,
}

// ParseDCloudRole 從算力平台 role_name 解析 new-api 角色
func ParseDCloudRole(roleName string) int {
	if roleName == "" {
		return common.RoleCommonUser
	}

	roles := strings.Split(roleName, ",")
	roleSet := make(map[string]bool)
	for _, r := range roles {
		roleSet[strings.TrimSpace(r)] = true
	}

	// 按优先級查找
	for _, priorityRole := range DCloudRolePriority {
		if roleSet[priorityRole] {
			return DCloudRoleMap[priorityRole]
		}
	}

	return common.RoleCommonUser
}

// ValidateDCloudToken 驗證算力平台 JWT Token
func ValidateDCloudToken(tokenString string) (*DCloudJWTClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &DCloudJWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		// 驗證簽名算法
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(common.DCloudJWTSecret), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*DCloudJWTClaims); ok && token.Valid {
		// 解析 OtherRole（可能是字符串或map）
		if claims.OtherRole != nil {
			switch v := claims.OtherRole.(type) {
			case string:
				// 如果是字符串，尝试解析为 JSON
				if v != "" {
					if err := json.Unmarshal([]byte(v), &claims.OtherRoleMap); err != nil {
						fmt.Printf("[DEBUG DCloud parseToken] Failed to parse OtherRole string: %v\n", err)
					}
				}
			case map[string]interface{}:
				// 转换为 map[string]string
				claims.OtherRoleMap = make(map[string]string)
				for key, val := range v {
					if strVal, ok := val.(string); ok {
						claims.OtherRoleMap[key] = strVal
					}
				}
			}
		}
		fmt.Printf("[DEBUG DCloud ValidateDCloudToken] OtherRoleMap=%v\n", claims.OtherRoleMap)
		return claims, nil
	}

	return nil, errors.New("invalid token claims")
}

// SyncDCloudUser 同步算力平台用戶到本地
func SyncDCloudUser(claims *DCloudJWTClaims) (*model.User, error) {
	// 1. 尝试通过 external_user_id + tenant_id 查找用戶
	user, err := model.GetUserByTenantAndExternalId(claims.TenantId, claims.UserId)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}
	var role int
	if claims.OtherRoleMap != nil {
		if newapiRole, ok := claims.OtherRoleMap["newapi"]; ok && newapiRole != "" {
			fmt.Printf("[DEBUG DCloud SyncDCloudUser] OtherRoleMap newapi=%s\n", newapiRole)
			if r, err := strconv.Atoi(newapiRole); err == nil {
				role = r
				fmt.Printf("[DEBUG DCloud SyncDCloudUser] Parsed role from OtherRoleMap: %d\n", role)
			}
		}
	}

	if role == 0 {
		role = ParseDCloudRole(claims.RoleName)
		fmt.Printf("[DEBUG DCloud SyncDCloudUser] Parsed role from RoleName: %d\n", role)
	}

	if user == nil {
		// 2. 用戶不存在，創建新用戶
		// 检查用戶名是否已存在
		existingUser, _ := model.GetUserByUsername(claims.UserName)
		if existingUser != nil {
			// 如果用戶名已存在，添加後綴
			claims.UserName = claims.UserName + "_" + claims.TenantId
		}

		user = &model.User{
			Username:       claims.UserName,
			DisplayName:    claims.UserName,
			Role:           role,
			Status:         common.UserStatusEnabled,
			Quota:          100000000,
			TenantId:       claims.TenantId,
			DeptId:         claims.VdcCode,
			ExternalUserId: claims.UserId,
			Group:          "default", // 默认分组，后续可以通过同步项目列表来更新
		}
		err = user.Insert(0)
	} else {
		// 3. 用戶存在，更新信息
		user.Role = role
		user.TenantId = claims.TenantId
		user.DeptId = claims.VdcCode
		// 如果用戶名變了也更新
		if user.Username != claims.UserName {
			// 檢查新用戶名是否已被其他用戶使用
			existingUser, _ := model.GetUserByUsername(claims.UserName)
			if existingUser == nil || existingUser.Id == user.Id {
				user.Username = claims.UserName
				user.DisplayName = claims.UserName
			}
		}
		err = user.Update(false)
	}

	return user, err
}

// SyncDCloudUserWithProjects 同步算力平台用戶及項目列表到本地
// projects: 項目列表，每個項目包含 external_id, project_code, project_name
func SyncDCloudUserWithProjects(claims *DCloudJWTClaims, projects []map[string]interface{}) (*model.User, error) {
	// 1. 先同步用戶基本信息
	user, err := SyncDCloudUser(claims)
	if err != nil {
		return nil, err
	}

	// 2. 如果有項目列表，同步項目到用戶組
	if len(projects) > 0 {
		_, _, err := model.BatchSyncUserGroups(claims.TenantId, claims.VdcCode, projects)
		if err != nil {
			common.SysError("Failed to sync user groups: " + err.Error())
			// 不返回錯誤，繼續處理
		}

		// 3. 設置用戶的默認分組為第一個項目的 project_code
		if firstProject, ok := projects[0]["project_code"].(string); ok && firstProject != "" {
			if user.Group == "" || user.Group == "default" {
				user.Group = firstProject
				err = user.Update(false)
				if err != nil {
					common.SysError("Failed to update user group: " + err.Error())
				}
			}
		}
	}

	return user, nil
}

// DCloudAuth 算力平台认证中间件
func DCloudAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 如果未启用算力平台集成，直接跳过
		if !common.DCloudIntegrationEnabled {
			c.Next()
			return
		}

		// 1. 从 Cookie 中获取 dcloud_token
		tokenString, err := c.Cookie(common.DCloudCookieName)
		if err != nil || tokenString == "" {
			// 嘗試讀取備選 cookie 名稱 "token"
			tokenString, err = c.Cookie("token")
			if err != nil || tokenString == "" {
				// 沒有找到算力平台的 token，繼續後續處理
				c.Next()
				return
			}
		}

		// 2. 驗證 JWT
		claims, err := ValidateDCloudToken(tokenString)
		if err != nil {
			// JWT 驗證失敗，但可能是普通的 session 請求，繼續後續處理
			common.SysLog("DCloud JWT validation failed: " + err.Error())
			c.Next()
			return
		}

		// 3. 同步用戶信息
		user, err := SyncDCloudUser(claims)
		if err != nil {
			common.SysError("Failed to sync DCloud user: " + err.Error())
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "用戶同步失敗",
			})
			c.Abort()
			return
		}

		// 4. 写入 Session
		session := sessions.Default(c)
		session.Set("username", user.Username)
		session.Set("role", user.Role)
		session.Set("id", user.Id)
		session.Set("status", user.Status)
		session.Set("group", user.Group)
		session.Set("tenant_id", user.TenantId)
		session.Set("external_user_id", user.ExternalUserId)
		session.Set("dcloud_auth", true)
		err = session.Save()
		if err != nil {
			common.SysError("Failed to save session: " + err.Error())
		}

		// 5. 设置上下文
		c.Set("username", user.Username)
		c.Set("role", user.Role)
		c.Set("id", user.Id)
		c.Set("group", user.Group)
		c.Set("user_group", user.Group)
		c.Set("tenant_id", user.TenantId)
		c.Set("external_user_id", user.ExternalUserId)
		c.Set("use_access_token", false)
		c.Set("vdc_code", claims.VdcCode)
		c.Set("other_role_map", claims.OtherRoleMap)
		//c.Set("other_role_map", TestMap)

		c.Next()
	}
}

// DCloudAuthRequired 算力平台認證必需中間件（未登錄則返回錯誤）
func DCloudAuthRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 如果未啟用算力平台集成，直接跳過
		if !common.DCloudIntegrationEnabled {
			c.Next()
			return
		}

		// 檢查是否已經有 session
		session := sessions.Default(c)
		if session.Get("id") != nil {
			c.Next()
			return
		}

		// 1. 從 Cookie 中讀取 dcloud_token
		tokenString, err := c.Cookie(common.DCloudCookieName)
		if err != nil || tokenString == "" {
			// 嘗試讀取備選 cookie 名稱 "token"
			tokenString, err = c.Cookie("token")
			if err != nil || tokenString == "" {
				c.JSON(http.StatusUnauthorized, gin.H{
					"success": false,
					"message": "未提供有效的認證憑證",
				})
				c.Abort()
				return
			}
		}

		// 2. 驗證 JWT
		claims, err := ValidateDCloudToken(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "無效的認證憑證",
			})
			c.Abort()
			return
		}

		// 3. 同步用戶信息
		user, err := SyncDCloudUser(claims)
		if err != nil {
			common.SysError("Failed to sync DCloud user: " + err.Error())
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "用戶同步失敗",
			})
			c.Abort()
			return
		}

		// 4. 寫入 Session
		session.Set("username", user.Username)
		session.Set("role", user.Role)
		session.Set("id", user.Id)
		session.Set("status", user.Status)
		session.Set("group", user.Group)
		session.Set("tenant_id", user.TenantId)
		session.Set("external_user_id", user.ExternalUserId)
		session.Set("dcloud_auth", true)
		err = session.Save()
		if err != nil {
			common.SysError("Failed to save session: " + err.Error())
		}

		// 5. 設置上下文
		c.Set("username", user.Username)
		c.Set("role", user.Role)
		c.Set("id", user.Id)
		c.Set("group", user.Group)
		c.Set("user_group", user.Group)
		c.Set("tenant_id", user.TenantId)
		c.Set("external_user_id", user.ExternalUserId)
		c.Set("use_access_token", false)
		c.Set("vdc_code", claims.VdcCode)
		c.Set("other_role_map", claims.OtherRoleMap)

		c.Next()
	}
}
