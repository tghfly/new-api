-- 用户限速功能迁移脚本
-- 在 users 表中添加 api_rate_total 和 api_rate_success 字段

-- MySQL
ALTER TABLE `users`
ADD COLUMN IF NOT EXISTS `api_rate_total` INT DEFAULT 0 COMMENT '用户API限流-每周期最多请求次数（包括失败请求，0表示使用用户组配置）',
ADD COLUMN IF NOT EXISTS `api_rate_success` INT DEFAULT 0 COMMENT '用户API限流-每周期最多成功请求次数（0表示使用用户组配置）';

-- 创建索引以加速查询
CREATE INDEX IF NOT EXISTS `idx_users_api_rate` ON `users`(`api_rate_total`, `api_rate_success`);

-- PostgreSQL
-- ALTER TABLE users
-- ADD COLUMN IF NOT EXISTS api_rate_total INTEGER DEFAULT 0,
-- ADD COLUMN IF NOT EXISTS api_rate_success INTEGER DEFAULT 0;
-- COMMENT ON COLUMN users.api_rate_total IS '用户API限流-每周期最多请求次数（包括失败请求，0表示使用用户组配置）';
-- COMMENT ON COLUMN users.api_rate_success IS '用户API限流-每周期最多成功请求次数（0表示使用用户组配置）';
-- CREATE INDEX IF NOT EXISTS idx_users_api_rate ON users(api_rate_total, api_rate_success);
