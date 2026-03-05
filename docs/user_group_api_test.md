# 用户组功能 API 测试文档

## 概述

本文档描述了用户组功能的 API 接口及其测试方法。

## API 接口

### 1. 获取用户组列表

**请求:**
```
GET /api/user-group/
```

**参数:**
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| page | int | 否 | 页码，默认 1 |
| page_size | int | 否 | 每页数量，默认 10 |
| name | string | 否 | 按名称模糊搜索 |
| enable | bool | 否 | 按启用状态筛选 |

**响应示例:**
```json
{
  "success": true,
  "message": "",
  "data": {
    "list": [
      {
        "id": 1,
        "symbol": "default",
        "name": "默认分组",
        "ratio": 1.0,
        "api_rate": 600,
        "public": true,
        "promotion": false,
        "min": 0,
        "max": 0,
        "enable": true,
        "tenant_id": "",
        "dept_id": "",
        "project_code": "",
        "external_id": 0,
        "source": "local"
      }
    ],
    "total": 1
  }
}
```

### 2. 创建用户组

**请求:**
```
POST /api/user-group/
```

**请求体:**
```json
{
  "symbol": "vip",
  "name": "VIP分组",
  "ratio": 0.8,
  "api_rate": 1200,
  "public": true,
  "promotion": true,
  "min": 100,
  "max": 1000
}
```

**字段说明:**
| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| symbol | string | 是 | 用户组唯一标识符，创建后不可修改 |
| name | string | 是 | 用户组显示名称 |
| ratio | float | 是 | 倍率，如 0.8 表示 80% 计费 |
| api_rate | int | 是 | 每分钟允许的请求数 |
| public | bool | 否 | 是否公开，公开的分组可在令牌中选择 |
| promotion | bool | 否 | 是否启用自动晋级 |
| min | int | 否 | 晋级最低充值金额 |
| max | int | 否 | 晋级最高充值金额，0 表示无上限 |

**响应示例:**
```json
{
  "success": true,
  "message": "用户组创建成功",
  "data": {
    "id": 2,
    "symbol": "vip",
    "name": "VIP分组",
    "ratio": 0.8,
    "api_rate": 1200,
    "public": true,
    "promotion": true,
    "min": 100,
    "max": 1000,
    "enable": true
  }
}
```

### 3. 更新用户组

**请求:**
```
PUT /api/user-group/:id
```

**请求体:**
```json
{
  "name": "VIP分组-更新",
  "ratio": 0.75,
  "api_rate": 1500,
  "public": true,
  "promotion": true,
  "min": 200,
  "max": 2000
}
```

**响应示例:**
```json
{
  "success": true,
  "message": "用户组更新成功"
}
```

### 4. 删除用户组

**请求:**
```
DELETE /api/user-group/:id
```

**响应示例:**
```json
{
  "success": true,
  "message": "用户组删除成功"
}
```

### 5. 获取公开用户组列表

**请求:**
```
GET /api/user-group/public
```

**说明:**
此接口用于令牌创建时选择用户组，仅返回公开且启用的用户组。

**响应示例:**
```json
{
  "success": true,
  "message": "",
  "data": [
    {
      "symbol": "default",
      "name": "默认分组"
    },
    {
      "symbol": "vip",
      "name": "VIP分组"
    }
  ]
}
```

## 测试步骤

### 1. 使用 curl 测试

```bash
# 获取用户组列表
curl -X GET "http://localhost:3000/api/user-group/" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 创建用户组
curl -X POST "http://localhost:3000/api/user-group/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "symbol": "vip",
    "name": "VIP分组",
    "ratio": 0.8,
    "api_rate": 1200,
    "public": true
  }'

# 更新用户组
curl -X PUT "http://localhost:3000/api/user-group/2" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "VIP分组-更新",
    "ratio": 0.75,
    "api_rate": 1500
  }'

# 删除用户组
curl -X DELETE "http://localhost:3000/api/user-group/2" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 2. 使用 Postman 测试

1. 导入 API 端点
2. 设置 Authorization Header 为 Bearer Token
3. 按顺序测试各个接口

## 数据库迁移

首次部署需要执行数据库迁移：

```bash
# 进入 MySQL 执行迁移脚本
mysql -u root -p your_database < bin/migration_user_group.sql
```

或者让应用自动迁移（GORM AutoMigrate 已集成）。

## 限流测试

用户组的 API 限流功能可以通过以下方式测试：

1. 创建一个用户组，设置 `api_rate` 为较低值（如 10）
2. 创建一个用户并分配到该用户组
3. 使用该用户的令牌连续发送请求
4. 观察是否在超过限流阈值后返回 429 错误

## 晋级功能测试

1. 创建一个晋级用户组：
   ```json
   {
     "symbol": "premium",
     "name": "高级会员",
     "ratio": 0.7,
     "api_rate": 2000,
     "public": false,
     "promotion": true,
     "min": 100,
     "max": 500
   }
   ```

2. 用户充值金额达到晋级条件后，系统自动将其用户组更新为该分组

## 注意事项

1. `symbol` 字段在创建后不可修改
2. 删除用户组前需要确保没有用户关联到该分组
3. 限流器支持 Redis 分布式限流（推荐生产环境使用）
4. 晋级功能基于用户累计充值金额触发