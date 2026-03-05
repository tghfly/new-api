-- 用户组功能迁移脚本
-- 用于创建 user_groups 表

-- MySQL
CREATE TABLE IF NOT EXISTS `user_groups` (
    `id` int NOT NULL AUTO_INCREMENT,
    `symbol` varchar(64) NOT NULL COMMENT '用户组标识，用于程序识别',
    `name` varchar(128) NOT NULL COMMENT '用户组名称',
    `ratio` decimal(10,2) DEFAULT '1.00' COMMENT '倍率',
    `api_rate` int DEFAULT '0' COMMENT 'API限流速率(RPM)，0表示不限流',
    `public` tinyint(1) DEFAULT '0' COMMENT '是否公开(可供令牌选择)',
    `enable` tinyint(1) DEFAULT '1' COMMENT '是否启用',
    `external_id` bigint DEFAULT NULL COMMENT '外部系统ID(用于cloud-web集成)',
    `tenant_id` varchar(128) DEFAULT NULL COMMENT '租户ID(用于cloud-web集成)',
    `dept_id` varchar(128) DEFAULT NULL COMMENT '部门ID(用于cloud-web集成)',
    `project_code` varchar(128) DEFAULT NULL COMMENT '项目代码(用于cloud-web集成)',
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` datetime DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_symbol` (`symbol`),
    KEY `idx_external_id` (`external_id`),
    KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户组表';

-- 插入默认用户组
INSERT IGNORE INTO `user_groups` (`symbol`, `name`, `ratio`, `api_rate`, `public`, `enable`)
VALUES ('default', '默认用户组', 1.00, 1000, 1, 1);

INSERT IGNORE INTO `user_groups` (`symbol`, `name`, `ratio`, `api_rate`, `public`, `enable`)
       VALUES ('vip', 'vip分组', 1.00, 1000, 0,1);

INSERT IGNORE INTO `user_groups` (`symbol`, `name`, `ratio`, `api_rate`, `public`, `enable`)
       VALUES ('svip', 'svip分组', 1.00, 1000, 0,1);
-- PostgreSQL
-- CREATE TABLE IF NOT EXISTS user_groups (
--     id SERIAL PRIMARY KEY,
--     symbol VARCHAR(64) NOT NULL UNIQUE,
--     name VARCHAR(128) NOT NULL,
--     ratio DECIMAL(10,2) DEFAULT 1.00,
--     api_rate INTEGER DEFAULT 0,
--     public BOOLEAN DEFAULT FALSE,
--     enable BOOLEAN DEFAULT TRUE,
--     external_id BIGINT DEFAULT NULL,
--     tenant_id VARCHAR(128) DEFAULT NULL,
--     dept_id VARCHAR(128) DEFAULT NULL,
--     project_code VARCHAR(128) DEFAULT NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     deleted_at TIMESTAMP DEFAULT NULL
-- );

-- CREATE INDEX IF NOT EXISTS idx_user_groups_external_id ON user_groups(external_id);
-- CREATE INDEX IF NOT EXISTS idx_user_groups_tenant_id ON user_groups(tenant_id);

-- INSERT INTO user_groups (symbol, name, ratio, api_rate, public, enable)
-- VALUES ('default', '默认用户组', 1.00, 0, TRUE, TRUE)
-- ON CONFLICT (symbol) DO NOTHING;