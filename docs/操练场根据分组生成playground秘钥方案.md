# 操练场根据分组生成 playground 密钥方案

## 一、问题分析

### 1.1 当前 playground 密钥生成时机

在 [controller/playground.go](file:///d:\gopath\src\one-api\new-api\controller\playground.go) 中，playground 密钥的生成发生在**每次请求到达后端时**：

```go
// controller/playground.go 第57-63行
tempToken := &model.Token{
    UserId: userId,
    Name:   fmt.Sprintf("playground-%s", relayInfo.UsingGroup),
    Group:  usingGroup,  // 使用请求体中的 group 参数
}
_ = middleware.SetupContextForToken(c, tempToken)
```

### 1.2 发现的问题（根本原因）

经过深入分析代码，发现了**真正的问题**：

#### 问题定位

在 [middleware/distributor.go#L93](file:///d:\gopath\src\one-api\new-api\middleware\distributor.go#L93) 中，操练场切换分组的权限校验存在 Bug：

```go
// middleware/distributor.go 第92-99行
if playgroundRequest.Group != "" {
    if !service.GroupInUserUsableGroups(usingGroup, playgroundRequest.Group) && playgroundRequest.Group != usingGroup {
        abortWithOpenAiMessage(c, http.StatusForbidden, i18n.T(c, i18n.MsgDistributorGroupAccessDenied))
        return
    }
    usingGroup = playgroundRequest.Group
    common.SetContextKey(c, constant.ContextKeyUsingGroup, usingGroup)
}
```

#### 问题原因

调用 `service.GroupInUserUsableGroups(usingGroup, playgroundRequest.Group)` 时，**没有传入 userId 参数**：

```go
// service/group.go 第54-57行
func GroupInUserUsableGroups(userGroup, groupName string) bool {
    _, ok := GetUserUsableGroups(userGroup, 0)[groupName]  // userId = 0 !!!
    return ok
}
```

由于 userId = 0，无法查询 `user_group_mappings` 表获取用户关联的其他分组。

#### 数据模型说明

- **users.group**：只存储用户的**一个**默认项目分组
- **user_group_mappings**：存储用户**多个**项目分组的映射关系

用户可能属于多个项目分组（例如 A 项目、B 项目），但 users.group 只存了一个。当用户在操练场切换到另一个项目分组时，由于 userId = 0，无法从 user_group_mappings 查到用户的权限，导致校验失败。

---

## 二、解决方案

### 2.1 修复方案

#### 修改位置

修改 [middleware/distributor.go](file:///d:\gopath\src\one-api\new-api\middleware\distributor.go) 第93行。

#### 修改内容

将 `service.GroupInUserUsableGroups(usingGroup, playgroundRequest.Group)` 修改为传入正确的 userId：

```go
// 获取用户ID
userId := common.GetContextKeyInt(c, constant.ContextKeyUserId)

if playgroundRequest.Group != "" {
    if !service.GroupInUserUsableGroups(usingGroup, userId, playgroundRequest.Group) && playgroundRequest.Group != usingGroup {
        abortWithOpenAiMessage(c, http.StatusForbidden, i18n.T(c, i18n.MsgDistributorGroupAccessDenied))
        return
    }
    usingGroup = playgroundRequest.Group
    common.SetContextKey(c, constant.ContextKeyUsingGroup, usingGroup)
}
```

### 2.2 配套修改

#### 修改 service/group.go

由于 `GroupInUserUsableGroups` 需要使用 userId 来查询用户分组，需要修改函数签名和实现：

```go
// 修改前
func GroupInUserUsableGroups(userGroup, groupName string) bool {
    _, ok := GetUserUsableGroups(userGroup, 0)[groupName]
    return ok
}

// 修改后
func GroupInUserUsableGroups(userGroup string, userId int, groupName string) bool {
    _, ok := GetUserUsableGroups(userGroup, userId)[groupName]
    return ok
}
```

#### 获取 userId 的方式

在 distributor.go 中可以通过以下方式获取 userId：

```go
userId := common.GetContextKeyInt(c, constant.ContextKeyUserId)
```

或者：

```go
userId := c.GetInt("id")
```

---

## 三、实施步骤

### 步骤 1：修改 service/group.go

1. 修改 `GroupInUserUsableGroups` 函数签名，添加 userId 参数
2. 调用 `GetUserUsableGroups` 时传入正确的 userId

### 步骤 2：修改 middleware/distributor.go

1. 在 playground 权限校验处获取 userId
2. 调用 `service.GroupInUserUsableGroups` 时传入 userId

### 步骤 3：检查其他调用点

检查是否有其他地方调用了 `GroupInUserUsableGroups`，确保同步修改：

```bash
grep -r "GroupInUserUsableGroups" --include="*.go"
```

### 步骤 4：测试验证

1. 创建一个用户，属于 A 分组
2. 在 user_group_mappings 中添加该用户到 B 分组的映射
3. 在操练场中选择 B 分组发送请求
4. 验证请求能成功通过权限校验并调用渠道

---

## 四、关键代码位置汇总

| 文件 | 位置 | 说明 |
|------|------|------|
| middleware/distributor.go | 第92-99行 | playground 分组权限校验（问题所在） |
| service/group.go | 第54-57行 | GroupInUserUsableGroups 函数实现 |
| controller/playground.go | 第57-63行 | playground 密钥生成逻辑 |
| model/user_group_mapping.go | - | 用户分组映射表模型 |

---

## 五、备选方案（前端优化）

虽然后端问题是根本原因，但也可以在前端做一些优化：

在 [useDataLoader.js](file:///d:\gopath\src\one-api\new-api\web\src\hooks\playground\useDataLoader.js) 中添加分组变化监听，当分组变化时重新加载模型列表。

但**这个问题不是必须的**，因为后端修复后，前端即使不刷新模型列表，请求也能正确路由到对应分组的渠道。

---

## 六、总结

**问题的根本原因**：
- `service.GroupInUserUsableGroups` 函数调用时没有传入 userId
- 导致无法查询 user_group_mappings 获取用户的多分组权限
- 用户虽然在 user_group_mappings 中有 B 分组的映射，但由于 userId=0 查询不到

**解决方案**：
- 修改 `GroupInUserUsableGroups` 函数签名，添加 userId 参数
- 在 distributor.go 中获取正确的 userId 并传入
