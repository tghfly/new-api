-- 用户-用户组关联表
-- 用于支持一个用户属于多个项目（用户组）的场景
-- 创建时间: 2026-03-02

CREATE TABLE IF NOT EXISTS user_group_mappings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL COMMENT 'new-api 用户ID',
    group_id INT NOT NULL COMMENT '用户组ID',
    external_user_id VARCHAR(64) COMMENT '算力平台用户ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_group (user_id, group_id),
    INDEX idx_user_id (user_id),
    INDEX idx_group_id (group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户-用户组关联表';
