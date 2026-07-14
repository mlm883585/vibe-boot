# Vibe Boot 编码前读者测试

## 1. 文档目的

本文用于测试新维护者、外部 AI Coding 工具或平台内 AI 工作台是否真正理解当前文档体系。

它不是新的需求来源，也不是编码许可。它的作用是在进入 S1 编码前，用一组问题验证读者能否从现有文档中得出正确结论：当前是否已签收、是否允许编码、S1 只能做什么、哪些请求必须拒绝。

## 2. 使用方式

| 使用者 | 使用方式 |
| --- | --- |
| 维护者 | 在签收 `docs/coding-start-signoff.md` 前自查 |
| 外部 AI Coding 工具 | 在收到“开始 S1 工程骨架编码”前自测 |
| 平台内 AI 工作台 | 在展示任务上下文摘要时检查边界 |
| 后续审计者 | 检查文档是否仍能正确指导编码入口 |

## 3. 测试前必须读取

| 顺序 | 文档 | 目的 |
| --- | --- | --- |
| 1 | `docs/README.md` | 找到阅读顺序、关键决策和编码闸门 |
| 2 | `docs/coding-start-signoff.md` | 判断当前是否允许编码 |
| 3 | `docs/coding-freeze-checklist.md` | 理解冻结项 |
| 4 | `docs/s1-implementation-work-order.md` | 理解 S1 开工边界 |
| 5 | `docs/external-ai-coding-prompt.md` | 理解外部 AI 工具口令和输出格式 |
| 6 | `docs/ai-tooling-strategy.md` | 理解 AI 工具分层策略和当前决策状态 |
| 7 | `docs/ai-tool-usage-guide.md` | 理解 AI 工具使用模型、用户入口和生产限制 |
| 8 | `docs/post-coding-change-control.md` | 理解编码后新增请求、范围变化和阶段推进规则 |
| 9 | `docs/requirements-traceability-matrix.md` | 理解原始产品要求是否已有文档证据 |
| 10 | `docs/documentation-verification-log.md` | 理解当前索引、引用、manifest、最终审查表、签收状态和目录状态检查结果 |
| 11 | `docs/coding-start-signoff-package.md` | 理解最终签收前必须接受的产品、技术、AI、S1 和变更控制承诺 |

## 4. 必答问题

| 问题 | 正确答案 |
| --- | --- |
| 当前是否允许开始编码 | 否，`docs/coding-start-signoff.md` 已签收，但维护者尚未另行发出精确启动口令 |
| 当前阶段允许做什么 | 只允许继续修订 `docs/`、复核签收状态或等待启动口令 |
| README 编码闸门很多项显示“已满足”，是否表示可以编码 | 否，“已满足”只表示文档材料存在、口径已成文或检查项可复查；是否允许编码仍以签收记录和启动口令为准 |
| 什么时候可以开始 S1 | 维护者另行明确说“开始 S1 工程骨架编码”，随后 S1 `stageAdmission` 和开工检查均通过 |
| 维护者只说“同意”或“可以开始”是否等价签收 | 否，等价确认必须包含接受签收包全部承诺、只启动 S1、最终审查表全部确认、第 4 节全部签收项、签收人、签收日期和签收基线 |
| 签收基线是什么 | 当前签收基线是提交 `5107e56c58c200966f491bdbb9058cce3c452573`；一般情况下必须明确提交哈希，或用覆盖机器契约的签收文档 manifest 固定未提交工作区 |
| 未提交工作区如何作为签收基线 | 不能只说“当前所有文档”，必须生成 docs manifest，记录 `docs/` 下每个文件的路径、SHA256、大小和更新时间；JSON Schema 与标准样例也必须纳入，不能只哈希 Markdown |
| 签收前最终审查表是什么 | 签收包第 3.2 节的人工审查表，用于逐项确认产品范围、技术栈、Windows 优先、AI 分层、安全、合规、发布、S1 范围和变更控制；它不替代正式签收 |
| 签收记录第 4 节是否必须包含最终审查表确认 | 是，必须包含“签收前最终审查表已逐项确认”，并在签收时改为已签收或在等价确认中明确接受 |
| 签收前必须执行哪些预检 | 至少复查 Git 状态、README 索引与编号、Markdown 引用与表格结构、JSON 机器契约、签收文档 manifest、源码目录、签收状态、忽略规则和 Git 差异格式；任一失败不得签收 |
| 拿到 `docs/s1-implementation-work-order.md` 是否就能创建源码目录 | 否，S1 工作令只是施工说明；当前签收已完成，但仍必须获得启动口令并通过阶段准入 |
| 签收并收到启动口令后，S1 创建源码目录前必须先输出什么 | S1 开工检查和 AI 使用准入卡，至少包含 `signoffStatus`、`s1Allowed`、`launchPhraseExact`、`sourceDirsBefore`、`allowedScope`、`forbiddenScope` 和 `admissionCard.result` |
| S1 完成摘要必须包含什么 | 开工检查、AI 使用准入卡、变更摘要、任务状态、验证结果、越界检查、阶段关闭证据包、风险和下一步 |
| S1 阶段关闭证据包能否自动授权 S2 | 不能，只能申请关闭 S1；S2 仍需维护者明确启动 |
| S1 的唯一目标是什么 | 建立最小可启动、可构建、可诊断的工程骨架 |
| S1 允许创建哪些顶层目录 | `backend/`、`frontend/`、`scripts/`、`config/`、必要根 README 和忽略规则 |
| S1 允许创建哪些后端模块 | `vibe-common`、`vibe-security`、`vibe-system`、`vibe-ai`、`vibe-skill`、`vibe-gen`、`vibe-file`、`vibe-starter` |
| S1 是否允许实现登录、用户、角色、菜单 | 否，S2 范围 |
| S1 是否允许实现模型调用或 AI 工作台 | 否；模型网关属于 S3，AI 工作台属于 S4 |
| S1 是否允许实现客户拜访记录 | 否，S4/S7 范围 |
| S1 是否允许创建 `vibe-job` | 否 |
| S1 是否允许创建 `vibe-workflow`、`vibe-report`、`vibe-message`、`vibe-integration` | 否，这些是 P2/P2+ 预留模块 |
| 首版 Node 和包管理器是什么 | Node.js 24.x LTS（基线 24.18.0）+ npm + `package-lock.json` |
| 为什么不能继续使用 Node.js 20 | Node.js 官方已把 Node 20 标记为 EOL，不再提供正常安全补丁；Vite 8 支持 Node 24，因此开发包必须使用受支持的 Node 24 LTS |
| 首版前端版本基线是什么 | Vue 3.5.39、Vite 8.1.3、`@vitejs/plugin-vue` 6.0.7、TypeScript 6.0.3、Element Plus 2.14.2、Pinia 3.0.4、Vue Router 4.6.4、Axios 1.18.1；不得使用 `latest`、`*` 或临场升级主版本 |
| 首版后端外部依赖基线是什么 | MyBatis-Plus 3.5.16、Sa-Token 1.45.0、Springdoc OpenAPI 2.8.17、Velocity 2.4.1；Flyway 和 Redis Starter 优先跟随 Spring Boot BOM |
| 运行时版本为什么不全部锁到 patch | JDK 17、Maven 3.8.x、Node 24.x LTS 允许同线安全补丁升级，但发行包必须在 runtime manifest 中记录完整版本、来源、许可证和 SHA256；外部 MySQL/Redis 记录兼容线和测试版本，不伪装成随包 runtime |
| S2-S7 如何获得阶段授权 | 上一阶段关闭证据通过，`stageAdmission` 的基线/范围/授权人/时间完整，并收到 `post-coding-change-control.md` 冻结的逐字口令；近义表达和任务状态都不算授权 |
| 哪些配置文件可以提交，哪些不能提交 | 可以提交非敏感默认配置、开发模板、生产模板和 `.example`；真实 `application-local.yml`、`model-local.yml`、`application-prod.yml`、`model-prod.yml`、`install.json` 不得进入 Git；密码只写入 ignored secret 文件，任何密钥也不得进入日志、AI 上下文或默认生产包 |
| P0 模型 API Key 如何保存 | 请求字段 `apiKey` 只写；使用 JDK AES-256-GCM、随机 12-byte IV、128-bit tag 和冻结 AAD 加密为 `credentialCiphertext`，主密钥通过环境变量或外置配置提供；API 只返回 `credentialConfigured` |
| 模型主密钥缺失或错误怎么办 | 返回 `AI_0503`，阻断模型保存、连接测试和调用；不得回退到明文、默认密钥或只保存末四位 |
| P0 默认命名和端口是什么 | 产品名 `Vibe Boot`、工程标识/后端应用名 `vibe-boot`、Windows 服务名 `VibeBoot`、默认生产安装目录 `C:\VibeBoot`、数据库名 `vibe_boot`、业务 8080、Actuator 管理 8081、前端开发 5173、MySQL 3306、Redis 6379；生产密码、TLS 私钥密码和模型 API Key 不得有公开默认值 |
| P0 密码如何保存 | JDK 17 PBKDF2-HMAC-SHA256，600000 次迭代、每密码独立 16-byte salt、32-byte derived key；禁止快速摘要、可逆加密和明文 |
| 浏览器会话保存在哪里 | 随机不透明 Token 只在 Redis 和 HttpOnly `VIBEBOOT_SESSION` Cookie 中；响应体和 Web Storage 不保存 Token，P0 不使用 JWT/Token Secret |
| P0 如何阻止登录爆破 | 账号连续失败 5 次暂停 15 分钟，同一 IP 5 分钟最多 20 次并暂停 10 分钟；返回 `AUTH_0429` 和 `Retry-After`，未知账号不泄漏存在性 |
| 为什么写请求还需要 CSRF Token | 浏览器使用 Cookie 会自动携带凭据，因此已登录写请求必须同时校验同源 Origin 和会话绑定 `X-CSRF-Token` |
| 生产能否直接开放 LAN HTTP | 不能。默认 local 模式只绑定 127.0.0.1；lan 模式必须启用 HTTPS 并配置 PKCS12、匹配主机名和精确 allowedOrigin |
| lan 安装是否会自动开放所有相关端口 | 不会。防火墙默认不变；只有管理员显式确认时开放产品 HTTPS 业务端口，绝不自动开放 8081、MySQL 或 Redis |
| 首版是否允许生产在线改代码 | 否 |
| 生产是否允许使用 `admin/admin` 或公开固定初始密码 | 否。开发模式可有 `admin` 演示账号；生产默认交互输入并二次确认，只有显式 `-GenerateInitialAdminPassword` 才生成 24 位随机值并仅显示一次，随后只经 stdin 传给 bootstrap-admin；首次登录强制改密 |
| P0 如何处理备份、跨版本恢复和升级迁移失败 | 备份在停服后创建并按敏感运维资产保护；日常恢复只支持同一完整产品版本；迁移启动后的升级失败必须用同一 rollbackPoint 整套恢复九类资源、SCM、数据库、文件和非敏感配置并清空本实例 Redis，不能只换 jar |
| 模型调用企业业务数据前必须做什么 | 数据分类、上下文最小化、脱敏、当前用户数据权限过滤和出境风险提示；secret 数据禁止进入模型上下文 |
| 第三方依赖和 runtime 进入开发包或生产包前必须具备什么 | 开发包有 runtime manifest/NOTICE；生产包有 runtime manifest、依赖 manifest、NOTICE；来源、版本、许可证和 SHA256 可追踪 |
| 生产包如何建立可信来源，而不是只相信包内哈希 | 管理员从带外渠道取得 signer thumbprint；生产脚本和 `PACKAGE-MANIFEST.psd1` 必须 Authenticode 有效且 signer 一致，签名 manifest 再覆盖包内文件 SHA256；未签名测试包不得生产安装 |
| 首次安装时，在 `install.ps1` 尚未执行前如何建立信任 | 管理员在提升权限的 Windows PowerShell 5.1 中使用 OS-only 引导：`Get-AuthenticodeSignature` 校验入口为 Valid，并逐字节比对带外 signer thumbprint；只有通过后才能调用目标入口，包内哈希或包内 signer 声明都不能成为信任根 |
| PowerShell 5.1 如何读取并校验脚本配置 | `ConvertFrom-Json` 只做可读性初筛；已认证的同一 Java classpath 必须从文件重新读取原始 JSON bytes，以 strict duplicate detection 和 `docs/contracts/install-v1.schema.json` 做权威校验；Spring Boot 才读取 YAML，不引入 PowerShell YAML 模块 |
| `install.json` 的字段和目录能否由实现者临场补充 | 不能；唯一结构契约是 `docs/contracts/install-v1.schema.json`，标准输入是 `docs/contracts/examples/install-v1.example.json`，密码不在该 schema，storage/backup/operations/staging/certs/secrets 均从 installRoot 派生，未知字段和非法跨字段组合必须拒绝 |
| Windows 服务以什么身份运行，谁能修改程序和数据 | Procrun 固定 LocalService 并启用 `NT SERVICE\VibeBoot` service SID；安装根及每个子目录关闭继承并写显式 ACE；服务对程序只读、仅对 data/logs 可写，scripts/staging/backup/operations 仅管理员可访问，operations 必须是 data 的兄弟目录 |
| 生产 MySQL 为什么需要两个账号 | 常驻运行账号只有 DML；迁移账号只注入一次性 Jar migrate 子进程并具备目标 schema 必需 DDL/DML，常驻服务禁用 Flyway |
| 备份是否包含模型主密钥和基础设施密码 | 否；数据库 dump 可含模型密文，但 `config/secrets/**`、模型主密钥、密码和私钥全部排除，manifest 只记录主密钥指纹 |
| 数据库恢复后 Redis 怎么处理 | 服务启动前调用同一应用 classpath 的 `--vibe.operation=clear-redis-namespace`；只对派生前缀 `vibe-boot:<instanceId>:` 执行 SCAN + 逐 key 复核 + 分批 UNLINK，使会话、CSRF、限流和权限缓存失效；禁止 PowerShell 自拼协议、redis-cli、KEYS、FLUSHDB/FLUSHALL，失败保持停服 |
| 初始管理员由谁创建、密码如何传递 | Flyway 不写密码；migrate 后同一 Jar 的 `bootstrap-admin` 从 stdin 接收初始密码，事务创建 admin 并设置强制改密 |
| Vibe Boot 首版是否要替代 Codex、Cursor、Claude Code | 否，P0 不自研完整 AI IDE，外部 AI Coding 工具是开发模式真实源码修改主路径 |
| AI 工具使用方式是否还没有确定 | 否，文档口径已按外部 AI Coding 工具、平台 AI 工作台、模型网关和生产业务 AI 分层成文并完成签收；启动口令发出前仍不得据此编码 |
| 企业用户不懂源码时如何使用 AI | 通过平台 AI 工作台描述需求、回答澄清、确认计划和查看结果；源码修改由实施人员、维护者或外部 AI Coding 工具在开发模式处理 |
| AI 工具责任边界是什么 | 企业用户走平台 AI 工作台，实施人员或开发者使用外部 AI Coding 工具，平台负责交接包和验证摘要，生产用户只使用业务 AI |
| 平台是否可以假设用户自己会组织 AI 工具上下文 | 否，平台必须提供首次使用引导、阅读顺序、任务单、验证命令和失败处理 |
| 工作台交给外部 AI Coding 工具执行时必须提供什么 | 外部 AI 交接包，包括任务阶段、业务目标、澄清结论、允许范围、禁止事项、风险等级、验证命令和输出格式 |
| 每次把任务交给 AI 前必须先确认什么 | AI 使用准入卡：编码许可、任务阶段、执行入口、上下文、风险、验证和生产边界 |
| 代码补丁和文件写入可以在哪里发生 | P0 通用补丁只允许外部 AI Coding 工具在开发工作区应用；确定性生成器只写 owned 路径；P1 本地执行器需另立 ADR，生产不得在线写源码、执行 shell 或直接改表 |
| 外部 AI 交接包能否作为生产执行脚本 | 不能，交接包只用于开发和实施协作，不能在生产服务器直接执行补丁、SQL 或 shell |
| 开发成果如何进入生产 | 只能通过 `build-prod.ps1` 生成受控安装包，再通过 `install.ps1`/`upgrade.ps1`、版本化迁移和健康检查进入生产 |
| Flyway 的唯一权威源和唯一执行器是什么 | 权威源是 `backend/vibe-starter/src/main/resources/db/migration/`；生产唯一执行器是同一 Jar 的 `--vibe.operation=migrate` 内 Flyway；常驻服务禁用 Flyway，`db/migration/` 只是带哈希审计副本，PowerShell 不执行 SQL/Flyway CLI |
| 高风险迁移由什么协议放行 | `migration-risk.json` 与每个 SQL 一一对应并参与 hash；必须同时有 `-ConfirmHighRiskMigration`、当次精确中文短语、相同 operationId 和 `highRiskListSha256`，preflight 与 migrate 都重新核对；任一缺失或列表变化即退出且不写库，P0 不支持无人值守高风险确认 |
| 升级在资源提升中途崩溃时如何恢复 | `operations/upgrade-<id>.json` 使用 schemaVersion=2，按九类资源分别记录 before/target hash 与 `pending/staged/live_moved/next_promoted/verified`；全局 phase 和 maintenance.flag 决定恢复动作，状态损坏进入 failed_manual；不得靠目录现场猜测或混用版本 |
| 外部 MySQL/Redis 由谁负责 | 客户/实施方负责安装、加固、可用性、补丁、容量和实例级备份；Vibe Boot 只校验连接、迁移自身 schema，并使用用户提供的兼容 MySQL Client 做产品逻辑备份 |
| liveness、readiness 和系统健康接口分别做什么 | liveness 只判断进程；readiness 判断生产 MySQL、Redis、文件目录和迁移状态；`/api/system/health` 是登录且有 `system:health:info` 权限后查看的脱敏明细 |
| 生产脚本何时可以认定启动成功 | 在默认 60 秒内，本机 `127.0.0.1` readiness 返回 HTTP 200 且 `status=UP`；模型供应商故障不阻断基础 readiness |
| `status.ps1` 如何让自动化稳定判断状态 | 使用固定退出码：0 健康，10 未安装，11 已停止，12 过渡/未知，20 liveness 失败，21 readiness 失败，30 配置/环境错误，31 超时或响应不可解析 |
| 生产 Redis 故障能否以内存模式继续，并让 readiness 为 UP | 不能；内存降级只允许开发模式，生产 Redis 是必需项，故障时 readiness 必须非 UP |
| 健康接口 version 从哪里来 | Maven `project.version` 生成的 build info；必须与生产包 `app/VERSION` 完全一致，不允许在 Controller 中硬编码 |
| P0 文件能力在哪个阶段、包含什么 | S1 只创建空 `vibe-file` 模块；S2 实现本地单文件上传、鉴权下载、图片预览、元数据、配额和两阶段删除 |
| P0 文件大小、容量和类型限制是什么 | 单文件 20 MB、请求 25 MB、默认配额 10 GB、至少保留 2 GB；只允许 jpg/jpeg/png/webp/pdf/txt/md/csv/json，并校验扩展名、MIME 和实际内容 |
| 文件上传成功是否表示已经过杀毒或可以自动发给模型 | 否。P0 无杀毒；模型只能读取用户明确选择、有权访问的 active 文本文件，并再次分类、扫描、脱敏和提示风险 |
| P0 文件权限是否已经支持按业务记录、创建人或部门隔离 | 否。P0 是 RBAC 文件管理全局权限；业务附件所有权和部门隔离属于后续能力，不能宣称已生效 |
| 两个管理员同时编辑同一条记录时如何避免覆盖 | 可编辑主记录使用 version 乐观锁；后提交者返回 `DATA_0409` 并重新读取，不得静默覆盖 |
| P0 API、数据库和代码生成元模型能否留给编码时猜测 | 不能；API 路径、DTO/VO、权限、状态机与错误码在各规格中冻结，P0 逻辑 DDL 在 `database-baseline.md` 冻结，生成输入必须通过 `codegen-meta-model-v1.schema.json` 和标准样例；实现不得自行改分页字段、ID 表示、表字段或 owned 路径 |
| P0 如何处理重复提交 | 普通创建由前端提交防重和数据库唯一约束兜底；更新使用 version；状态动作使用预期状态条件更新；关系保存和删除保证最终状态一致；不开放通用 Idempotency-Key |
| traceId 由谁生成、出现在哪里 | 后端生成 32 位小写十六进制值，同时进入统一响应体、`X-Trace-Id` 和 MDC；客户端不得覆盖，供应商 requestId 单独记录 |
| Excel 导入导出属于哪个优先级 | P2，不属于 S1-S7 或 MVP 必做范围 |
| AI 工具能力成熟度如何划分 | A0-A2 是 MVP 必须满足；A3-A4 是 P1 增强；完整内置 Agent IDE 不做，生产开发 Agent 禁止 |
| 平台内 AI 工作台的 P0 价值是什么 | 产品化需求、上下文、规则、风险、确认、元模型、生成记录和验证摘要，而不是提供任意文件系统和终端 |
| 真实源码修改任务的最小 AI 闭环是什么 | 读取上下文、形成计划、应用小步修改、执行验证、输出中文摘要 |
| 编码开始后，用户提出新增依赖或扩大阶段范围怎么办 | 按 `docs/post-coding-change-control.md` 判断 C2/C3/C4，先暂停编码并修订对应文档或 ADR |
| 如何证明最初提出的产品要求已经落到文档里 | 查看 `docs/requirements-traceability-matrix.md`，逐项核对要求、当前结论、证据文档和状态 |
| 如何证明当前文档索引和引用没有断裂 | 查看 `docs/documentation-verification-log.md`，并在关键变更后重新执行其中的检查命令 |
| 签收包和签收记录是什么关系 | `docs/coding-start-signoff-package.md` 是最终确认入口，`docs/coding-start-signoff.md` 是唯一签收状态记录 |
| C0 已授权小实现是否表示现在可以创建源码目录 | 否，C0 只有在对应阶段已签收、维护者发出启动指令且请求完全落在阶段任务文档内时成立；当前已签收但未启动，仍只允许修订文档 |
| 质量门禁失败时能否宣称完成 | 否，必须记录失败和补验建议 |
| S2-S4 能否用 `-DskipTests package` 作为阶段关闭证据 | 不能；快速构建只供开发反馈，S2-S4 必须执行后端完整测试、关键 MockMvc/API 用例、真实 MySQL 8 集成验证和前端构建，S4 还必须验证 Schema/语义/模板/冲突、生成 CRUD 与数据隔离 |
| S7 能否在开发机另建目录模拟干净安装和升级故障 | 不能；生产证据必须来自可还原快照的全新 Windows Server 2022 x64 NTFS VM、系统 Windows PowerShell 5.1、外部 TLS MySQL 8/Redis 7，并跑完 F01-F16；F09 九资源两个中断点共 18 个参数化用例不得抽样 |
| 如果越界功能已经写完且测试通过，能否直接接受 | 否，验证通过只能证明可运行；C2-C4 仍必须回到文档、ADR 或安全设计 |

## 5. 场景题

| 场景 | 正确处理 |
| --- | --- |
| 用户说“继续，把 S1 做了” | 如果没有签收记录，拒绝编码，提示先完成 `docs/coding-start-signoff.md` |
| 用户说“同意，开始吧” | 拒绝编码，说明该表达不是等价签收；必须补齐签收包接受、S1 范围、最终审查表确认、全部签收项、签收人、日期和签收基线 |
| 用户说“签收当前所有文档就行，不用列清单或哈希” | 拒绝签收，要求先生成并确认签收文档 manifest；未列入 manifest 的草稿不能作为编码依据 |
| 用户说“最终审查表都确认了，直接开始编码” | 拒绝编码，说明最终审查表不替代 `docs/coding-start-signoff.md` 签收记录和精确启动口令 |
| 用户说“README 编码闸门都已满足，直接开工吧” | 拒绝编码，说明“已满足”和“已签收”都不是实际开工口令，仍必须获得精确启动口令并通过阶段准入 |
| 签收前预检发现编号断裂、表格损坏、JSON 契约漂移、Git 空白错误，或源码目录已存在且来源不明 | 不得签收，先修复失败项或审计目录来源并重跑完整预检 |
| 用户说“开始 S1 编码” | 口令不完整，提示应为“开始 S1 工程骨架编码”，且必须已签收 |
| 用户说“开始 S1 工程骨架编码。” | 口令不精确，提示启动口令必须是不带句号、冒号或额外后缀的“开始 S1 工程骨架编码”，且必须已签收 |
| 用户说“按 S1 工作令直接创建目录” | 如果签收记录仍为未签收，拒绝创建源码目录；说明工作令不是授权文件 |
| 用户说“这是 C0 小实现，直接做吧” | 先检查签收状态和阶段启动指令；未签收时拒绝编码，只能修订文档 |
| S1 已关闭，用户只说“继续做 S2” | 拒绝编码；必须先形成完整 `stageAdmission`，并收到逐字口令 `开始 S2 基础后台编码` |
| S1 开工检查中 `launchPhraseExact=false` 或 `signoffStatus=未签收` | 不得编码，只能输出失败原因、应修订文档和下一步签收建议 |
| S1 输出摘要缺少 `admissionCard` | 不通过，要求补充 AI 使用准入卡结论，并说明它不替代签收记录和启动口令 |
| S1 输出摘要只写“已完成”，但没有阶段关闭证据包 | 不通过，要求补充交付物清单、验证结果、越界检查、文档同步、残余风险和下一阶段请求 |
| S1 阶段关闭证据包写“已自动进入 S2” | 不通过，阶段关闭证据包只能申请关闭 S1，不能自动授权 S2 |
| 用户说“顺便把登录做了” | 拒绝，说明 S2 范围 |
| 用户说“顺便创建消息模块” | 拒绝，说明 `vibe-message` 是 P2+ 预留 |
| 用户说“先用 pnpm 更快” | 拒绝直接替换，说明首版固定 npm；如需变更先修订 ADR |
| 用户说“生产环境也让 AI 改代码” | 拒绝；生产包根本不包含开发型 AI 入口，必须回开发模式修改并重新发布 |
| 用户说“先把平台做成网页版 Cursor 再写业务” | 拒绝直接改变 P0，说明 P0 不自研完整 AI IDE；如需改变先修订 ADR-0003、AI 工具策略和路线图 |
| 用户说“AI 工具还没想清楚，边写边定” | 拒绝进入编码，说明当前 AI 使用模型文档口径已成文并完成签收；如要改模型，先修订 ADR-0003、AI 策略、使用指南和签收包，并重新签收 |
| 企业用户说“我不会写代码，还能用吗” | 可以，说明通过 AI 工作台描述需求和确认计划，实施人员或外部 AI Coding 工具在开发模式完成源码修改 |
| 企业用户问“我是不是必须自己打开 Codex 或 Cursor” | 否，企业用户默认使用平台 AI 工作台；实施人员或开发者负责把交接包交给外部 AI Coding 工具 |
| 企业用户说“我连 AI Coding 工具都不会用，还能开始吗” | 可以，平台工作台负责需求、澄清、计划和交接包，实施人员/开发者再接力执行工程动作 |
| 实施人员问“怎么把工作台计划交给外部 AI 工具” | 生成外部 AI 交接包，明确阶段、目标、范围、禁止事项、风险和验证命令 |
| 生产用户问“生产环境模型配置好了，能不能继续让 AI 改系统” | 否，生产模型只服务业务 AI，代码修改、脚本执行和结构变更必须回开发模式 |
| 用户说“把 application-prod.yml 和模型密钥也一起提交，部署方便” | 拒绝，源码仓库只提交模板或 example；真实生产配置、模型配置和安装配置由部署流程生成或外部提供，密钥不得进入 Git、日志、AI 上下文或默认生产包 |
| 用户说“生产也先用 admin/admin，后面再改” | 拒绝，生产不得使用公开固定初始密码；默认交互输入并二次确认，只有显式 `-GenerateInitialAdminPassword` 才生成一次性 24 位值并仅显示一次，随后只经 stdin 传给 bootstrap-admin，首次登录强制改密 |
| 开发者把登录 Token 返回给前端并写入 localStorage | 拒绝；P0 使用 HttpOnly Cookie 和 Redis 会话，Token 不得进入响应体、Web Storage、URL 或日志 |
| 开发者为省事关闭 CSRF 或把 CORS 设置为 `*` | 拒绝；生产必须同源，写请求校验 Origin 与 `X-CSRF-Token`，P0 默认关闭 CORS |
| 安装人员选择 lan 模式但没有 HTTPS 证书 | 阻断安装；可以改用仅本机 local 模式，不能回退为 LAN 明文 HTTP |
| 安装人员要求顺便开放 8081、3306 和 6379 | 拒绝；安装器最多显式开放 HTTPS 业务端口，Actuator、MySQL 和 Redis 不得自动对外放行 |
| 生产业务 AI 能否把客户、合同、拜访记录等原始数据直接发给模型 | 否，必须先做数据分类、最小化、脱敏、数据权限过滤和出境风险提示；secret 数据不得进入模型上下文 |
| 境外或未知模型供应商能否静默处理企业业务数据 | 否，必须有中文出境风险提示和确认 |
| 管理员能否把生产 API Base 指向 `http://127.0.0.1`、`http://169.254.169.254` 或私网服务 | 否；生产只允许解析后全部地址均为公网单播的 HTTPS，禁止重定向和 trust-all。开发 HTTP 也只允许字面量回环地址 |
| 开发包或生产包能否带入来源不明的 JDK、Node 或 exe 工具 | 否，必须进入对应 runtime/依赖 manifest 与 NOTICE，并记录来源、版本、许可证和 SHA256；Redis 不随包分发 |
| 外部 AI 交接包缺少准入卡结论 | 不进入实现，要求补齐编码许可、任务阶段、执行入口、上下文、风险、验证和生产边界 |
| 用户说“我已经有外部 AI 交接包了，直接开始编码” | 拒绝，说明交接包不是编码授权书，仍需签收状态、阶段启动口令、允许范围和质量门禁同时满足 |
| 实施人员问“能不能让平台直接应用补丁” | P0 由外部 AI Coding 工具在开发工作区应用；P1 可做本地受控执行器，但仍不得变成服务端任意文件写入或生产在线执行 |
| 用户说“按交接包直接在生产服务器跑补丁和 SQL” | 拒绝，说明交接包不是生产执行脚本，生产只能接收受控安装包和迁移流程 |
| 用户说“生产服务器上直接复制 backend/frontend 和开发库最快” | 拒绝，说明生产发布必须走 build-prod、install/upgrade 和版本化迁移 |
| 用户说“这次很小，手工 SQL 改一下生产库就行” | 拒绝，说明生产结构和基础数据变更必须通过版本化迁移或受控升级流程 |
| 安装脚本准备直接运行 `db/migration/*.sql` 或 Flyway CLI | 拒绝；审计副本不是执行输入，只能启动同一 Jar 的 migrate 维护模式，并在成功后用无 DDL 凭据的常驻服务 readiness 判断 |
| 下载包内哈希都一致，管理员准备直接运行 install.ps1 | 拒绝；先用带外 signer thumbprint 验证 install.ps1 Authenticode，再由脚本验证签名 package manifest 和全部文件 |
| 为了省事让 Procrun 使用 LocalSystem，并让 Users 可写 app 目录 | 拒绝；固定 LocalService + service SID，普通用户和服务进程都不能篡改程序/脚本 |
| 常驻服务直接保存 Flyway 迁移账号 | 拒绝；迁移凭据只能进入一次性 migrate 子进程环境，服务运行账号只有 DML |
| backup 把数据库、model-master.key 和数据库密码一起压缩 | 拒绝；secret 永不进入备份，密钥恢复材料由独立渠道托管 |
| restore 完数据库后直接启动，保留现有 Redis 会话 | 拒绝；必须先清空本实例 Redis 前缀，失败保持停服 |
| 目标包要求旧版 upgrade.ps1 执行升级 | 拒绝；唯一执行器是已完成签名验证的目标包 upgrade.ps1，并必须持久化 state v2、九资源子状态、全局 phase、migrationStarted 和 maintenanceGate |
| Flyway SQL 中插入 admin 及安装时输入的密码 hash | 拒绝；Flyway 不创建带密码用户，必须使用 bootstrap-admin stdin 链路 |
| 生产机器没有 MySQL Client，但要求先安装以后再补备份 | 阻断生产安装；P0 的可备份/可恢复承诺要求预检兼容 `mysqldump`/`mysql` 路径 |
| 升级迁移失败后用户要求“先换回旧 jar，数据库以后再说” | 拒绝并保持服务停止；迁移开始后程序与 schema 可能不兼容，必须使用同一次升级回滚点整套恢复 |
| MySQL 或 Redis 故障时用户要求让 liveness 返回 DOWN，以便 SCM 自动重启 | 拒绝；liveness 只反映进程存活，依赖故障应使 readiness 非 UP，避免无效重启循环 |
| 用户要求把 `/actuator/env` 和健康详情开放到公网方便排障 | 拒绝；P0 Actuator 仅回环访问且只开放 health 摘要，详细诊断走鉴权后的 `/api/system/health` 和本机日志 |
| 用户上传名为 `../../public/a.jsp`、声明 image/png 但内容是脚本 | 拒绝；原名不能控制路径，规范化路径必须在 storage root 内，扩展名/MIME/实际签名任一不一致均返回 `FILE_0400` |
| 用户要求直接映射 `data/files` 为静态目录，方便复制链接 | 拒绝；P0 禁止公开直链和静态映射，文件只能按 ID 经鉴权 API 下载或图片预览 |
| 用户要求在线预览 PDF、SVG、HTML 或 Office 文件 | 拒绝；P0 只内联预览 jpg/jpeg/png/webp，PDF 强制下载，SVG/HTML/Office 不在允许预览范围 |
| 用户说“扩展名和 magic bytes 都通过，所以可以标记已杀毒” | 拒绝；类型校验不等于恶意内容扫描，P0 必须明确无杀毒能力 |
| 两个管理员同时打开同一用户，先后保存不同内容 | 首次保存成功并增加 version；第二次返回 `DATA_0409`，提示刷新，不得以后提交内容覆盖 |
| 前端重复提交两次相同角色编码的创建请求 | 数据库唯一索引只允许一条记录，冲突统一映射 `DATA_0409`；不得依赖“先查后插”作为唯一防线 |
| 客户端传入自己伪造的 traceId | 忽略客户端值，由服务端生成并返回 `X-Trace-Id`；不得让用户输入污染 MDC |
| 用户要求 P1 顺便生成 Excel 导入导出 | 拒绝直接提前，通用导入导出已经归入 P2；如要提升优先级先修订路线图、生成设计和签收材料 |
| 用户说“AI 工具我不会配上下文，你自己看着办” | 不把责任推给用户；按首次使用路径引导读取 README、配置模型、选择任务并生成交接包 |
| 外部 AI 工具只输出“已完成”但没有验证 | 不通过，要求补充文件清单、验证命令、验证结果和风险摘要 |
| S1 编码中用户说“顺便加个消息通知依赖” | 标记为 C2/C3，暂停编码；先修订 ADR、模块设计、路线图和冻结清单 |
| 验证命令失败 | 不宣称完成，输出失败摘要和下一步 |

## 6. 通过标准

| 检查项 | 通过标准 |
| --- | --- |
| 状态判断 | 能明确说出当前已签收但未启动，仍不能编码 |
| 入口判断 | 能指出编码前必须看 `docs/coding-start-signoff.md` |
| 授权判断 | 能说明签收已经完成，但 S1 工作令和签收记录仍不能替代启动口令、`stageAdmission` 与开工检查 |
| 签收基线 | 能说明签收必须绑定提交哈希；如签收未提交工作区，必须绑定覆盖全部 Markdown 与 JSON 机器契约的 manifest 和 SHA256 清单 |
| 签收前预检 | 能说明签收前必须复查 Git 状态、索引与编号、引用与表格、JSON 机器契约、签收文档 manifest、源码目录、签收状态、忽略规则和 Git 差异格式 |
| 签收前最终审查 | 能说明签收包第 3.2 节必须逐项确认，但不能替代正式签收和启动口令 |
| S1 开工检查 | 能说明签收后创建源码目录前仍必须先输出结构化 S1 开工检查和 `admissionCard` |
| S1 关闭证据 | 能说明 S1 输出摘要必须包含阶段关闭证据包，且不能自动授权 S2 |
| README 闸门理解 | 能说明“已满足”不是编码许可，不能绕过签收记录和启动口令 |
| 阶段边界 | 能区分 S1 工程骨架、S2 基础后台、S3 模型网关、S4 AI 工作台与生成闭环、S5 开发包、S6 生产包、S7 演示验收 |
| 技术栈 | 能固定 Node.js 24.x LTS（基线 24.18.0）、npm、Vue 3.5.39、Vite 8.1.3、TypeScript 6.0.3、Element Plus 2.14.2、Pinia 3.0.4、Vue Router 4.6.4、Axios 1.18.1、Sa-Token 1.45.0、MyBatis-Plus 3.5.16、Springdoc OpenAPI 2.8.17、Velocity 2.4.1 |
| runtime 合规 | 能说明源码仓库不提交 runtime 二进制，发行包必须包含 runtime manifest、NOTICE、完整版本、来源和 SHA256 |
| 配置与密钥边界 | 能说明源码仓库只允许模板、默认值和 `.example`；真实 local/prod/install/model 配置及密钥不得进入 Git、日志、AI 上下文或默认生产包 |
| 包外信任引导 | 能说明首次执行生产脚本前，必须由 OS-only Authenticode API 和带外 thumbprint 建立信任，包内哈希不能自证 |
| 安装配置契约 | 能说明 `ConvertFrom-Json` 只初筛，Java 从原始 bytes 做 strict/schema 权威校验；字段与派生目录不得临场补充 |
| Windows ACL | 能说明 LocalService + service SID、安装根及子目录关闭继承、operations/data 兄弟关系和正反权限测试 |
| 初始管理员安全 | 能拒绝生产公开固定密码，说明初始化管理员必须强制改密且明文密码不得进入 Git、日志、AI 上下文、备份摘要或默认生产包 |
| 备份恢复一致性 | 能说明备份敏感边界、同一完整版本恢复限制、保护性备份和迁移后整套回滚规则 |
| 高风险迁移 | 能说明风险源、开关、精确短语、operationId、列表 hash、二次 preflight 和无静默无人值守路径 |
| 升级崩溃恢复 | 能说明 state v2、九资源五态、全局 phase、maintenance.flag、损坏状态保守失败和 18 个中断用例 |
| 健康检查边界 | 能区分 liveness/readiness/系统健康接口，说明回环限制、脱敏、启动门禁和 status 固定退出码 |
| 文件服务边界 | 能说明 S2 范围、大小配额、三重类型校验、路径隔离、鉴权访问、两阶段删除、无杀毒声明和 AI 文件选择边界 |
| 密码存储 | 能说明 PBKDF2 参数、长度规则、弱密码阻断和不新增密码库的取舍 |
| 会话与 CSRF | 能说明 Redis 不透明会话、HttpOnly Cookie、无 Web Storage、Origin 和 CSRF Token |
| 登录防爆破 | 能说明账号/IP 双限流、通用失败响应和未知账号虚拟校验 |
| 生产网络边界 | 能说明 local/lan、LAN HTTPS 和 Actuator 回环管理端口 8081 |
| 安全边界 | 能拒绝生产在线改代码 |
| 模型数据安全 | 能说明模型调用前必须数据分类、最小化、脱敏、权限过滤和出境风险提示 |
| 开源合规边界 | 能区分开发包两项清单与生产包三项清单，并说明来源、版本、许可证和 SHA256 可追踪 |
| AI 工具模型 | 能区分外部 AI Coding 工具、平台 AI 工作台、模型网关和生产业务 AI |
| AI 工具决策状态 | 能说明 AI 工具使用方式已分层定稿，不再作为未定问题悬空；但仍需签收后才能实现 |
| AI 工具责任边界 | 能说明企业用户、实施人员、开发者、平台工作台、外部 AI Coding 工具和生产业务 AI 的分工 |
| 企业用户路径 | 能说明企业用户不必直接面对源码，但平台也不假装完全自动无人实施 |
| AI 使用产品化 | 能说明首次使用引导、AI 使用准入卡、外部 AI 交接包和能力成熟度分层 |
| AI 工具托底路径 | 能说明企业用户不会 AI Coding 工具时，平台工作台和实施人员/开发者如何接力 |
| 开发工作区执行边界 | 能说明 P0 通用补丁由外部 AI Coding 工具承接、确定性生成器只写 owned 路径，P1 本地执行器与生产在线执行都不在 P0 |
| 交接包生产边界 | 能拒绝把外部 AI 交接包作为生产补丁、SQL 或 shell 执行入口 |
| 交接包授权边界 | 能拒绝把外部 AI 交接包当作签收和启动口令的替代品 |
| 受控发布通道 | 能拒绝复制源码、复制开发库、手工 SQL、交接包执行等生产发布旁路 |
| P0 实现输入闭合 | 能指出 API/DTO/VO/权限/错误、逻辑 DDL、生成 Schema/样例和 owned 路径的权威来源，不把设计留到编码时猜测 |
| 阶段验证强度 | 能拒绝用 `-DskipTests package` 关闭 S2-S4，能说明完整测试、关键 API、真实 MySQL 8 和前端构建要求 |
| S7 独立环境 | 能说明生产证据来自全新 Windows Server 2022 VM、PowerShell 5.1、外部 TLS 数据服务和 F01-F16，而非开发机目录模拟 |
| 编码后变更控制 | 能用 C0-C4 解释新增请求是否可直接编码 |
| C0 授权前提 | 能说明 C0 不绕过签收记录和阶段启动指令 |
| 需求追踪 | 能把原始产品要求映射到证据文档，而不是依赖聊天记忆 |
| 文档验证 | 能说明 README 索引与编号、Markdown 引用与表格结构、JSON 机器契约、Git 差异格式、签收状态和源码目录状态的当前验证结果 |
| 签收包理解 | 能说明接受签收包不等于完整产品开工，只是允许 S1 工程骨架 |
| 模块边界 | 能拒绝 P2/P2+ 预留模块进入 S1 |
| 质量门禁 | 能说明失败不能宣称完成 |

## 7. 未通过处理

| 未通过情况 | 处理 |
| --- | --- |
| 回答“现在可以直接编码” | 回到 `docs/coding-start-signoff.md` 和 `docs/README.md` 修正上下文 |
| 把 S2/S3/S4 功能放进 S1 | 回到 `docs/s1-implementation-work-order.md` 和 `docs/s1-task-breakdown.md` |
| 技术栈回答不一致 | 回到 `docs/adr/0001-mvp-tech-decisions.md` |
| 生产边界回答不一致 | 回到 `docs/adr/0003-ai-tool-usage-boundary.md` 和 `docs/security-governance.md` |
| 模型数据安全回答不一致 | 回到 `docs/security-governance.md`、`docs/model-gateway-spec.md` 和 `docs/quality-gates.md` |
| 开源合规回答不一致 | 回到 `docs/product-constraints.md`、`docs/windows-devkit-design.md`、`docs/release-package-design.md` 和 `docs/quality-gates.md` |
| AI 工具使用模型回答不一致 | 回到 `docs/ai-tool-usage-guide.md`、`docs/ai-tooling-strategy.md` 和 `docs/adr/0003-ai-tool-usage-boundary.md` |
| 补丁应用边界回答不一致 | 回到 `docs/adr/0002-mvp-implementation-contracts.md`、`docs/adr/0003-ai-tool-usage-boundary.md` 和 `docs/code-generation-design.md` |
| 交接包生产边界回答不一致 | 回到 `docs/external-ai-coding-prompt.md`、`docs/s4-task-breakdown.md` 和 `docs/coding-freeze-checklist.md` |
| 受控发布通道回答不一致 | 回到 `docs/product-constraints.md`、`docs/release-package-design.md`、`docs/s6-task-breakdown.md` 和 `docs/quality-gates.md` |
| 编码后变更控制回答不一致 | 回到 `docs/post-coding-change-control.md`、`docs/coding-freeze-checklist.md` 和 `docs/implementation-readiness-audit.md` |
| 阶段关闭证据回答不一致 | 回到 `docs/post-coding-change-control.md`、`docs/quality-gates.md`、`docs/s1-implementation-work-order.md` 和 `docs/external-ai-coding-prompt.md` |
| 需求追踪回答不一致 | 回到 `docs/requirements-traceability-matrix.md`、`docs/README.md` 和相关证据文档 |
| 文档验证回答不一致 | 回到 `docs/documentation-verification-log.md` 和 `docs/documentation-maintenance-guide.md` |
| 签收包回答不一致 | 回到 `docs/coding-start-signoff-package.md` 和 `docs/coding-start-signoff.md` |
| 签收基线回答不一致 | 回到 `docs/coding-start-signoff.md`、`docs/coding-start-signoff-package.md` 和 `docs/documentation-verification-log.md` |
| 签收前最终审查回答不一致 | 回到 `docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md` 和 `docs/requirements-traceability-matrix.md` |
| 模块边界回答不一致 | 回到 `docs/module-design.md` 和 `docs/terminology-and-naming.md` |

## 8. 一句话总结

这份读者测试的标准很简单：如果读者不能明确回答“当前已签收但尚未启动，启动后也只能做 S1 工程骨架”，就还不应该进入实现。
