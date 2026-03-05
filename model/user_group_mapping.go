package model

import (
	"time"
)

type UserGroupMapping struct {
	Id             int       `json:"id" gorm:"primary_key"`
	UserId         int       `json:"user_id" gorm:"index;not null"`
	GroupId        int       `json:"group_id" gorm:"index;not null"`
	ExternalUserId string    `json:"external_user_id" gorm:"type:varchar(64)"`
	CreatedAt      time.Time `json:"created_at"`
}

func (UserGroupMapping) TableName() string {
	return "user_group_mappings"
}

// GetUserGroupsByUserId 根据用户ID获取关联的所有用户组
func GetUserGroupsByUserId(userId int) ([]*UserGroup, error) {
	var userGroups []*UserGroup
	err := DB.Joins("JOIN user_group_mappings ON user_group_mappings.group_id = user_groups.id").
		Where("user_group_mappings.user_id = ?", userId).
		Find(&userGroups).Error
	return userGroups, err
}

// SaveUserGroupMapping 保存用户-用户组关联（如果不存在则创建）
func SaveUserGroupMapping(userId, groupId int, externalUserId string) error {
	mapping := UserGroupMapping{
		UserId:         userId,
		GroupId:        groupId,
		ExternalUserId: externalUserId,
		CreatedAt:      time.Now(),
	}
	// FirstOrCreate: 如果不存在则创建，存在则返回已有记录
	return DB.Where("user_id = ? AND group_id = ?", userId, groupId).
		FirstOrCreate(&mapping).Error
}

// DeleteUserGroupMappingsByUserId 删除用户的所有关联
func DeleteUserGroupMappingsByUserId(userId int) error {
	return DB.Where("user_id = ?", userId).Delete(&UserGroupMapping{}).Error
}

// DeleteUserGroupMapping 删除特定的用户-用户组关联
func DeleteUserGroupMapping(userId, groupId int) error {
	return DB.Where("user_id = ? AND group_id = ?", userId, groupId).
		Delete(&UserGroupMapping{}).Error
}

// GetUserGroupIdsByUserId 获取用户关联的所有用户组ID
func GetUserGroupIdsByUserId(userId int) ([]int, error) {
	var mappings []UserGroupMapping
	err := DB.Where("user_id = ?", userId).Find(&mappings).Error
	if err != nil {
		return nil, err
	}

	groupIds := make([]int, len(mappings))
	for i, m := range mappings {
		groupIds[i] = m.GroupId
	}
	return groupIds, nil
}

// IsUserInGroup 检查用户是否属于某个用户组
func IsUserInGroup(userId, groupId int) bool {
	var count int64
	DB.Model(&UserGroupMapping{}).
		Where("user_id = ? AND group_id = ?", userId, groupId).
		Count(&count)
	return count > 0
}
