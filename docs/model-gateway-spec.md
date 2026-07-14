# Vibe Boot 模型网关规格

## 1. 文档目的

本文定义 Vibe Boot S3 阶段模型网关的产品边界、配置字段、管理页面、API、调用协议、错误处理、用量统计、安全约束和验收标准。

模型网关不是通用大模型平台，也不是复杂 Agent 编排系统。它只负责把 Vibe Boot AI 工作台和业务 AI 能力需要的模型调用统一起来，避免模型 SDK、API Key、错误处理和用量统计散落在业务代码中。

## 2. S3 目标

| 目标 | 说明 |
| --- | --- |
| 模型可配置 | 管理员能配置供应商、API Base、模型名、超时和启用状态 |
| 连接可测试 | 保存配置前后都能测试模型是否可用 |
| 调用可统一 | AI 工作台只通过模型网关调用模型 |
| 密钥可保护 | API Key 不进入 Git、不明文返回前端、不打印日志 |
| 错误可理解 | 上游错误转换为中文可读错误 |
| 用量可审计 | 记录模型、token、耗时、成功失败、关联任务 |
| 生产可管控 | 生产模式可禁用开发型 AI 能力 |

## 3. 不做事项

| 不做 | 原因 |
| --- | --- |
| 不做全供应商 SDK 适配 | P0 以 OpenAI 兼容协议覆盖主流模型 |
| 不做模型市场 | 首版只提供配置模板 |
| 不做向量数据库 | P1/P2 再评估上下文索引需求 |
| 不做复杂路由策略 | P0 手动选择默认模型 |
| 不做自动余额查询 | 不同供应商差异大 |
| 不做多租户额度 | 首版单企业内部系统 |
| 不做生产代码 Agent | 生产默认禁用代码修改和脚本执行 |

P0 虽不做复杂计费和模型路由，但必须具备最小成本防护：管理员能设置单次 token 上限、每日调用上限和基础限流，避免模型配置错误或循环任务造成不可控费用。

## 4. 支持范围

| 能力 | P0 |
| --- | --- |
| OpenAI 兼容 Chat Completions | 必做 |
| 国内模型 OpenAI 兼容接入 | 必做 |
| 模型连接测试 | 必做 |
| 流式响应 | 可选，P0 可先非流式 |
| Embedding | P1 |
| 图片/多模态 | P2 |
| Function Calling/Tools | P1 |
| 多模型自动降级 | P1 |

P0 的关键判断是：只要用户能填入兼容 OpenAI API 的 `apiBase`、`apiKey` 和 `modelName`，AI 工作台就能完成需求澄清和计划生成。

## 5. 配置模型

模型配置字段以 ADR-0002 为准。

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| providerCode | string | 是 | 供应商编码，如 `openai-compatible`、`deepseek` |
| providerName | string | 是 | 供应商名称 |
| apiBase | string | 是 | API Base，不含敏感参数 |
| apiKeyEncrypted | string | 是 | 加密或受保护后的 API Key |
| modelName | string | 是 | 模型名 |
| modelType | string | 是 | `chat`、`code`、`embedding`，P0 主要使用 `chat` |
| enabled | boolean | 是 | 是否启用 |
| timeoutSeconds | int | 是 | 默认 60 |
| maxTokens | int | 否 | 单次最大输出 token |
| dailyCallLimit | int | 否 | 单日调用上限，P0 可按模型配置统计 |
| dailyTokenLimit | int | 否 | 单日 token 上限，供应商不返回 token 时只做提示 |
| rateLimitPerMinute | int | 否 | 每分钟调用上限 |
| remark | string | 否 | 备注 |

前端保存 API Key 后，只能显示脱敏值，例如 `sk-****abcd` 或 `已配置`。

## 6. 供应商模板

| 模板 | P0 | 说明 |
| --- | --- | --- |
| OpenAI Compatible | 是 | 通用兼容模板 |
| DeepSeek | 是 | 国内常用，按 OpenAI 兼容方式配置 |
| 通义千问 | 可选 | 若使用 OpenAI 兼容地址则可配置 |
| 智谱 GLM | 可选 | 若使用 OpenAI 兼容地址则可配置 |
| 本地模型服务 | 可选 | 只要暴露 OpenAI 兼容接口 |

模板只提供默认 `providerCode`、名称和示例 `apiBase`，不内置用户密钥。

## 7. 管理页面

| 页面 | 路由 | P0 控件 |
| --- | --- | --- |
| 模型配置 | `/ai/model-config` | 列表、新增、编辑、启用/禁用、测试连接 |
| 用量记录 | `/ai/usage-log` | 查询、表格、详情 |
| AI 任务 | `/ai/task` | P0 可从 AI 工作台进入，不必做复杂列表 |

模型配置页面必须明确提示：

| 提示 | 说明 |
| --- | --- |
| API Key 保存后不可明文查看 | 防止误泄漏 |
| 境外模型可能涉及数据出境 | 接入境外供应商时提示 |
| 发送给模型的数据需最小化 | 不发送整库、完整日志、密钥文件或无关业务数据 |
| 生产默认禁用开发型 AI 能力 | 避免误以为生产可在线改代码 |

## 8. API 范围

所有 API 遵守 `docs/api-conventions.md`。

### 8.1 模型配置 API

| Method | Path | 说明 | 权限 |
| --- | --- | --- | --- |
| GET | `/api/ai/model-configs/page` | 分页查询 | `ai:modelConfig:list` |
| GET | `/api/ai/model-configs/{id}` | 详情 | `ai:modelConfig:query` |
| POST | `/api/ai/model-configs` | 创建 | `ai:modelConfig:create` |
| PUT | `/api/ai/model-configs/{id}` | 更新 | `ai:modelConfig:update` |
| DELETE | `/api/ai/model-configs/{id}` | 删除 | `ai:modelConfig:delete` |
| PUT | `/api/ai/model-configs/{id}/status` | 启用/禁用 | `ai:modelConfig:update` |
| POST | `/api/ai/model-configs/{id}/test` | 测试连接 | `ai:modelConfig:test` |

### 8.2 模型调用内部 API

模型调用优先作为后端内部服务，不直接暴露给普通业务前端。

| 服务方法 | 说明 |
| --- | --- |
| `chat(request)` | 普通非流式聊天调用 |
| `testConnection(configId)` | 测试配置 |
| `estimateOrRecordUsage(...)` | 记录用量 |
| `maskSecret(...)` | 脱敏展示 |

若后续暴露调试 API，必须仅管理员可用，并记录审计。

### 8.3 用量记录 API

| Method | Path | 说明 | 权限 |
| --- | --- | --- | --- |
| GET | `/api/ai/usage-logs/page` | 分页查询 | `ai:usageLog:list` |
| GET | `/api/ai/usage-logs/{id}` | 详情 | `ai:usageLog:query` |

P0 不提供删除用量记录。

## 9. 调用协议

P0 使用 OpenAI 兼容 Chat Completions 风格。

| 请求字段 | 说明 |
| --- | --- |
| model | 模型名 |
| messages | system/user/assistant 消息 |
| temperature | 可选，默认由任务类型决定 |
| max_tokens | 可选，对应 `maxTokens` |
| stream | P0 默认 false |

模型网关内部请求对象使用统一字段，不让业务代码拼供应商 JSON。

| 内部字段 | 说明 |
| --- | --- |
| modelConfigId | 模型配置 ID |
| taskId | AI 任务 ID，可为空 |
| purpose | clarify/plan/generate/review 等 |
| systemPrompt | 系统提示词 |
| messages | 消息列表 |
| timeoutSeconds | 本次超时 |
| metadata | 任务上下文摘要，不含密钥 |
| dataClasses | 本次请求涉及的数据分类摘要：public/internal/sensitive/secret |
| redactionPolicy | 本次请求使用的脱敏和最小化策略 |
| providerRegionRisk | 供应商区域或数据出境风险提示 |

模型网关调用前必须执行上下文安全检查。

| 检查项 | P0 处理 |
| --- | --- |
| secret 数据 | 阻断调用，提示移除密钥或本地配置 |
| sensitive 数据 | 默认脱敏或摘要化；未确认供应商数据策略时阻断 |
| 业务数据 | 生产模式必须先经过登录态、权限和数据范围过滤 |
| 日志和异常 | 不允许把完整日志或完整异常堆栈直接作为模型输入 |
| 用户上传文件 | P0 只允许用户明确选择 `txt/md/csv/json` 文件；读取前再次鉴权、分类、secret 扫描和风险提示，单次送模内容最多 1 MB |

P0 不自动解析 PDF、图片、Office、压缩包或音视频，不做 OCR。文件上传成功不表示允许进入模型上下文；模型网关只能按文件 ID 读取当前用户有权访问且状态为 `active` 的文本文件，禁止读取 storage path、遍历文件目录或把未选择附件自动拼入上下文。合计超过 1 MB 时返回 `AI_0413`，不得静默截断后继续调用。

## 10. 错误处理

| 上游情况 | 统一错误码 | 中文提示 |
| --- | --- | --- |
| API Key 无效 | `AI_0401` | 模型 API Key 无效或已过期 |
| 权限不足/余额不足 | `AI_0403` | 模型服务拒绝请求，请检查权限或余额 |
| 模型不存在 | `AI_0404` | 模型名称不存在或当前账号不可用 |
| 限流 | `AI_0429` | 模型服务请求过于频繁，请稍后重试 |
| 超时 | `AI_0504` | 模型响应超时，请检查网络或调大超时时间 |
| 网络失败 | `AI_0502` | 无法连接模型服务，请检查 API Base 和网络 |
| 响应格式异常 | `AI_0500` | 模型响应格式异常 |
| 未配置模型 | `AI_0400` | 请先配置并启用模型 |
| 上下文过大 | `AI_0413` | 所选上下文超过 1 MB，请减少文件或内容 |
| 本地限流 | `AI_0428` | 当前模型调用过于频繁，请稍后重试 |
| 本地配额耗尽 | `AI_0430` | 当前模型今日调用额度已用完，请调整配置或明日重试 |

错误日志可记录供应商状态码和 requestId，但不得记录 API Key、完整敏感请求体。

失败降级语义：

| 场景 | P0 处理 |
| --- | --- |
| 未配置模型 | 工作台任务进入 blocked，提示先配置模型 |
| 模型连接失败 | 保留用户输入和上下文摘要，不生成空计划 |
| 限流或配额耗尽 | 任务进入 blocked 或 waiting_confirm，提示稍后重试或切换配置 |
| 超时 | 允许用户重试，但必须保留失败记录 |
| 供应商不返回 token | 用量详情显示“供应商未返回用量”，不得估算成精确成本 |

## 11. 用量统计

`ai_usage_log` 至少记录：

| 字段 | 说明 |
| --- | --- |
| id | 雪花 ID |
| task_id | AI 任务 ID，可为空 |
| model_config_id | 模型配置 ID |
| provider_code | 供应商编码 |
| model_name | 模型名 |
| purpose | 调用目的 |
| prompt_tokens | 输入 token |
| completion_tokens | 输出 token |
| total_tokens | 总 token |
| duration_ms | 耗时 |
| success | 是否成功 |
| error_code | 失败错误码 |
| created_by | 调用用户 |
| created_at | 调用时间 |

若供应商不返回 token，P0 可记录为 null，并在详情中标记“供应商未返回用量”。

P0 用量摘要：

| 维度 | 要求 |
| --- | --- |
| 今日调用次数 | 按模型配置、用户、purpose 统计 |
| 今日 token | 供应商返回 token 时统计；未返回时显示未知 |
| 失败次数 | 按错误码统计，便于定位配置或网络问题 |
| 最近失败 | 展示错误码、中文原因、traceId 或 requestId |
| 配额状态 | 展示未配置、正常、接近上限、已超限 |

P0 不承诺精确人民币成本计算，但必须能让管理员看出“哪个模型、哪个用途、哪个用户”在消耗模型调用。

## 12. 安全约束

| 约束 | 说明 |
| --- | --- |
| API Key 不明文返回 | 前端只显示脱敏值 |
| API Key 不进入日志 | 请求、异常、审计均需脱敏 |
| API Key 不进入模型上下文 | 上下文构建必须排除密钥配置 |
| 配置修改需权限 | 只有管理员或授权角色可修改 |
| 境外供应商提示 | 使用境外 API Base 时提示数据出境风险 |
| 数据最小化 | 请求体只包含任务必要上下文，禁止整库、完整日志和 secret 数据 |
| 数据策略确认 | sensitive 数据发送到境外或未知供应商前必须用户确认 |
| 生产开发能力关闭 | `vibe.ai.dev-tools-enabled=false` 时禁止代码级任务 |

最小限流和配额约束：

| 约束 | 说明 |
| --- | --- |
| 单次 maxTokens 生效 | 请求不得超过模型配置或任务配置上限 |
| 每分钟限流 | 对同一模型配置或同一用户做基础限流 |
| 每日上限 | 达到 dailyCallLimit 或 dailyTokenLimit 时阻止继续调用 |
| 管理员可调整 | 限流和配额属于模型配置的一部分 |
| 超限必须记录 | 超限也要写入用量或错误记录，便于审计 |

P0 密钥存储遵守 ADR-0002：ignored local 配置 + 日志脱敏。若写入数据库，应存储加密或受保护值，不能明文存储。

## 13. 与 AI 工作台的关系

| AI 工作台动作 | 模型网关职责 |
| --- | --- |
| 需求澄清 | 提供 chat 调用和用量记录 |
| 生成计划 | 提供 chat 调用、错误中文化 |
| 风险解释 | 提供 chat 调用 |
| 代码生成摘要 | 提供 chat 调用 |
| 任务审计 | 返回模型、token、耗时、成功失败 |

AI 工作台不得直接读取 API Key，也不得直接调用供应商 SDK。

## 14. 与生产模式的关系

| 能力 | 开发模式 | 生产模式 |
| --- | --- | --- |
| 配置模型 | 可用 | 管理员可用 |
| 测试连接 | 可用 | 管理员可用 |
| 需求澄清 | 可用 | 可选 |
| 业务问答 | 可选 | 可选 |
| 代码修改 | 可用，但需确认 | 默认禁用 |
| 脚本执行 | P1 开发模式评估 | 禁用 |
| 数据库结构修改 | 通过生成和迁移 | 禁用在线修改 |

生产环境启用业务 AI 时，仍必须遵守登录态、权限和数据权限。

## 15. 质量门禁

| 门禁 | 验收方式 |
| --- | --- |
| 配置保存 | 能保存 OpenAI 兼容模型配置 |
| 密钥脱敏 | 保存后前端不能看到明文 API Key |
| 连接测试成功 | 有效配置返回中文成功提示 |
| 连接测试失败 | 错误 API Key/API Base 返回中文错误 |
| AI 工作台可调用 | 需求澄清能通过模型网关完成 |
| 用量记录 | 成功和失败调用均有记录 |
| 限流配额 | 本地限流、每日调用上限和 token 上限可配置，超限返回中文错误 |
| 用量摘要 | 用量页面能展示今日调用、token、失败次数和配额状态 |
| 权限控制 | 无权限用户不能修改模型配置 |
| 数据最小化 | secret 数据阻断，sensitive 数据脱敏或确认，日志不记录完整敏感请求体 |
| 数据出境提示 | 境外或未知供应商在配置和调用前均有中文提示 |
| 生产限制 | 生产 profile 下开发型 AI 能力默认关闭 |

## 16. 实现前准入

进入 S3 编码前必须确认：

| 条件 | 状态 |
| --- | --- |
| 模型字段 | 已由 ADR-0002 和本文确认 |
| OpenAI 兼容优先 | 已由 ADR-0001、AI 工具策略和本文确认 |
| API Key 策略 | 已由 ADR-0002、安全治理和本文确认 |
| 错误码 | 已由本文补充 |
| 用量记录 | 已由本文确认 |
| 数据最小化和出境提示 | 已由 `docs/security-governance.md` 和本文确认 |
| 生产禁用策略 | 已由 ADR-0002 和本文确认 |

## 17. 一句话总结

模型网关的目标是让 Vibe Boot 可以安全、统一、可审计地使用大模型：配置集中、密钥受控、调用统一、错误中文化、用量可查，而不是把模型调用散落到各个业务模块里。
