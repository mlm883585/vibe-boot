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
| 生产可管控 | 生产可禁用业务 AI 模型；开发型 AI 页面、API、路由和处理器不进入生产包 |

## 3. 不做事项

| 不做 | 原因 |
| --- | --- |
| 不做全供应商 SDK 适配 | P0 以 OpenAI 兼容协议覆盖主流模型 |
| 不做模型市场 | 首版只提供配置模板 |
| 不做向量数据库 | P1/P2 再评估上下文索引需求 |
| 不做复杂路由策略 | P0 手动选择默认模型 |
| 不做自动余额查询 | 不同供应商差异大 |
| 不做多租户额度 | 首版单企业内部系统 |
| 不做生产代码 Agent | 生产包不包含代码修改、脚本执行或开发任务入口 |

P0 虽不做复杂计费和模型路由，但必须具备最小成本防护：管理员能设置单次 token 上限、每日调用上限和基础限流，避免模型配置错误或循环任务造成不可控费用。

## 4. 支持范围

| 能力 | P0 |
| --- | --- |
| OpenAI 兼容 Chat Completions | 必做 |
| 国内模型 OpenAI 兼容接入 | 必做 |
| 模型连接测试 | 必做 |
| 流式响应 | P1；P0 固定使用非流式响应 |
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
| providerName | string | 响应派生 | 从 `ai_provider` 按 providerCode 获取，不由配置 DTO 写入 |
| apiBase | string | 是 | API Base，不含敏感参数 |
| apiKey | string | 创建时是、更新时否 | 只写请求字段；进入 Service 后立即加密，不记录、不回显 |
| credentialCiphertext | string | 数据库内部 | ADR-0002 格式的 AES-GCM 密文，禁止进入 Controller 响应 |
| credentialConfigured | boolean | 响应派生 | 只表示是否已有凭据，不包含密文或密钥片段 |
| modelName | string | 是 | 模型名 |
| modelType | string | 是 | P0 固定 `chat`；code/embedding 属于后续 schema 版本 |
| enabled | boolean | 是 | 是否启用 |
| timeoutSeconds | int | 是 | 默认 60 |
| maxTokens | int | 否 | 单次最大输出 token，默认 2048 |
| rateLimitPerMinute | int | 否 | 同一模型配置每分钟总调用上限，默认 30 |
| userRateLimitPerMinute | int | 否 | 同一用户 + 模型配置每分钟上限，默认 10 |
| dailyCallLimit | int | 否 | 同一模型配置按 `Asia/Shanghai` 自然日统计，默认 1000 |
| dailyTokenLimit | int | 否 | 同一模型配置按 `Asia/Shanghai` 自然日统计，默认 1000000；供应商不返回 token 时记录 unknown |
| remark | string | 否 | 备注 |

前端保存 API Key 后只能显示“已配置/未配置”。P0 不返回末四位，避免响应层继续接触可识别的密钥片段。

`providerCode` 必须规范化为 lowercase ASCII，并与预先分配的雪花 `configId` 一起进入 ADR-0002 的 AAD；两者创建后不可修改。需要更换供应商时新建模型配置。开发 profile 优先读取 `VIBEBOOT_MODEL_MASTER_KEY`，与 ignored local 配置同时存在但值不同时失败；生产 profile 只读取 `config/secrets/model-master.key`，检测到环境变量或 YAML 内嵌主密钥时启动失败。任一来源 Base64URL 解码后不是 32 bytes，返回 `AI_0503` 并阻断保存、测试和调用。

## 6. 供应商模板

| 模板 | P0 | 说明 |
| --- | --- | --- |
| OpenAI Compatible | 是 | 通用兼容模板 |
| DeepSeek | 是 | 国内常用，按 OpenAI 兼容方式配置 |
| 通义千问 | 可选 | 若使用 OpenAI 兼容地址则可配置 |
| 智谱 GLM | 可选 | 若使用 OpenAI 兼容地址则可配置 |
| 本地模型服务 | 仅开发可选 | 只允许回环地址上的 OpenAI 兼容接口；生产访问私网/本机模型属于 P1 网络安全决策 |

模板只提供默认 `providerCode`、名称和示例 `apiBase`，不内置用户密钥。

### 6.1 API Base 与 SSRF 防护

P0 后端固定使用 Spring `RestClient` + JDK `HttpClient`，不新增 OkHttp/Apache HttpClient。模型配置、连接测试和每次调用都必须执行同一套网络校验：

| 项目 | P0 固定规则 |
| --- | --- |
| URI 解析 | 使用 `java.net.URI`；原始值最长 2048 字符，必须是绝对 URI；禁止 userInfo、query、fragment、空 host、非法端口、路径 `..` 和双重编码绕过 |
| 协议 | 生产只允许 HTTPS；开发访问公网也只允许 HTTPS，HTTP 仅允许 host 为字面量 `127.0.0.1` 或 `[::1]` |
| 地址校验 | 保存、测试和调用前重新解析 DNS；生产要求全部 A/AAAA 地址均为公网单播，任一地址属于 loopback、私网、链路本地、组播、未指定、保留网段或云 metadata 地址即拒绝 |
| 重定向 | JDK `HttpClient.Redirect.NEVER`，任何 3xx 都按上游错误处理，不跟随到新地址 |
| TLS | 使用 JDK 默认信任链和主机名校验，禁止 trust-all、关闭 hostname verification 或把证书错误降级为警告 |
| 路径拼接 | 规范化 `apiBase` 后只追加固定 `/chat/completions`；不允许模型名、用户文本或响应头影响目标 URL |
| 响应上限 | 响应体按流读取且最多 2 MB，超限立即中止并返回 `AI_0500`；不得无界读取错误页或响应 |
| 失败语义 | 不安全/非法 API Base 在保存时返回 `AI_0400`；调用时 DNS 结果变为禁止地址返回 `AI_0502`，且不得发出网络请求 |

P0 不支持 HTTP/HTTPS 代理、生产私网模型地址或自定义 CA。需要企业代理、私有模型服务或私有 CA 时，必须先新增 P1 ADR，明确 DNS、证书、代理凭据和 egress allowlist。

## 7. 管理页面

| 页面 | 路由 | P0 控件 |
| --- | --- | --- |
| 模型配置 | `/ai/model-config` | 列表、新增、编辑、启用/禁用、测试连接 |
| 用量记录 | `/ai/usage-log` | 查询、表格、详情 |
| AI 任务 | `/ai/task` | P0 提供按状态筛选的任务列表和详情入口，与 AI 工作台共用任务数据 |

模型配置页面必须明确提示：

| 提示 | 说明 |
| --- | --- |
| API Key 保存后不可明文查看 | 响应只返回 `credentialConfigured`，防止明文、密文或末四位泄漏 |
| 境外模型可能涉及数据出境 | 接入境外供应商时提示 |
| 发送给模型的数据需最小化 | 不发送整库、完整日志、密钥文件或无关业务数据 |
| 生产固定禁用开发型 AI 能力 | 配置为 true 时启动失败，避免误以为生产可在线改代码 |

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
| GET | `/api/ai/providers` | enabled 供应商模板，按 sortOrder/id 排序 | `ai:modelConfig:query` |

创建请求必须携带非空 `apiKey`；更新请求省略或传空 `apiKey` 表示保留原凭据，传入新值表示重新加密替换。DELETE 固定执行逻辑删除：同一事务内禁用配置、清空 `credential_ciphertext`、设置 `deleted=1` 并递增 version，历史任务与用量日志保留引用。所有查询响应都必须删除 `apiKey` 与 `credentialCiphertext`，只返回 `credentialConfigured`。Controller、参数日志、操作日志和异常对象不得持有或序列化原始 API Key。

API 字段集合冻结如下。所有对象拒绝未知字段；除 `apiKey` 外字符串先 trim，Long ID 在 JSON 中使用 string。

| 对象 | 精确字段与校验 |
| --- | --- |
| `ModelConfigPageQuery` | `providerCode?`；`enabled? boolean`；`keyword? 1..100`，只匹配 modelName；`pageNo 1..100000`；`pageSize 1..100`；`sortField=id|modelName|createdAt`，默认 createdAt；`sortOrder=asc|desc`，默认 desc |
| `ModelConfigCreateDTO` | `providerCode:[a-z][a-z0-9-]{2,63}`；`apiBase 1..500`；`apiKey 1..8192`，不 trim；`modelName 1..128`；`modelType=chat`；`enabled:boolean`；`timeoutSeconds 1..300`；`maxTokens 1..32768`；`rateLimitPerMinute 1..10000`；`userRateLimitPerMinute 1..1000` 且不大于总限额；`dailyCallLimit 1..1000000`；`dailyTokenLimit 1..1000000000000`；`remark? <=500` |
| `ModelConfigUpdateDTO` | `apiBase/modelName/modelType/enabled/timeoutSeconds/maxTokens/rateLimitPerMinute/userRateLimitPerMinute/dailyCallLimit/dailyTokenLimit/remark/version`；可选 `apiKey 1..8192`，缺失或空字符串表示保留；不接受 providerCode/id/audit/credentialCiphertext |
| `ModelConfigStatusDTO` | `enabled:boolean`、`version:int>=0` |
| `ModelConfigVO` | `id/providerCode/providerName/apiBase/modelName/modelType/enabled/timeoutSeconds/maxTokens/rateLimitPerMinute/userRateLimitPerMinute/dailyCallLimit/dailyTokenLimit/remark/credentialConfigured/version/createdAt/updatedAt` |
| `ModelConnectionTestVO` | `status=success`、`latencyMs:long>=0`、`providerRequestId?:string<=128`、`testedAt:datetime`；不返回模型正文、请求消息或凭据 |
| `ProviderTemplateVO` | `providerCode/providerName/defaultApiBase/sortOrder`；不返回 disabled 模板、credential 或数据库审计字段 |

更新/状态/删除均使用 `id + version + deleted=0` 乐观锁；DELETE 的 version 固定使用 query 参数 `?version={int>=0}`，缺失返回 `VALID_0400`，冲突返回 `DATA_0409`。启用配置前必须成功执行与测试连接相同的 API Base、DNS、TLS 和凭据检查；失败时不得把 enabled 写为 true。创建/更新返回 `ModelConfigVO`，DELETE 返回 null，测试返回 `ModelConnectionTestVO`，分页返回 `PageResult<ModelConfigVO>`。

### 8.2 模型调用内部 API

模型调用优先作为后端内部服务，不直接暴露给普通业务前端。

| 服务方法 | 说明 |
| --- | --- |
| `chat(request)` | 普通非流式聊天调用 |
| `testConnection(configId)` | 测试配置 |
| `recordUsage(...)` | 记录供应商实际返回的用量；未返回 token 时写 null，不估算成精确值 |
| `encryptCredential(...)` / `decryptCredential(...)` | 仅在 `vibe-ai` 内部按 ADR-0002 处理凭据，解密结果不得跨越供应商调用边界 |

若后续暴露调试 API，必须仅管理员可用，并记录审计。

### 8.3 用量记录 API

| Method | Path | 说明 | 权限 |
| --- | --- | --- | --- |
| GET | `/api/ai/usage-logs/page` | 分页查询 | `ai:usageLog:list` |
| GET | `/api/ai/usage-logs/{id}` | 详情 | `ai:usageLog:query` |

P0 不提供删除用量记录。

| 对象 | 精确字段与校验 |
| --- | --- |
| `UsageLogPageQuery` | `modelConfigId?:string`；`taskId?:string`；`purpose?:clarify|plan|generate|review|business_qa|business_summary|business_classify|business_copy|business_analysis|connection_test`；`success?:boolean`；`errorCode?:string<=64`；`createdFrom?/createdTo?:ISO-8601 datetime` 且跨度≤31天；分页同上；`sortField=createdAt|durationMs|totalTokens`，默认 createdAt；`sortOrder=asc|desc`，默认 desc |
| `UsageLogVO` | `id/taskId/modelConfigId/providerCode/modelName/purpose/promptTokens/completionTokens/totalTokens/durationMs/success/errorCode/quotaResult/traceId/providerRequestId/createdBy/createdAt`；token 可为 null，不返回 prompt、completion、API Base 或凭据 |

用量详情也返回 `UsageLogVO`。列表和详情只能查看管理范围内的审计记录；P0 `ai:usageLog:list/query` 仅授予管理员角色，不提供按普通业务用户自行扩权的接口。

## 9. 调用协议

P0 使用 OpenAI 兼容 Chat Completions 风格。

| 请求字段 | 说明 |
| --- | --- |
| model | 模型名 |
| messages | system/user/assistant 消息 |
| temperature | P0 固定发送 `0.2`，不允许页面或任务任意覆盖 |
| max_tokens | P0 始终发送；取任务上限与模型配置 `maxTokens` 的较小值，任务未指定时使用模型配置值（默认 2048） |
| stream | P0 固定 false；true 视为不支持请求 |

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

| 上游情况 | 统一错误码 | HTTP | 中文提示 |
| --- | --- | --- | --- |
| 配置缺失或 API Base 非法/不安全 | `AI_0400` | 400 | 请检查模型配置和 API Base 安全规则 |
| API Key 无效 | `AI_0401` | 400 | 模型 API Key 无效或已过期 |
| 权限不足/余额不足 | `AI_0403` | 400 | 模型服务拒绝请求，请检查权限或余额 |
| 模型不存在 | `AI_0404` | 400 | 模型名称不存在或当前账号不可用 |
| 上下文过大 | `AI_0413` | 413 | 所选上下文超过 1 MB，请减少文件或内容 |
| 本地限流 | `AI_0428` | 429 | 当前模型调用过于频繁，请稍后重试 |
| 供应商限流 | `AI_0429` | 429 | 模型服务请求过于频繁，请稍后重试 |
| 本地配额耗尽 | `AI_0430` | 429 | 当前模型今日调用额度已用完，请调整配置或明日重试 |
| 响应格式异常、响应过大或未知上游错误 | `AI_0500` | 502 | 模型响应异常 |
| 网络失败或 DNS 安全校验失败 | `AI_0502` | 502 | 无法安全连接模型服务，请检查 API Base 和网络 |
| 凭据主密钥不可用 | `AI_0503` | 503 | 模型凭据无法解密，请联系管理员检查本机安全配置 |
| 超时 | `AI_0504` | 504 | 模型响应超时，请检查网络或调大超时时间 |

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
| quota_result | `allowed`、`blocked_minute`、`blocked_daily_call` 或 `blocked_daily_token` |
| trace_id | Vibe Boot 服务端 traceId，必填 |
| provider_request_id | 供应商 requestId，可空且不得替代 traceId |
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
| API Key 不明文返回 | 前端只显示 `credentialConfigured` 对应的“已配置/未配置” |
| API Key 不进入日志 | 请求、异常、审计均需脱敏 |
| API Key 不进入模型上下文 | 上下文构建必须排除密钥配置 |
| API Key 数据库存储 | 必须按 ADR-0002 使用 JDK AES-256-GCM；明文只在创建/更新和单次供应商调用的最短作用域存在 |
| 主密钥外置 | 开发 profile 为环境变量优先、ignored `model-local.yml` 备用；生产 profile 只允许 `config/secrets/model-master.key` 且 `model-prod.yml` 只保存路径；禁止进入数据库、Git、日志、AI 上下文、备份和默认生产包 |
| API 响应最小化 | 只返回 `credentialConfigured`，不返回明文、密文、末四位或主密钥 |
| 配置修改需权限 | 只有管理员或授权角色可修改 |
| 境外供应商提示 | 使用境外 API Base 时提示数据出境风险 |
| 数据最小化 | 请求体只包含任务必要上下文，禁止整库、完整日志和 secret 数据 |
| 数据策略确认 | sensitive 数据发送到境外或未知供应商前必须用户确认 |
| 生产开发能力关闭 | 生产 profile 强制 `vibe.ai.dev-tools-enabled=false`；检测到 true 必须启动失败，不能把它当作可由管理员开启的生产开关 |

最小限流和配额约束：

| 约束 | 说明 |
| --- | --- |
| 单次 maxTokens 生效 | 请求不得超过模型配置或任务配置上限 |
| 计数维度 | 同时检查 `(modelConfigId, minute)` 总量和 `(userId, modelConfigId, minute)` 用户量；固定窗口键带过期时间，Redis Lua 原子自增 |
| 每分钟限流 | 默认模型总量 30/min、单用户 10/min；任一超限返回 `AI_0428` 与 `Retry-After`，不调用供应商 |
| 每日上限 | 按 `Asia/Shanghai` 自然日统计模型配置总量；默认 1000 calls / 1000000 tokens，达到后返回 `AI_0430` 与 `resetAt` |
| 调用计数 | 进入供应商调用前即计入 dailyCallLimit；供应商返回 token 时原子累计，未返回则 token 记为 unknown，不伪造 0 |
| 管理员可调整 | 限流和配额属于模型配置的一部分 |
| 超限必须记录 | 超限也要写入用量或错误记录，便于审计 |

P0 密钥存储遵守 ADR-0002：供应商 API Key 必须加密写入数据库，外置主密钥与密文分离。开发脚本和生产安装只负责生成或接收主密钥，不保存供应商 API Key；P0 不允许回退为数据库明文、可逆“自定义编码”或仅靠字段名伪装的“受保护值”。

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
| 开发需求澄清 | 可用 | 不打包、不提供页面或 API |
| 业务问答 | 可选 | 可选 |
| 代码修改 | 可用，但需确认 | 不打包、不提供页面或 API |
| 脚本执行 | P1 开发模式评估 | 禁用 |
| 数据库结构修改 | 通过生成和迁移 | 禁用在线修改 |

生产环境启用业务 AI 时，仍必须遵守登录态、权限和数据权限。生产 profile 只允许连接测试以及问答、摘要、分类、文案、分析这组业务白名单；需求澄清、项目文档问答、代码计划、代码修改、交接包和验证摘要均属于开发链路，不能以“只读”或“管理员可选”的方式重新开放。

## 15. 质量门禁

| 门禁 | 验收方式 |
| --- | --- |
| 配置保存 | 能保存 OpenAI 兼容模型配置 |
| 密钥加密与响应最小化 | 数据库中不是明文；保存后前端只能看到 `credentialConfigured`；缺失或错误主密钥返回 `AI_0503` |
| 连接测试成功 | 有效配置返回中文成功提示 |
| 连接测试失败 | 错误 API Key/API Base 返回中文错误 |
| AI 工作台可调用 | 需求澄清能通过模型网关完成 |
| 用量记录 | 成功和失败调用均有记录 |
| 限流配额 | 本地限流、每日调用上限和 token 上限可配置，超限返回中文错误 |
| 用量摘要 | 用量页面能展示今日调用、token、失败次数和配额状态 |
| 权限控制 | 无权限用户不能修改模型配置 |
| 数据最小化 | secret 数据阻断，sensitive 数据脱敏或确认，日志不记录完整敏感请求体 |
| 数据出境提示 | 境外或未知供应商在配置和调用前均有中文提示 |
| 生产限制 | 生产包不打包开发型 AI 页面/API，profile 固定 false 且 true 时启动失败 |

## 16. 实现前准入

进入 S3 编码前必须确认：

| 条件 | 状态 |
| --- | --- |
| 模型字段 | 已由 ADR-0002 和本文确认 |
| OpenAI 兼容优先 | 已由 ADR-0001、AI 工具策略和本文确认 |
| API Key 策略 | 已由 ADR-0002、安全治理和本文确认 |
| 主密钥生成、存放、故障和轮换 | 已由 ADR-0002、安全治理和本文确认 |
| 错误码 | 已由本文补充 |
| 用量记录 | 已由本文确认 |
| 数据最小化和出境提示 | 已由 `docs/security-governance.md` 和本文确认 |
| 生产禁用策略 | 已由 ADR-0002 和本文确认 |

## 17. 一句话总结

模型网关的目标是让 Vibe Boot 可以安全、统一、可审计地使用大模型：配置集中、密钥受控、调用统一、错误中文化、用量可查，而不是把模型调用散落到各个业务模块里。
