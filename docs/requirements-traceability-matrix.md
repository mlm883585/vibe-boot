# Vibe Boot 需求追踪矩阵

## 1. 文档目的

本文把 Vibe Boot 编码前已经讨论过的核心产品要求，逐条映射到当前文档证据。

它不是新的需求来源，也不替代任何设计文档。它的作用是证明：当前文档体系不是散乱堆叠，而是已经覆盖了进入 S1 工程骨架前必须收敛的产品约束、技术约束、AI 工具边界、开发/生产模式和签收规则。

## 2. 覆盖状态口径

| 状态 | 含义 |
| --- | --- |
| 已覆盖 | 已有明确文档约束，签收后可作为编码依据 |
| 已覆盖但需实现验证 | 文档已定义标准，后续要通过代码、脚本、测试或演示证明 |
| 需人工签收 | 文档已定义承诺，但进入 S1 前仍需维护者接受 |
| 未覆盖 | 缺少明确文档，不应进入相关编码 |

## 3. 原始产品要求追踪

| 原始要求 | 当前结论 | 证据文档 | 状态 |
| --- | --- | --- | --- |
| 做一个超过传统低代码的平台 | 不做拖拽解释器，生成真实 Java/Vue 代码，依靠 AI、skills、规则和质量门禁持续迭代 | `docs/product-constraints.md`、`docs/vibe-boot-architecture.md`、`docs/competitive-analysis.md` | 已覆盖 |
| 用户不是从零开始编码 | 用户从 Vibe Boot 准备好的模块化单体底座开始，通过 AI 持续迭代 | `docs/vibe-boot-architecture.md`、`docs/ai-tool-usage-guide.md` | 已覆盖 |
| 支持 vibe coding 式逐步迭代 | 开发模式允许外部 AI Coding 工具修改真实源码，平台 AI 工作台沉淀需求、计划、风险和验证摘要 | `docs/ai-tooling-strategy.md`、`docs/ai-tool-usage-guide.md`、`docs/post-coding-change-control.md` | 已覆盖 |
| 平台接入常用大模型 | 统一走模型网关，OpenAI 兼容协议优先，支持配置、连接测试、用量记录、错误中文化、限流配额和用量摘要 | `docs/model-gateway-spec.md`、`docs/s3-task-breakdown.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 大模型调用成本必须可控 | P0 不做精确计费，但必须支持 maxTokens、每分钟限流、每日调用/token 上限、超限错误和用量摘要 | `docs/model-gateway-spec.md`、`docs/s3-task-breakdown.md`、`docs/ai-workbench-design.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 模型调用必须保护企业数据与内网 | 模型调用前必须做数据分类、最小化、脱敏、生产数据权限过滤和出境风险提示；secret 数据不得进入模型上下文；API Base 必须通过 SSRF、DNS、TLS、重定向和响应大小门禁 | `docs/security-governance.md`、`docs/model-gateway-spec.md`、`docs/ai-workbench-task-breakdown.md`、`docs/quality-gates.md`、`docs/product-constraints.md` | 已覆盖但需实现验证 |
| 配置与密钥边界 | 源码仓库只提交非敏感默认配置和 example；真实 local/prod/install/model 配置由本地或部署脚本生成，包含密钥时不得进入 Git、日志、AI 上下文或默认生产包 | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/engineering-skeleton-spec.md`、`docs/release-package-design.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 模型凭据存储 | 供应商 API Key 使用 JDK AES-256-GCM 密文入库，32-byte 主密钥外置并与数据库分离；API 只返回 `credentialConfigured`，错误主密钥返回 `AI_0503` | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/model-gateway-spec.md`、`docs/security-governance.md`、`docs/database-baseline.md` | 已覆盖但需实现验证 |
| 默认命名与端口基线 | P0 固定产品名 `Vibe Boot`、工程标识 `vibe-boot`、后端应用名 `vibe-boot`、Windows 服务名 `VibeBoot`、默认生产安装目录 `C:\VibeBoot`、数据库名 `vibe_boot`、端口 8080/5173/3306/6379；敏感密码不得有公开默认值 | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/engineering-skeleton-spec.md`、`docs/windows-devkit-design.md`、`docs/release-package-design.md` | 已覆盖但需实现验证 |
| 有 skills 和约束规则 | Skills/规则用于约束 AI 行为、项目边界、风险确认和生成上下文；P0 必须记录 skill/rule 版本快照、来源文档、冲突裁决、阻断项和警告项 | `docs/skill-rule-design.md`、`docs/ai-workbench-task-breakdown.md`、`docs/quality-gates.md`、`docs/product-constraints.md` | 已覆盖但需实现验证 |
| 用户定位是中小企业 | 首版面向中国中小企业、实施人员、Java 全栈开发者，不优先服务超大企业复杂治理 | `docs/product-constraints.md`、`docs/competitive-analysis.md` | 已覆盖 |
| 极低成本搭建系统 | 技术栈最小化、模块化单体、Windows 优先、国内镜像、不引入微服务和重型中间件 | `docs/product-constraints.md`、`docs/adr/0001-mvp-tech-decisions.md`、`docs/windows-devkit-design.md` | 已覆盖 |
| 开源仓库和安装包可分发 | 第三方依赖、runtime、工具来源、版本、许可证和 NOTICE 必须可追踪；来源不明或高风险许可证不得进入发行包 | `docs/product-constraints.md`、`docs/windows-devkit-design.md`、`docs/release-package-design.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 支持不断扩展升级 | P0/P1/P2 分层，编码后变更按 C0-C4 控制，生产包支持升级回滚和备份恢复 | `docs/mvp-roadmap.md`、`docs/post-coding-change-control.md`、`docs/release-package-design.md`、`docs/s6-task-breakdown.md` | 已覆盖但需实现验证 |

## 4. 技术栈要求追踪

| 技术要求 | 当前结论 | 证据文档 | 状态 |
| --- | --- | --- | --- |
| JDK 17 | 固定 JDK 17，不追逐新版本 | `docs/adr/0001-mvp-tech-decisions.md`、`docs/product-constraints.md` | 已覆盖 |
| Maven 3.8 | 固定 Maven 3.8.x，不使用 Gradle | `docs/adr/0001-mvp-tech-decisions.md`、`docs/product-constraints.md` | 已覆盖 |
| 运行时 patch 策略 | 内置 JDK/Maven/Node 允许同线安全补丁并在 manifest 记录版本、来源、许可证、SHA256；外部 MySQL/Redis 记录兼容线和测试版本 | `docs/adr/0001-mvp-tech-decisions.md`、`docs/windows-devkit-design.md`、`docs/release-package-design.md`、`docs/coding-start-signoff-package.md` | 已覆盖 |
| Spring Boot 基线锁定 | P0 使用 Spring Boot 3.5.16，只允许 3.5.x patch 升级；不得临场升级到 Spring Boot 4.x | `docs/adr/0001-mvp-tech-decisions.md`、`docs/product-constraints.md`、`docs/engineering-skeleton-spec.md`、`docs/coding-start-signoff-package.md` | 已覆盖 |
| 后端外部依赖基线锁定 | MyBatis-Plus 3.5.16、Sa-Token 1.45.0、Springdoc OpenAPI 2.8.17、Velocity 2.4.1 由父 POM 集中管理；Flyway、Redis Starter 跟随 Spring Boot BOM | `docs/adr/0001-mvp-tech-decisions.md`、`docs/engineering-skeleton-spec.md`、`docs/s1-task-breakdown.md`、`docs/coding-start-signoff-package.md` | 已覆盖 |
| MySQL 8 | 首版只支持 MySQL 8 | `docs/product-constraints.md`、`docs/database-baseline.md` | 已覆盖 |
| Redis | 用于登录态、验证码、限流、轻量缓存 | `docs/product-constraints.md`、`docs/adr/0002-mvp-implementation-contracts.md` | 已覆盖 |
| Node.js | 固定 Node.js 24.x LTS（基线 24.18.0）+ npm + `package-lock.json`，禁止 EOL Node 进入开发发行包 | `docs/adr/0001-mvp-tech-decisions.md`、`docs/frontend-admin-spec.md` | 已覆盖 |
| 前端版本基线锁定 | P0 使用 Vue 3.5.39、Vite 8.1.3、`@vitejs/plugin-vue` 6.0.7、TypeScript 6.0.3、Element Plus 2.14.2、Pinia 3.0.4、Vue Router 4.6.4、Axios 1.18.1；不得使用 `latest`、`*` 或临场升级主版本 | `docs/adr/0001-mvp-tech-decisions.md`、`docs/frontend-admin-spec.md`、`docs/engineering-skeleton-spec.md`、`docs/coding-start-signoff-package.md` | 已覆盖 |
| Java 技术栈越少越好 | 不引入 Spring Cloud、MQ、ES、K8s、多数据库、多前端框架 | `docs/product-constraints.md`、`docs/coding-freeze-checklist.md` | 已覆盖 |
| P0 不引入 Lombok | 后端手写代码、生成模板和质量门禁均禁止 Lombok 依赖和注解；如未来引入必须先更新 ADR | `docs/adr/0001-mvp-tech-decisions.md`、`docs/product-constraints.md`、`docs/engineering-skeleton-spec.md`、`docs/backend-implementation-spec.md`、`docs/code-generation-design.md`、`docs/quality-gates.md` | 已覆盖 |
| API 并发与重复提交可预测 | P0 使用数据库唯一约束、version 乐观锁、状态条件更新和事务内关系保存；不引入通用幂等中间件或 Redis CRUD 锁 | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/api-conventions.md`、`docs/backend-implementation-spec.md`、`docs/database-baseline.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 请求可追踪且不可伪造 | 服务端生成 traceId，并同步到统一响应体、`X-Trace-Id` 和 MDC；供应商 requestId 单独保存 | `docs/api-conventions.md`、`docs/backend-implementation-spec.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 密码存储不新增安全框架 | JDK 17 PBKDF2-HMAC-SHA256/600000 次、独立 salt 和自描述格式，不引入 Spring Security Crypto，不使用快速摘要 | `docs/security-governance.md`、`docs/basic-admin-spec.md`、`docs/s2-task-breakdown.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 浏览器会话可撤销 | Sa-Token + Redis 不透明随机 Token、HttpOnly Cookie、固定生命周期和全部会话失效；P0 不使用 JWT/Token Secret 或 Web Storage | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/security-governance.md`、`docs/frontend-admin-spec.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 登录与跨站攻击有基础防护 | 账号/IP 双限流、通用失败响应、Origin 和会话绑定 CSRF Token；默认关闭 CORS | `docs/security-governance.md`、`docs/basic-admin-spec.md`、`docs/s2-task-breakdown.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 生产网络暴露默认安全 | local 模式只绑定回环；lan 模式强制 HTTPS；Actuator 独立绑定 `127.0.0.1:8081` | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/release-package-design.md`、`docs/s6-task-breakdown.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| PowerShell 5.1 无额外解析依赖 | 开发/安装脚本固定使用 `ConvertFrom-Json` 读取 devkit/install JSON；Spring Boot 才读取 YAML | `docs/windows-devkit-design.md`、`docs/adr/0002-mvp-implementation-contracts.md`、`docs/release-package-design.md` | 已覆盖但需实现验证 |
| 主流 Admin 参考 | 参考 RuoYi、JeecgBoot、Mars Admin、AgileBoot 等，但不照搬大而全能力 | `docs/competitive-analysis.md`、`docs/vibe-boot-architecture.md` | 已覆盖 |

## 5. 平台与国内体验要求追踪

| 要求 | 当前结论 | 证据文档 | 状态 |
| --- | --- | --- | --- |
| 先做特定平台 | 首版 Windows 优先，Linux/Docker 作为后续增强 | `docs/product-constraints.md`、`docs/windows-devkit-design.md`、`docs/release-package-design.md` | 已覆盖 |
| Java 虽跨平台但先做 Windows | 文档明确首版只把 Windows 开发与生产跑顺 | `docs/vibe-boot-architecture.md`、`docs/windows-devkit-design.md` | 已覆盖 |
| Maven 使用国内镜像 | 默认提供国内 Maven 镜像配置和诊断 | `docs/windows-devkit-design.md`、`docs/s5-task-breakdown.md` | 已覆盖但需实现验证 |
| Node/npm 使用国内镜像 | 默认 npm registry 使用 `npmmirror` | `docs/ai-tool-usage-guide.md`、`docs/windows-devkit-design.md`、`docs/s1-task-breakdown.md` | 已覆盖但需实现验证 |
| Java 环境准备好 | 开发包预置或自动定位 JDK/Maven/Node | `docs/windows-devkit-design.md`、`docs/s5-task-breakdown.md` | 已覆盖但需实现验证 |
| 弱网和企业内网可诊断 | 开发包区分 online/mirror/intranet，doctor 输出镜像可达性、runtime manifest 和缓存缺失风险 | `docs/windows-devkit-design.md`、`docs/s5-task-breakdown.md`、`docs/quality-gates.md`、`docs/s7-demo-acceptance.md` | 已覆盖但需实现验证 |
| 中文提示 | 脚本、模型错误、依赖失败、安装失败都要中文说明 | `docs/quality-gates.md`、`docs/windows-devkit-design.md`、`docs/release-package-design.md` | 已覆盖 |

## 6. 开发模式与生产模式追踪

| 要求 | 当前结论 | 证据文档 | 状态 |
| --- | --- | --- | --- |
| 平台分开发模式和生产模式 | 开发模式用于 AI 改代码，生产模式只运行构建产物 | `docs/product-constraints.md`、`docs/vibe-boot-architecture.md`、`docs/ai-tool-usage-guide.md` | 已覆盖 |
| 开发模式只需接入大模型即可开发 | 用户启动开发包、配置模型后进入 AI 工作台和外部 AI Coding 工具闭环 | `docs/ai-tool-usage-guide.md`、`docs/windows-devkit-design.md`、`docs/model-gateway-spec.md` | 已覆盖但需实现验证 |
| 开发完成后生成生产安装包 | S6 定义 build-prod、install、status、backup、restore | `docs/release-package-design.md`、`docs/s6-task-breakdown.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 开发成果进入生产必须有受控通道 | 生产只接受 build-prod 产物、install/upgrade 和版本化迁移，不接受复制源码、复制开发库、交接包执行、补丁、临时 SQL 或 shell | `docs/product-constraints.md`、`docs/release-package-design.md`、`docs/s6-task-breakdown.md`、`docs/s7-demo-acceptance.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 生产安装包可自动运行部署 | 带外 signer + Authenticode + 签名 package manifest、Procrun LocalService/service SID、健康检查和启停卸载已成文 | `docs/release-package-design.md`、`docs/s6-task-breakdown.md` | 已覆盖但需实现验证 |
| 生产部署状态必须可被脚本可靠判断 | liveness/readiness 分层、回环访问、脱敏明细、稳定状态枚举、60 秒启动门禁和 status 固定退出码已定义 | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/backend-implementation-spec.md`、`docs/release-package-design.md`、`docs/s6-task-breakdown.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 生产安装前必须预检 | 任何写盘前校验 signer/package manifest；写库前检查 JSON/secret、端口、MySQL 双账号、Redis ACL/TLS、磁盘、迁移状态和 AI 白名单 | `docs/release-package-design.md`、`docs/s6-task-breakdown.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 生产包必须包含合规清单 | 生产包必须包含 runtime manifest、依赖 manifest 和 `THIRD-PARTY-NOTICES.txt`，预检校验来源、许可证和 SHA256 | `docs/adr/0001-mvp-tech-decisions.md`、`docs/release-package-design.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 生产禁止开发型 AI | 生产不允许在线改源码、执行开发脚本、改数据库结构 | `docs/adr/0003-ai-tool-usage-boundary.md`、`docs/security-governance.md`、`docs/release-package-design.md` | 已覆盖 |

## 7. AI 工具使用要求追踪

| 要求 | 当前结论 | 证据文档 | 状态 |
| --- | --- | --- | --- |
| 如何使用 AI 工具必须确定 | 文档口径已分层定稿：外部 AI Coding 工具 + 平台 AI 工作台 + 模型网关 + 生产业务 AI，不再作为未定问题悬空；人工签收仍未完成 | `docs/README.md`、`docs/adr/0003-ai-tool-usage-boundary.md`、`docs/ai-tooling-strategy.md`、`docs/ai-tool-usage-guide.md`、`docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md` | 需人工签收 |
| 不首版自研完整 AI IDE | P0 不替代 Codex/Cursor/Claude Code | `docs/ai-tooling-strategy.md`、`docs/ai-tool-usage-guide.md`、`docs/coding-freeze-checklist.md` | 已覆盖 |
| 外部 AI Coding 工具是源码修改主路径 | Codex、Cursor、Claude Code、通义灵码等负责开发模式真实源码修改 | `docs/ai-tool-usage-guide.md`、`docs/external-ai-coding-prompt.md` | 已覆盖 |
| 首次使用 AI 工具要有引导 | 用户解压、检查环境、配置模型、启动开发模式后，应知道如何让 AI 读取上下文并开始任务 | `docs/ai-tool-usage-guide.md`、`docs/product-constraints.md`、`docs/coding-freeze-checklist.md` | 已覆盖 |
| 每次 AI 任务要有准入判断 | 编码许可、任务阶段、执行入口、上下文、风险、验证和生产边界必须先确认 | `docs/ai-tool-usage-guide.md`、`docs/product-constraints.md`、`docs/coding-start-signoff-package.md` | 已覆盖 |
| 平台要能把工作台任务交给外部 AI 工具 | 工作台必须输出外部 AI 交接包，包含阶段、目标、范围、禁止事项、风险、验证命令和输出格式 | `docs/ai-tool-usage-guide.md`、`docs/coding-start-signoff-package.md`、`docs/pre-coding-reader-test.md` | 已覆盖 |
| 企业用户不必直接面对源码 | 企业用户通过 AI 工作台表达需求、确认计划、看结果，实施人员或外部 AI 工具处理源码 | `docs/ai-tool-usage-guide.md`、`docs/ai-workbench-design.md` | 已覆盖 |
| 企业用户不会 AI Coding 工具也能开始 | 平台工作台负责需求、澄清、计划和交接包，实施人员/开发者再使用外部 AI Coding 工具执行工程动作 | `docs/ai-tool-usage-guide.md`、`docs/product-constraints.md`、`docs/coding-freeze-checklist.md` | 已覆盖 |
| AI 工作台必须区分角色入口和状态流转 | 企业管理员、实施人员、Java 开发者和生产用户的可见信息、允许动作和禁止动作不同；任务状态必须能解释澄清、计划、确认、交接、验证、完成、失败或阻塞 | `docs/ai-workbench-design.md`、`docs/ai-workbench-task-breakdown.md`、`docs/quality-gates.md`、`docs/s7-demo-acceptance.md` | 已覆盖 |
| AI 任务必须能解释规则依据 | 每次任务必须展示并审计 `skillSnapshot`、`ruleSnapshot`、`resolutionTrace`、`blockedRules` 和 `warnings`，违反 active must/must-not 规则时不得生成可执行交接包 | `docs/skill-rule-design.md`、`docs/ai-workbench-task-breakdown.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| AI 任务必须能解释数据安全依据 | 每次模型调用必须记录 dataClasses、redactionPolicy、providerRegionRisk 和权限过滤状态，不能只写“已脱敏” | `docs/security-governance.md`、`docs/model-gateway-spec.md`、`docs/ai-workbench-task-breakdown.md` | 已覆盖但需实现验证 |
| AI 能力边界不能过度承诺 | A0-A2 是 MVP 必须满足；A3-A4 是 P1 增强；完整内置 Agent IDE 不做，生产开发 Agent 禁止 | `docs/ai-tool-usage-guide.md`、`docs/coding-freeze-checklist.md`、`docs/pre-coding-reader-test-results.md` | 已覆盖 |
| 数据权限和审计不能只停留在字段 | S2 必须提供数据范围枚举、当前用户上下文、部门树、查询扩展点和审计详情；生成模块必须声明数据范围，未接入时不能宣称已生效 | `docs/security-governance.md`、`docs/basic-admin-spec.md`、`docs/s2-task-breakdown.md`、`docs/database-baseline.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 本地文件能力不能成为任意文件写入入口 | P0 只允许本地单文件白名单上传、鉴权访问、图片预览和两阶段删除；大小、配额、路径、内容签名、内部路径隐藏、无杀毒声明和 AI 上下文边界均已固定 | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/module-design.md`、`docs/security-governance.md`、`docs/api-conventions.md`、`docs/database-baseline.md`、`docs/s2-task-breakdown.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 生产初始管理员不能使用公开默认密码 | Flyway 不写带密码用户；migrate 后由同一 Jar bootstrap-admin 从 stdin 接收初始密码，事务创建 admin 并强制首次改密 | `docs/basic-admin-spec.md`、`docs/database-baseline.md`、`docs/release-package-design.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |
| 备份、恢复和升级回滚必须保持版本与数据一致 | 备份排除全部 secret/模型主密钥并记录指纹；恢复后由维护模式清空本实例 Redis；目标包脚本、state v2 九资源状态、maintenance.flag 和 migrationStarted 决定继续或整套回滚 | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/release-package-design.md`、`docs/s6-task-breakdown.md`、`docs/quality-gates.md`、`docs/s7-demo-acceptance.md` | 已覆盖但需实现验证 |
| AI 修改必须有上下文和验证 | 先读文档、形成计划、标记风险、执行验证、输出摘要 | `docs/external-ai-coding-prompt.md`、`docs/quality-gates.md`、`docs/post-coding-change-control.md` | 已覆盖 |
| 代码补丁应用必须限定在开发工作区 | P0 通用补丁由外部 AI Coding 工具执行；确定性生成器只写 owned 路径；P1 本地执行器需另立 ADR，生产始终禁止 | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/adr/0003-ai-tool-usage-boundary.md`、`docs/ai-tooling-strategy.md`、`docs/code-generation-design.md` | 已覆盖 |
| 外部 AI 交接包不能作为生产执行入口 | 交接包只用于开发和实施链路，不能在生产服务器直接执行补丁、SQL 或 shell | `docs/ai-tool-usage-guide.md`、`docs/external-ai-coding-prompt.md`、`docs/s4-task-breakdown.md`、`docs/windows-devkit-design.md` | 已覆盖 |
| 外部 AI 交接包不是编码授权书 | 交接包不能绕过签收状态、阶段启动口令、允许范围和质量门禁 | `docs/ai-tool-usage-guide.md`、`docs/adr/0003-ai-tool-usage-boundary.md`、`docs/coding-start-signoff.md` | 已覆盖 |
| 生成代码必须可接管可二次生成 | 生成产物必须像人工代码，二次生成不得静默覆盖人工修改，冲突、模板版本、元模型 hash 和产物所有权必须可追踪 | `docs/code-generation-design.md`、`docs/s4-task-breakdown.md`、`docs/backend-implementation-spec.md`、`docs/frontend-admin-spec.md`、`docs/quality-gates.md` | 已覆盖但需实现验证 |

## 8. 编码准入与签收追踪

| 要求 | 当前结论 | 证据文档 | 状态 |
| --- | --- | --- | --- |
| 编码前始终优先修订文档 | 当前只允许修订 `docs/`，未签收不得创建源码目录 | `docs/README.md`、`docs/coding-start-signoff.md` | 需人工签收 |
| 形成产品约束后再编码 | 产品、技术、AI、交付、安全、质量、变更控制均已有约束文档 | `docs/product-constraints.md`、`docs/documentation-readiness-review.md` | 已覆盖 |
| 当前方案是否已经满足编码 | 技术约束修订后可进入人工签收，但不满足直接编码；仍缺签收基线、最终审查确认、签收记录、精确口令、S1 stageAdmission 和开工检查 | `docs/coding-start-signoff-package.md`、`docs/implementation-readiness-audit.md`、`docs/coding-start-signoff.md` | 需人工签收 |
| S1 只做工程骨架 | 签收后也只能创建工程骨架，不得实现业务 | `docs/s1-implementation-work-order.md`、`docs/s1-task-breakdown.md` | 需人工签收 |
| S1 工作令不是开工许可 | 工作令只是施工说明，签收记录和精确启动口令 `开始 S1 工程骨架编码` 才是授权来源；口令不得带句号、冒号或额外后缀 | `docs/coding-start-signoff.md`、`docs/coding-start-signoff-package.md`、`docs/coding-freeze-checklist.md` | 需人工签收 |
| S1 创建源码目录前必须先持久化准入并开工检查 | 精确口令后先写 **docs/stage-records/S1-admission.md**，再输出签收、口令、准入路径、目录基线、范围和 `admissionCard.result`；任一失败不得编码 | `docs/s1-implementation-work-order.md`、`docs/external-ai-coding-prompt.md`、`docs/quality-gates.md`、`docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md` | 需人工签收 |
| 签收仓库基线必须明确 | 进入 S1 前必须明确提交哈希；如签收未提交工作区，必须生成包含路径和 SHA256 的签收文档 manifest；未纳入签收基线的草稿不得作为编码依据 | `docs/README.md`、`docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md`、`docs/coding-freeze-checklist.md` | 需人工签收 |
| 签收前预检必须可执行 | 进入 S1 前必须复查 Git 状态、README 索引、Markdown 引用、签收文档 manifest、源码目录、签收状态和忽略规则；任一失败不得签收 | `docs/README.md`、`docs/coding-start-signoff-package.md`、`docs/documentation-maintenance-guide.md`、`docs/documentation-verification-log.md` | 需人工签收 |
| 签收前最终审查必须逐项确认 | 进入 S1 前必须确认产品范围、技术栈、Windows 优先、AI 分层、安全、合规、发布、S1 范围和变更控制；`docs/coding-start-signoff.md` 第 4 节必须包含并签收“签收前最终审查表已逐项确认”；最终审查表不能替代正式签收 | `docs/README.md`、`docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md`、`docs/implementation-readiness-audit.md` | 需人工签收 |
| 模糊表达不能等价签收 | “同意”“可以开始”“按文档做”等表达不构成签收；等价确认必须包含签收包接受、S1 范围、最终审查表全部确认、全部签收项、签收人、签收日期和签收基线 | `docs/coding-start-signoff.md`、`docs/coding-start-signoff-package.md`、`docs/pre-coding-reader-test.md`、`docs/coding-freeze-checklist.md` | 需人工签收 |
| S2-S7 阶段任务分解不是开工许可 | 阶段任务文档只是施工依据，必须前置阶段完成、通过门禁，并由维护者明确启动对应阶段 | `docs/s2-task-breakdown.md`、`docs/s3-task-breakdown.md`、`docs/s4-task-breakdown.md`、`docs/s5-task-breakdown.md`、`docs/s6-task-breakdown.md`、`docs/s7-demo-acceptance.md` | 已覆盖 |
| 编码后仍文档优先 | 新请求按 C0-C4 判断，超范围先回文档或 ADR | `docs/post-coding-change-control.md` | 已覆盖 |
| 阶段完成必须有关闭证据包 | 每个阶段完成必须记录交付物、验证结果、越界检查、文档同步、残余风险和下一阶段请求；证据包不自动授权下一阶段 | `docs/post-coding-change-control.md`、`docs/quality-gates.md`、`docs/mvp-roadmap.md` | 已覆盖 |
| S1 输出摘要必须包含关闭证据包 | S1 完成摘要必须把开工检查、准入卡、交付物、验证、越界检查、文档同步、残余风险和下一阶段请求串成可复查证据 | `docs/s1-implementation-work-order.md`、`docs/external-ai-coding-prompt.md`、`docs/s1-task-breakdown.md`、`docs/quality-gates.md` | 已覆盖 |
| C0 不绕过签收和阶段启动 | C0 只有阶段已签收、维护者发出阶段启动指令且请求完全落在阶段任务内时成立；未签收时只允许修订文档 | `docs/post-coding-change-control.md`、`docs/coding-start-signoff-package.md`、`docs/external-ai-coding-prompt.md`、`docs/s1-implementation-work-order.md` | 需人工签收 |
| 质量门禁不能替代变更授权 | 构建或测试通过只能证明可运行，不能把 C2-C4 越界请求变成 C0 | `docs/post-coding-change-control.md`、`docs/quality-gates.md`、`docs/coding-start-signoff.md`、`docs/pre-coding-reader-test.md` | 已覆盖 |
| 最终签收入口 | 签收包已汇总最终承诺，签收状态仍以签收记录为准 | `docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md` | 需人工签收 |

## 9. 未完成但不阻塞 S1 签收准备的实现验证

以下不是文档缺口，也不表示当前允许编码；它们只是后续编码和验收要证明的事项。

| 事项 | 验证阶段 | 验证依据 |
| --- | --- | --- |
| Maven/npm 国内镜像真实可用 | S1/S5 | `docs/quality-gates.md`、`docs/s5-task-breakdown.md` |
| JDK/Maven/Node runtime 打包体验 | S5 | `docs/windows-devkit-design.md` |
| 模型网关连接测试 | S3 | `docs/model-gateway-spec.md`、`docs/s3-task-breakdown.md` |
| AI 工作台需求到计划闭环 | S4 | `docs/ai-workbench-task-breakdown.md` |
| 客户拜访记录端到端演示 | S7 | `docs/customer-visit-demo-spec.md`、`docs/s7-demo-acceptance.md` |
| 生产安装包自动部署 | S6 | `docs/release-package-design.md`、`docs/s6-task-breakdown.md` |
| 第三方依赖 NOTICE 和 manifest 生成 | S5/S6 | `docs/product-constraints.md`、`docs/windows-devkit-design.md`、`docs/release-package-design.md`、`docs/quality-gates.md` |

## 10. 当前结论

| 问题 | 结论 |
| --- | --- |
| 原始产品要求是否有文档证据 | 是 |
| 是否还有必须先补的产品约束文档 | 暂未发现 |
| 当前方案是否已经满足编码 | 否，只满足签收前审查；仍需预检、签收基线、最终审查确认、签收记录、精确启动口令和 S1 开工检查 |
| 是否可以直接开始编码 | 否，仍需签收 |
| 未签收前允许做什么 | 继续修订和审计文档 |
| 签收依据是什么 | 必须是明确提交哈希；如签收未提交工作区，必须是签收文档 manifest 的生成时间、文件数量、纳入范围和 SHA256 清单，并覆盖 Markdown 与 JSON 机器契约 |
| 签收前要跑什么预检 | Git 状态、README 索引、Markdown 引用、签收文档 manifest、源码目录、签收状态和忽略规则 |
| 签收前还要确认什么 | 必须逐项确认签收包第 3.2 节最终审查表；不能用模糊同意替代 |
| 签收后第一步是什么 | 在维护者明确说出精确启动口令 `开始 S1 工程骨架编码` 后，先输出 S1 开工检查；通过后才只能按 S1 工作令做工程骨架 |
| 阶段怎么结束 | 必须输出阶段关闭证据包；证据包通过后只是申请关闭当前阶段，不能自动进入下一阶段 |
| S1 完成摘要必须包含什么 | 开工检查、AI 使用准入卡、变更摘要、任务状态、验证结果、越界检查、阶段关闭证据包、风险和下一步 |
| C0 是否可以绕过未签收状态 | 否，未签收或阶段未启动时 C0 不成立 |
| 补丁或写入文件是否可以在服务端或生产执行 | 否，只限开发工作区；生产只接收受控安装包和迁移流程 |
| 外部 AI 交接包是否可以直接在生产执行 | 否，交接包只是开发和实施交接输入 |
| 是否可以复制开发源码或开发数据库到生产作为发布方式 | 否，生产发布必须走 build-prod、install/upgrade 和版本化迁移 |

## 11. 一句话总结

Vibe Boot 当前文档已经覆盖原始产品设想的关键约束：面向中国中小企业、Windows 优先、最小 Java/Vue 技术栈、AI 工具使用方式已分层定稿、外部 AI Coding 工具主导真实源码修改、平台 AI 工作台产品化需求流程、生产禁用开发型 AI，并通过签收包和变更控制防止编码阶段范围失控。
