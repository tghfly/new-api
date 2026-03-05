# new-api 日志改造实现计划

## 项目背景

需要对 new-api 的使用日志进行改造，记录用户的输入 prompt 以及模型的输出，包括：
- 输入：messages 字段
- 输出：id 字段和 message 字段

同时需要适配不同类型的模型，包括文本、VL模型、向量模型、重排模型等。

## 实现计划

### 1. 分析现有代码结构

- **controller/relay.go**：处理 API 请求的主控制器
- **relay/compatible_handler.go**：处理文本模型的请求，包括 `/v1/chat/completions` 接口
- **relay/channel/openai/relay-openai.go**：处理 OpenAI 模型的响应
- **model/log.go**：记录使用日志的相关函数

### 2. 实现输入日志记录

- **修改 TextHelper 函数**：在处理文本模型请求时，记录输入的 messages 字段
- **修改其他模型处理函数**：对于 VL模型、向量模型、重排模型等，记录相应的输入字段

### 3. 实现输出日志记录

- **修改 OpenaiHandler 函数**：在处理 OpenAI 模型响应时，记录输出的 id 和 message 字段
- **修改 OaiStreamHandler 函数**：在处理流式响应时，记录输出的 id 和 message 字段
- **修改其他模型响应处理函数**：对于其他类型的模型，记录相应的输出字段

### 4. 适配不同类型的模型

- **文本模型**：记录 messages 输入和 message 输出
- **VL模型**：记录包含图像的输入和相应的输出
- **向量模型**：记录输入文本和输出向量
- **重排模型**：记录输入文本和重排结果

### 5. 性能和稳定性考虑

- 确保日志记录不会影响系统性能
- 确保日志记录不会导致内存泄漏
- 确保日志记录不会影响响应时间

## 具体实现步骤

### 任务 1：修改 TextHelper 函数，记录输入的 messages 字段

- **优先级**：P0
- **依赖**：无
- **描述**：在 TextHelper 函数中，获取并记录用户输入的 messages 字段
- **成功标准**：能够在日志中看到用户输入的 messages 字段
- **测试要求**：
  - `programmatic` TR-1.1：发送 /v1/chat/completions 请求，检查日志中是否包含 messages 字段
  - `human-judgement` TR-1.2：检查日志格式是否清晰，信息是否完整

### 任务 2：修改 OpenaiHandler 函数，记录输出的 id 和 message 字段

- **优先级**：P0
- **依赖**：任务 1
- **描述**：在 OpenaiHandler 函数中，获取并记录模型输出的 id 和 message 字段
- **成功标准**：能够在日志中看到模型输出的 id 和 message 字段
- **测试要求**：
  - `programmatic` TR-2.1：发送 /v1/chat/completions 请求，检查日志中是否包含 id 和 message 字段
  - `human-judgement` TR-2.2：检查日志格式是否清晰，信息是否完整

### 任务 3：修改 OaiStreamHandler 函数，记录流式响应的 id 和 message 字段

- **优先级**：P1
- **依赖**：任务 2
- **描述**：在 OaiStreamHandler 函数中，获取并记录流式响应的 id 和 message 字段
- **成功标准**：能够在日志中看到流式响应的 id 和 message 字段
- **测试要求**：
  - `programmatic` TR-3.1：发送流式 /v1/chat/completions 请求，检查日志中是否包含 id 和 message 字段
  - `human-judgement` TR-3.2：检查日志格式是否清晰，信息是否完整

### 任务 4：修改其他模型处理函数，适配不同类型的模型

- **优先级**：P1
- **依赖**：任务 1-3
- **描述**：修改 VL模型、向量模型、重排模型等的处理函数，记录相应的输入和输出字段
- **成功标准**：能够在日志中看到不同类型模型的输入和输出字段
- **测试要求**：
  - `programmatic` TR-4.1：发送不同类型模型的请求，检查日志中是否包含相应的输入和输出字段
  - `human-judgement` TR-4.2：检查日志格式是否清晰，信息是否完整

### 任务 5：测试和优化

- **优先级**：P2
- **依赖**：任务 1-4
- **描述**：测试日志记录的性能和稳定性，优化日志格式和存储方式
- **成功标准**：日志记录不会影响系统性能和稳定性
- **测试要求**：
  - `programmatic` TR-5.1：发送大量请求，检查系统性能是否受到影响
  - `human-judgement` TR-5.2：检查日志存储是否合理，是否存在内存泄漏

## 技术实现细节

### 输入日志记录

在 `TextHelper` 函数中，获取 `info.Request` 作为 `*dto.GeneralOpenAIRequest` 类型，然后提取 `messages` 字段进行记录。

### 输出日志记录

在 `OpenaiHandler` 和 `OaiStreamHandler` 函数中，获取响应数据，然后提取 `id` 和 `message` 字段进行记录。

### 适配不同类型的模型

- **文本模型**：记录 `messages` 输入和 `message` 输出
- **VL模型**：记录包含图像的输入和相应的输出
- **向量模型**：记录输入文本和输出向量
- **重排模型**：记录输入文本和重排结果

### 日志存储方式

使用现有的 `model.RecordConsumeLog` 函数，将输入和输出信息存储到数据库中。

## 预期效果

- 能够在日志中看到用户输入的 prompt 和模型的输出
- 能够适配不同类型的模型
- 日志记录不会影响系统性能和稳定性

## 风险和注意事项

- 确保日志记录不会导致内存泄漏
- 确保日志记录不会影响响应时间
- 确保日志格式清晰，信息完整
- 确保适配不同类型的模型

## 结论

通过以上实现计划，我们可以对 new-api 的使用日志进行改造，记录用户的输入 prompt 以及模型的输出，同时适配不同类型的模型。