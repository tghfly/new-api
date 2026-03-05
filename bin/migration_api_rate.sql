-- 用户组限速字段迁移脚本
-- 将旧的 api_rate 字段数据迁移到新的 api_rate_total 和 api_rate_success 字段

-- 1. 首先添加新字段（如果不存在）
ALTER TABLE user_groups ADD COLUMN IF NOT EXISTS api_rate_total INT DEFAULT 0;
ALTER TABLE user_groups ADD COLUMN IF NOT EXISTS api_rate_success INT DEFAULT 1000;

-- 2. 将旧数据迁移到新字段
-- 将原来的 api_rate 值同时设置给 api_rate_total 和 api_rate_success
UPDATE user_groups SET
    api_rate_total = CASE WHEN api_rate = 0 THEN 0 ELSE api_rate END,
    api_rate_success = CASE WHEN api_rate = 0 THEN 1000 ELSE api_rate END
WHERE api_rate_total = 0 AND api_rate_success = 1000;

-- 3. 为 default 组设置默认值（如果还没有设置）
UPDATE user_groups SET
    api_rate_total = 0,
    api_rate_success = 1000
WHERE symbol = 'default' AND api_rate_total = 0 AND api_rate_success = 1000;

-- 4. 验证迁移结果
SELECT symbol, name, api_rate, api_rate_total, api_rate_success
FROM user_groups
ORDER BY id;
