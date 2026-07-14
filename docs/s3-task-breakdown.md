# Vibe Boot S3 模型网关任务分解

## 1. 文档目的

本文把 `docs/model-gateway-spec.md` 拆解为可执行的 S3 编码任务，明确任务顺序、依赖关系、交付物、验证方式和禁止越界项。

S3 的目标是让 Vibe Boot 能安全、统一、可审计地调用大模型。它不是 AI 工作台的完整实现，也不是通用模型平台。

## 2. S3 总目标

| 目标 | 验收口径 |
| --- | --- |
| 模型可配置 | 管理员可维护 OpenAI 兼容模型配置 |
| 连接可测试 | 有效配置返回成功，错误配置返回中文错误 |
| 调用可统一 | 后端内部服务统一调用模型，不散落 SDK 或 HTTP 细节 |
| 密钥可保护 | API Key 使用 ADR-0002 的 JDK AES-256-GCM 加密入库，主密钥外置，不明文返回前端、不打印日志、不进入 Git |
| 错误可理解 | 上游错误映射为统一错误码和中文提示 |
| 用量可审计 | 成功和失败调用均记录模型、耗时、token、错误 |
| 成本可控 | P0 支持单次 token 上限、每分钟限流、每日调用/token 上限和用量摘要 |
| 生产边界固定 | 生产包不包含开发型 AI 入口，profile 固定 false |

## 3. 前置条件

S3 应在 S2 基础后台后实施，至少依赖认证、权限、菜单和操作日志能力。

| 前置项 | 要求 |
| --- | --- |
| S1 工程骨架 | 后端、前端、脚本基础已存在 |
| S2 基础后台 | 登录、权限、菜单、操作日志可用 |
| 阶段签收与启动 | S2 阶段关闭证据已通过，`stageAdmission` 记录完整，并收到精确口令 `开始 S3 模型网关编码`；本文本身不是当前编码许可 |
| 数据库迁移 | Flyway 已可执行 |
| 权限模型 | `ai:modelConfig:*`、`ai:usageLog:*` 可写入菜单权限 |
| 前端布局 | 管理端菜单、动态路由、权限按钮可用 |
| 文档确认 | `model-gateway-spec.md`、`security-governance.md`、`quality-gates.md` 已确认 |

## 4. 任务顺序

| 顺序 | 任务 | 主要产物 | 依赖 |
| --- | --- | --- | --- |
| 1 | AI 数据表与初始菜单 | `ai_provider`、`ai_model_config`、`ai_usage_log`、菜单权限 | S2 菜单权限 |
| 2 | 密钥与脱敏基础 | AES-GCM 凭据服务、外置主密钥校验、响应最小化、日志脱敏工具 | 安全治理 |
| 3 | 模型配置后端 API | 配置 CRUD、启用禁用、权限校验 | 数据表与安全基础 |
| 4 | OpenAI 兼容调用服务 | 统一请求对象、HTTP 调用、超时、响应解析 | 配置 API |
| 5 | 连接测试能力 | 测试配置、成功/失败中文反馈 | 调用服务 |
| 6 | 错误码与异常映射 | `AI_0401`、`AI_0429`、`AI_0504` 等 | 调用服务 |
| 7 | 用量记录 | 成功/失败、token、耗时、错误码、调用人 | 调用服务 |
| 8 | 限流与配额控制 | maxTokens、rateLimitPerMinute、userRateLimitPerMinute、dailyCallLimit、dailyTokenLimit | 用量记录 |
| 9 | 前端模型配置页面 | 列表、新增、编辑、启用禁用、测试连接、限流配额字段 | 后端 API |
| 10 | 前端用量记录页面 | 分页、详情、状态、错误原因、今日摘要、配额状态 | 用量 API |
| 11 | 生产限制与验收 | dev-tools 开关、权限检查、门禁验证 | 全部 S3 功能 |

## 5. 任务明细

### 5.1 AI 数据表与初始菜单

| 项目 | 要求 |
| --- | --- |
| `ai_provider` | 供应商模板，P0 可只保存模板信息 |
| `ai_model_config` | 模型配置、API Base、`credential_ciphertext`、启用状态；不得保存主密钥或明文 API Key |
| `ai_usage_log` | 模型调用用量、耗时、成功失败、错误码 |
| 初始菜单 | AI 管理、模型配置、用量记录 |
| 初始权限 | `ai:modelConfig:*`、`ai:usageLog:*` |
| 迁移方式 | Flyway 版本化 SQL |

P0 不创建向量库、知识库、复杂路由策略相关表。

### 5.2 密钥与脱敏基础

| 能力 | P0 要求 |
| --- | --- |
| 保存策略 | 遵守 ADR-0002，API Key 必须使用 JDK `AES/GCM/NoPadding` 加密后写入数据库 |
| 主密钥 | 32-byte 随机值；开发 profile 使用环境变量优先、ignored local 配置备用，生产 profile 只读 `config/secrets/model-master.key`；不进入数据库 |
| 数据库保存 | 只保存版本化 `credential_ciphertext`，不得保存明文或主密钥 |
| 前端展示 | 响应只返回 `credentialConfigured`，页面显示“已配置/未配置” |
| 日志脱敏 | API Key、Token、密码、数据库密码不得打印 |
| 上下文排除 | 模型配置密钥不得进入 AI 上下文 |

P0 不允许把加密降级为 Base64、自定义异或、数据库明文或“先做日志脱敏后续再加密”。主密钥缺失、格式错误或解密失败时返回 `AI_0503`，并阻断保存、测试和模型调用。

### 5.3 模型配置后端 API

| API | 要求 |
| --- | --- |
| 分页查询 | 支持 providerCode、modelName、enabled 查询 |
| 详情 | 不返回明文或密文，只返回 `credentialConfigured` |
| 创建 | 校验必填字段、API Base 和非空 API Key；在 Service 最短作用域内加密 |
| 更新 | API Key 为空时保留原密文，非空时使用新 IV 重新加密 |
| 删除 | P0 固定逻辑删除：同一事务内先禁用、清空 `credential_ciphertext`、设置 `deleted=1` 并递增 version；历史任务和用量日志保留引用，不做物理删除 |
| 启用禁用 | 禁用后不可被调用 |
| 测试连接 | 见 5.5 |

后端实现必须遵守 `docs/backend-implementation-spec.md`，所有接口必须有权限控制和操作日志。

### 5.4 OpenAI 兼容调用服务

| 能力 | 要求 |
| --- | --- |
| 统一请求对象 | `modelConfigId`、`purpose`、`messages`、`timeoutSeconds`、`metadata` |
| 协议 | P0 使用 OpenAI 兼容 Chat Completions |
| 调用方式 | 固定 Spring `RestClient` + JDK `HttpClient`，禁用重定向并执行模型网关 SSRF 校验；不让业务代码拼供应商 JSON |
| 超时 | 使用配置超时，默认 60 秒 |
| temperature | P0 固定 `0.2`，页面和任务不得覆盖 |
| maxTokens | 始终发送模型配置值与任务上限的较小值；任务未指定时使用模型配置值，默认 2048 |
| 限流 | 调用前同时检查模型配置总量 30/min 和用户 + 模型配置 10/min 的默认固定窗口上限 |
| 每日配额 | 按 `Asia/Shanghai` 自然日检查模型配置级 dailyCallLimit=1000、dailyTokenLimit=1000000 默认值 |
| 响应解析 | 提取文本、token、供应商 requestId |
| 响应上限 | 流式读取最多 2 MB，超限返回 `AI_0500` |
| 非流式 | P0 固定 `stream=false`，流式响应 P1 |

业务模块和 AI 工作台不得直接调用供应商 API。

用户选择文件作为模型上下文时，S3 只能读取 S2 `vibe-file` 中状态为 `active`、当前用户有权下载的 `txt/md/csv/json`。必须由用户逐个明确选择，单次送模文件内容合计不超过 1 MB，并在读取后再次执行 UTF-8 校验、数据分类、secret 扫描、脱敏和出境风险提示。超过 1 MB 返回 `AI_0413`，不得静默截断。P0 不解析 PDF、图片或其他类型，不允许根据 storage path 直接读盘，也不自动附加用户历史上传文件。

### 5.5 连接测试能力

| 场景 | 结果 |
| --- | --- |
| API Base 可访问、Key 有效、模型存在 | 返回中文成功提示 |
| API Key 错误 | 返回 `AI_0401` 和中文原因 |
| 模型名错误 | 返回 `AI_0404` |
| 限流 | 返回 `AI_0429` |
| 网络不通 | 返回 `AI_0502` |
| 超时 | 返回 `AI_0504` |

连接测试必须写入用量记录或测试记录，至少能在日志中定位失败原因，但不得记录密钥。

### 5.6 错误码与异常映射

| 错误码 | 含义 |
| --- | --- |
| `AI_0400` | HTTP 400；未配置、配置不完整或 API Base 非法/不安全 |
| `AI_0401` | HTTP 400；供应商 API Key 无效或过期，不得映射成 Vibe Boot 登录失效 |
| `AI_0403` | HTTP 400；供应商拒绝请求、权限或余额不足 |
| `AI_0404` | HTTP 400；供应商模型不存在或不可用 |
| `AI_0413` | HTTP 413；所选模型上下文超过 1 MB |
| `AI_0428` | HTTP 429；本地限流，调用过于频繁 |
| `AI_0429` | HTTP 429；供应商限流 |
| `AI_0430` | HTTP 429；本地配额耗尽 |
| `AI_0500` | HTTP 502；响应格式异常、响应超过 2 MB 或未知上游错误 |
| `AI_0502` | HTTP 502；网络连接或 DNS 安全校验失败 |
| `AI_0503` | HTTP 503；模型凭据主密钥缺失、格式错误或无法解密 |
| `AI_0504` | HTTP 504；模型响应超时 |

异常响应遵守 `docs/api-conventions.md`，必须包含 traceId。

### 5.7 用量记录

| 字段 | 要求 |
| --- | --- |
| task_id | 可为空，AI 工作台任务接入后写入 |
| model_config_id | 必填 |
| provider_code | 必填 |
| model_name | 必填 |
| purpose | clarify/plan/test/business 等 |
| prompt_tokens | 供应商返回则记录 |
| completion_tokens | 供应商返回则记录 |
| duration_ms | 必填 |
| success | 必填 |
| error_code | 失败时记录 |
| created_by | 当前用户 |
| trace_id | Vibe Boot 服务端 traceId，必填 |
| provider_request_id | 供应商 requestId，可空且不得替代 traceId |
| quota_result | 固定枚举 `allowed`、`blocked_minute`、`blocked_daily_call`、`blocked_daily_token`，必填 |

若供应商不返回 token，P0 可记录 null，并在前端显示“供应商未返回”。

### 5.7.1 限流与配额控制

| 控制项 | P0 要求 |
| --- | --- |
| 单次输出上限 | `maxTokens` 必须参与请求构建 |
| 模型配置限流 | `rateLimitPerMinute` 默认 30，对 `(modelConfigId, minute)` 生效 |
| 用户限流 | `userRateLimitPerMinute` 默认 10，对 `(userId, modelConfigId, minute)` 生效 |
| 每日调用上限 | `dailyCallLimit` 默认 1000，按模型配置和 `Asia/Shanghai` 自然日统计，调用供应商前计数 |
| 每日 token 上限 | `dailyTokenLimit` 默认 1000000；供应商返回 token 时原子累计，未返回时显示 unknown |
| 超限记录 | 分钟超限返回 `AI_0428` + `Retry-After`；每日超限返回 `AI_0430` + `resetAt`，并写入失败记录 |
| 原子性 | Redis Lua/EVALSHA 完成检查、自增和 TTL 设置；生产 Redis 故障时不得退回进程内计数 |

### 5.8 前端模型配置页面

| 页面能力 | 要求 |
| --- | --- |
| 列表 | 供应商、模型名、类型、启用状态、更新时间 |
| 新增/编辑 | API Base、API Key、模型名、超时、maxTokens、备注 |
| 限流配额 | maxTokens、模型每分钟上限、用户每分钟上限、每日调用上限、每日 token 上限及冻结默认值 |
| API Key | 保存后只显示“已配置/未配置”，不得返回明文、密文或末四位 |
| 测试连接 | 按钮触发并展示中文结果 |
| 启用禁用 | 禁用需确认 |
| 权限按钮 | 使用统一权限组件 |
| 风险提示 | 境外 API Base 提示数据出境风险 |

页面遵守 `docs/frontend-admin-spec.md`，不做复杂模型市场。

### 5.9 前端用量记录页面

| 页面能力 | 要求 |
| --- | --- |
| 查询 | 模型、用途、成功失败、时间范围 |
| 列表 | 模型名、用途、token、耗时、状态、调用人、时间 |
| 详情 | 错误码、中文错误、traceId 或 requestId |
| 今日摘要 | 今日调用、token、失败次数、配额状态 |
| 删除 | P0 不提供删除 |

### 5.10 生产限制与配置开关

| 配置 | 要求 |
| --- | --- |
| `vibe.ai.enabled` | 控制 AI 总开关 |
| `vibe.ai.dev-tools-enabled` | 开发 profile 可配置；生产 profile 固定 false，配置为 true 必须启动失败 |
| `vibe.ai.allow-overseas-provider` | P1 可引入，P0 先做提示 |
| `vibe.ai.default-model-config-id` | 可不配置；未配置时用户必须显式选择启用模型，指向不存在/禁用/已删除模型时配置校验失败 |

生产模式可以配置业务 AI，但不得启用代码修改、脚本执行、数据库结构修改能力。

## 6. 后端交付物

| 模块 | 交付 |
| --- | --- |
| `vibe-ai` | 模型配置、模型调用、用量记录、错误映射 |
| `vibe-common` | 脱敏工具、统一异常补充 |
| `vibe-security` | 模型配置权限控制、当前用户上下文复用 |
| `vibe-starter` | AI 配置项、Flyway 迁移装配 |
| `vibe-system` | 菜单权限初始化和操作日志复用 |

## 7. 前端交付物

| 目录 | 交付 |
| --- | --- |
| `src/api/ai/modelConfig.ts` | 模型配置 API |
| `src/api/ai/usageLog.ts` | 用量记录 API |
| `src/views/ai/model-config` | 模型配置页面 |
| `src/views/ai/usage-log` | 用量记录页面 |
| 前端状态 | S3 不新增模型全局 Store；默认模型来自后端配置，页面筛选和编辑草稿使用组件本地状态，S4 再创建统一 `src/stores/ai.ts` |
| `src/utils` | 脱敏展示、连接测试状态展示辅助 |

## 8. 权限清单

| 领域 | 权限 |
| --- | --- |
| 模型配置 | `ai:modelConfig:list`、`ai:modelConfig:query`、`ai:modelConfig:create`、`ai:modelConfig:update`、`ai:modelConfig:delete`、`ai:modelConfig:test` |
| 用量记录 | `ai:usageLog:list`、`ai:usageLog:query` |

模型配置修改属于高价值配置变更，必须记录操作日志。

## 9. S3 禁止越界项

| 禁止 | 原因 |
| --- | --- |
| 做完整 AI 工作台 | S3 只做模型网关，工作台基础属于 S4 子任务 |
| 做代码生成器 | S4 范围 |
| 做向量数据库/RAG | P1/P2 范围 |
| 做复杂模型路由 | P1 范围 |
| 做模型市场 | 偏离 MVP |
| 直接引入多个供应商 SDK | 破坏 OpenAI 兼容优先和技术栈克制 |
| 生产启用代码 Agent | 违反安全治理 |
| 把 API Key 明文返回前端 | 安全风险 |

## 10. 验证门禁

S3 完成后必须满足：

| 门禁 | 验收方式 |
| --- | --- |
| 后端完整验证 | `scripts/mvn.ps1 -pl vibe-starter -am test` 全部通过；模型配置、密钥最小响应、SSRF/DNS、限流、连接测试和用量接口有本地 stub + MockMvc 正反用例，快速构建不得关闭 S3 |
| 前端构建 | `npm run build` |
| 配置保存 | OpenAI 兼容模型配置可保存 |
| 密钥加密 | 数据库不含明文，API 只返回 `credentialConfigured`，错误主密钥返回 `AI_0503` |
| 连接测试成功 | 有效配置返回中文成功提示 |
| 连接测试失败 | 错误 API Key/API Base 返回中文错误 |
| 用量记录 | 成功和失败调用均有记录 |
| 限流配额 | 本地限流和每日上限生效，超限返回中文错误 |
| 用量摘要 | 前端能看到今日调用、token、失败次数和配额状态 |
| 权限控制 | 无权限用户不能修改模型配置 |
| 生产限制 | 生产包不包含开发型 AI 页面/API，配置为 true 必须启动失败 |

## 11. AI 实现提示

外部 AI Coding 工具执行 S3 时必须遵守：

| 规则 | 说明 |
| --- | --- |
| 先读文档 | `docs/README.md`、本文、`model-gateway-spec.md`、安全治理和质量门禁 |
| 不扩成 Agent | S3 只做模型配置、调用和用量 |
| 不散落 SDK | 所有模型调用经过 `vibe-ai` 模型网关 |
| 密钥最小暴露 | 不在日志、前端响应、模型上下文中出现明文密钥 |
| 错误中文化 | 上游错误必须转换为中文可读信息 |
| 生成后验证 | 后端/前端构建和连接测试结果必须写入摘要 |

## 12. 完成定义

S3 只有在以下条件同时满足时才算完成：

| 条件 | 说明 |
| --- | --- |
| 配置闭环 | 管理员可新增、编辑、禁用、测试模型配置 |
| 调用闭环 | 后端内部服务可通过模型网关发起 OpenAI 兼容调用 |
| 安全闭环 | 密钥不明文暴露，操作有权限和审计 |
| 用量闭环 | 成功和失败调用都可追踪 |
| 成本防护闭环 | 单次上限、每分钟限流、每日上限和超限错误可验证 |
| 前端闭环 | 模型配置和用量记录页面可用 |
| 生产边界 | 开发型 AI 能力不进入生产包，不能通过配置恢复 |
| 验证通过 | S3 质量门禁满足 |

## 13. 一句话总结

S3 模型网关要先把“模型怎么配、怎么测、怎么调、怎么记账、怎么保护密钥”做稳。只有这层稳定，后续 AI 工作台、代码生成和业务 AI 才不会把模型调用散落成不可治理的暗线。
