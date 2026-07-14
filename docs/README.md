# Vibe Boot 文档索引

## 1. 文档优先原则

Vibe Boot 当前处于编码前产品与架构收敛阶段。进入编码实现前，新增范围、技术选型、部署方式、安全策略、AI 工作流变化，都必须先修订文档。

## 2. 阅读顺序

| 顺序 | 文档 | 用途 |
| --- | --- | --- |
| 1 | `vibe-boot-architecture.md` | 总体架构与产品方向 |
| 2 | `product-constraints.md` | 产品约束、技术约束、实现准入 |
| 3 | `competitive-analysis.md` | 竞品和差异化定位 |
| 4 | `adr/0001-mvp-tech-decisions.md` | MVP 首版技术选型 |
| 5 | `adr/0002-mvp-implementation-contracts.md` | MVP 实现契约 |
| 6 | `adr/0003-ai-tool-usage-boundary.md` | AI 工具使用边界 |
| 7 | `module-design.md` | 后端模块、前端目录、依赖边界 |
| 8 | `terminology-and-naming.md` | 术语、模块、目录、状态、权限和脚本命名规范 |
| 9 | `backend-implementation-spec.md` | Spring Boot 后端分层、事务、权限、异常和生成规范 |
| 10 | `frontend-admin-spec.md` | Vue 管理端布局、路由、权限、页面和生成规范 |
| 11 | `ai-tooling-strategy.md` | 外部 AI coding 工具、平台内 AI 工作台、模型网关的分工 |
| 12 | `ai-tool-usage-guide.md` | 开发者、企业用户和生产环境如何使用 AI 工具 |
| 13 | `external-ai-coding-prompt.md` | 外部 AI Coding 工具标准提示词 |
| 14 | `model-gateway-spec.md` | S3 模型网关配置、调用、错误和用量规格 |
| 15 | `s3-task-breakdown.md` | S3 模型网关任务分解、顺序和交付物 |
| 16 | `ai-workbench-design.md` | AI 工作台设计 |
| 17 | `ai-workbench-task-breakdown.md` | S4 AI 工作台基础子任务、边界和交付物 |
| 18 | `skill-rule-design.md` | Skills 与规则设计 |
| 19 | `code-generation-design.md` | 代码生成设计；机器契约见 `contracts/codegen-meta-model-v1.schema.json`，标准样例见 `contracts/examples/customer-visit-meta-model-v1.json` |
| 20 | `s4-task-breakdown.md` | S4 AI 工作台与代码生成闭环任务分解、边界和交付物 |
| 21 | `quality-gates.md` | 质量门禁、验证命令、失败处理和阶段验收 |
| 22 | `windows-devkit-design.md` | Windows 开发包设计 |
| 23 | `s5-task-breakdown.md` | S5 Windows 开发包任务分解、边界和交付物 |
| 24 | `release-package-design.md` | 生产安装包设计 |
| 25 | `s6-task-breakdown.md` | S6 生产安装包任务分解、边界和交付物 |
| 26 | `security-governance.md` | 安全治理设计 |
| 27 | `mvp-roadmap.md` | MVP 路线和实现准入 |
| 28 | `implementation-readiness-audit.md` | 编码实现准入审计和 S1 开工清单 |
| 29 | `coding-freeze-checklist.md` | 编码前冻结确认清单 |
| 30 | `documentation-readiness-review.md` | 编码前文档就绪审计报告 |
| 31 | `documentation-maintenance-guide.md` | 文档维护规则、同步规则和引用检查 |
| 32 | `post-coding-change-control.md` | 编码后变更控制、范围变化和阶段推进规则 |
| 33 | `pre-coding-reader-test.md` | 编码前读者测试问题集 |
| 34 | `pre-coding-reader-test-results.md` | 编码前读者测试执行结果 |
| 35 | `requirements-traceability-matrix.md` | 原始产品要求到文档证据的追踪矩阵 |
| 36 | `documentation-verification-log.md` | 文档索引、引用、manifest、最终审查表、签收状态和目录状态验证日志 |
| 37 | `coding-start-signoff-package.md` | 编码启动最终人工签收包 |
| 38 | `coding-start-signoff.md` | 编码启动人工签收记录 |
| 39 | `s1-implementation-work-order.md` | S1 工程骨架实施工作令 |
| 40 | `engineering-skeleton-spec.md` | S1 工程骨架施工规格 |
| 41 | `s1-task-breakdown.md` | S1 工程骨架任务分解、顺序和交付物 |
| 42 | `basic-admin-spec.md` | S2 基础后台功能、权限、页面和验收规格 |
| 43 | `s2-task-breakdown.md` | S2 基础后台任务分解、顺序和交付物 |
| 44 | `customer-visit-demo-spec.md` | MVP 客户拜访记录演示用例 |
| 45 | `s7-demo-acceptance.md` | S7 MVP 端到端演示验收剧本 |
| 46 | `api-conventions.md` | API、响应、分页、错误码、权限标识规范 |
| 47 | `database-baseline.md` | MySQL 表域、基础字段、Flyway 迁移和 P0 表清单 |

### 2.1 机器契约

下列文件与 Markdown 具有同等签收效力，必须进入提交基线或签收 manifest；它们不参与上方 Markdown 编号统计。

| 文件 | 用途 |
| --- | --- |
| `contracts/codegen-meta-model-v1.schema.json` | P0 代码生成元模型 Draft 2020-12 Schema |
| `contracts/examples/customer-visit-meta-model-v1.json` | 客户拜访记录标准元模型输入 |
| `contracts/install-v1.schema.json` | Windows 生产安装配置 Draft 2020-12 Schema |
| `contracts/examples/install-v1.example.json` | Windows 生产安装配置标准样例 |

## 3. 当前关键决策

| 决策 | 结果 | 来源 |
| --- | --- | --- |
| 首版平台 | Windows 优先 | `product-constraints.md` |
| 架构形态 | 模块化单体 | `vibe-boot-architecture.md` |
| 后端 | JDK 17 + Spring Boot 3.5.16 + Maven 3.8 | `adr/0001-mvp-tech-decisions.md` |
| 权限 | Sa-Token 1.45.0 | `adr/0001-mvp-tech-decisions.md` |
| ORM | MyBatis-Plus 3.5.16 | `adr/0001-mvp-tech-decisions.md` |
| 数据库 | MySQL 8 | `product-constraints.md` |
| 迁移 | classpath 唯一权威源 + 同一 Jar 的一次性 Flyway 维护模式；常驻服务无 DDL 权限，包外 SQL 仅作审计副本 | `adr/0002-mvp-implementation-contracts.md`、`database-baseline.md` |
| 缓存 | Redis | `product-constraints.md` |
| 前端 | Vue 3.5.39 + Vite 8.1.3 + TypeScript 6.0.3 + Element Plus 2.14.2 + Pinia 3.0.4 + Vue Router 4.6.4 + Axios 1.18.1 | `adr/0001-mvp-tech-decisions.md` |
| Node | Node.js 24.x LTS（基线 24.18.0）+ npm | `adr/0001-mvp-tech-decisions.md` |
| API 文档 | Springdoc OpenAPI 2.8.17 | `adr/0001-mvp-tech-decisions.md` |
| 代码模板 | Velocity 2.4.1 | `adr/0001-mvp-tech-decisions.md` |
| 机器契约 | 代码生成元模型与安装配置均使用 Draft 2020-12 JSON Schema + 标准样例；内嵌副本必须机器比较一致 | `contracts/`、`code-generation-design.md`、`release-package-design.md` |
| Windows 服务 | Apache Commons Daemon Procrun 1.6.1 x64 | `adr/0001-mvp-tech-decisions.md` |
| AI 协议 | OpenAI 兼容接口优先 | `adr/0001-mvp-tech-decisions.md` |
| AI 工具边界 | 三层 AI 工具模式，P0 不自研完整 AI IDE | `adr/0003-ai-tool-usage-boundary.md` |
| AI 使用模型 | 外部 AI Coding 工具 + 平台 AI 工作台 + 模型网关 + skills/规则，文档口径已分层定稿，不再作为未定问题悬空；当前仍待人工签收 | `product-constraints.md`、`ai-tooling-strategy.md`、`ai-tool-usage-guide.md` |
| AI 工具分工 | 外部 AI coding 工具负责开发实现，平台内 AI 工作台负责受控业务生成 | `ai-tooling-strategy.md` |
| AI 用户入口 | 维护者用外部 AI Coding 工具，企业用户用平台 AI 工作台，生产用户只用业务 AI | `ai-tool-usage-guide.md` |
| AI 使用路径产品化 | 首次使用有引导，工作台能输出外部 AI 交接包，企业用户不必懂源码 | `ai-tool-usage-guide.md`、`product-constraints.md` |
| AI 工具使用责任边界 | 企业用户走平台 AI 工作台，实施人员/开发者用外部 AI Coding 工具，生产用户只用业务 AI | `ai-tool-usage-guide.md`、`product-constraints.md` |
| AI 工具托底路径 | 企业用户不会 AI Coding 工具时，平台工作台负责需求和交接包，实施人员/开发者负责工程执行 | `ai-tool-usage-guide.md`、`product-constraints.md` |
| AI 使用准入卡 | 每次 AI 任务先确认编码许可、任务阶段、执行入口、上下文、风险、验证和生产边界 | `ai-tool-usage-guide.md`、`quality-gates.md` |
| S1 开工检查 | 签收并收到精确启动口令后，创建源码目录前仍必须先输出结构化开工检查 | `s1-implementation-work-order.md`、`external-ai-coding-prompt.md`、`quality-gates.md` |
| Skills/规则审计 | AI 任务必须记录 skill/rule 版本快照、来源、冲突裁决、阻断项和警告项 | `skill-rule-design.md`、`quality-gates.md` |
| 模型数据安全 | 模型调用前必须做数据分类、最小化、脱敏、数据权限过滤和出境风险提示 | `security-governance.md`、`model-gateway-spec.md`、`quality-gates.md` |
| AI 执行边界 | 补丁和文件写入只限开发工作区，外部 AI 交接包不能作为生产执行入口 | `coding-freeze-checklist.md`、`quality-gates.md`、`s6-task-breakdown.md` |
| AI 交接包授权边界 | 外部 AI 交接包只是执行上下文，不替代签收状态、阶段启动口令、允许范围和质量门禁 | `ai-tool-usage-guide.md`、`adr/0003-ai-tool-usage-boundary.md` |
| 生产 AI 白名单 | 生产模型配置只允许业务问答、摘要、分类、文案、分析和连接测试，不恢复开发型 AI | `security-governance.md`、`release-package-design.md`、`quality-gates.md` |
| 受控发布通道 | 开发成果只能通过 build-prod、install/upgrade、版本化迁移和健康检查进入生产 | `product-constraints.md`、`release-package-design.md`、`s6-task-breakdown.md` |
| 开源合规边界 | 开发包提供 runtime manifest/NOTICE；生产包提供 runtime manifest、依赖 manifest 和 NOTICE，并记录来源、版本、许可证及 SHA256 | `product-constraints.md`、`windows-devkit-design.md`、`release-package-design.md`、`quality-gates.md` |
| 阶段准入 | S1-S7 每阶段都有冻结口令和 `stageAdmission`；上一阶段证据、基线、范围、授权人和时间缺一不可 | `post-coding-change-control.md` |
| 签收仓库基线 | 进入 S1 前必须明确提交哈希；如签收未提交工作区，必须生成覆盖 Markdown 与 JSON 机器契约的路径/SHA256 manifest | `coding-start-signoff-package.md`、`coding-start-signoff.md` |
| 签收前预检命令包 | 签收前必须复查 Git 状态、README 索引、Markdown 引用、JSON Schema/样例及内嵌副本、全文件 manifest、源码目录、签收状态和忽略规则 | `coding-start-signoff-package.md`、`documentation-maintenance-guide.md`、`documentation-verification-log.md` |
| 签收前最终审查表 | 签收前必须逐项确认产品范围、技术栈、Windows 优先、AI 分层、安全、合规、发布、S1 范围和变更控制 | `coding-start-signoff-package.md`、`coding-start-signoff.md` |
| 当前编码判定 | 技术文档已达到可提交签收的实现基线，但不满足直接编码；仍缺签收基线、最终审查确认、签收记录、精确启动口令、S1 `stageAdmission` 和开工检查 | `coding-start-signoff-package.md`、`implementation-readiness-audit.md`、`coding-start-signoff.md` |
| 阶段关闭证据包 | 每个阶段完成时必须记录交付物、验证、越界检查、文档同步、残余风险和下一阶段请求；不自动授权下一阶段 | `post-coding-change-control.md`、`quality-gates.md`、`mvp-roadmap.md` |
| S1 关闭证据包 | S1 输出摘要必须包含阶段关闭证据包，且只能申请关闭 S1，不能自动授权 S2 | `s1-implementation-work-order.md`、`external-ai-coding-prompt.md`、`s1-task-breakdown.md` |
| 后端实现模式 | Controller 薄、Service 稳、Mapper 简、DTO/VO 清晰 | `backend-implementation-spec.md` |
| 前端页面模式 | Element Plus 管理端统一布局、列表、表单、权限按钮 | `frontend-admin-spec.md` |
| 验证门禁 | Maven、npm、doctor、build-prod、install 分阶段验证 | `quality-gates.md` |
| API 响应 | `Result<T>` + `PageResult<T>` | `api-conventions.md` |
| 错误码 | `{DOMAIN}_{CODE}` | `api-conventions.md` |
| 数据库主键 | 雪花 ID | `database-baseline.md` |

## 4. 编码闸门

进入工程骨架编码前，必须满足：

本节的“已满足”只表示文档材料存在、口径已成文或检查项可复查，不表示当前已经允许编码。当前是否允许开始 S1，仍以 `coding-start-signoff.md` 的签收状态和维护者启动口令为准。

| 闸门 | 状态 |
| --- | --- |
| 总体架构文档存在 | 已满足 |
| 产品约束文档存在 | 已满足 |
| 竞品定位文档存在 | 已满足 |
| 模块设计文档存在 | 已满足 |
| 术语与命名规范存在 | 已满足 |
| 后端实现规范存在 | 已满足 |
| 前端管理端规格存在 | 已满足 |
| AI 工作台文档存在 | 已满足 |
| AI 工作台任务分解存在 | 已满足 |
| AI 工具使用策略存在 | 已满足 |
| AI 工具使用指南存在 | 已满足 |
| 外部 AI Coding 工具标准提示词存在 | 已满足 |
| S3 模型网关规格存在 | 已满足 |
| S3 模型网关任务分解存在 | 已满足 |
| Skills 与规则文档存在 | 已满足 |
| 代码生成文档存在 | 已满足 |
| 代码生成与安装 JSON Schema/标准样例存在并可校验 | 已满足，仍必须纳入签收基线 |
| S4 AI 工作台与代码生成任务分解存在 | 已满足 |
| 质量门禁文档存在 | 已满足 |
| Windows 开发包文档存在 | 已满足 |
| S5 Windows 开发包任务分解存在 | 已满足 |
| 生产安装包文档存在 | 已满足 |
| S6 生产安装包任务分解存在 | 已满足 |
| 安全治理文档存在 | 已满足 |
| MVP 路线文档存在 | 已满足 |
| 编码实现准入审计存在 | 已满足 |
| 编码前冻结确认清单存在 | 已满足 |
| 编码前文档就绪审计报告存在 | 已满足 |
| 文档维护规则存在 | 已满足 |
| 编码后变更控制存在 | 已满足 |
| 编码前读者测试存在 | 已满足 |
| 编码前读者测试结果存在 | 已满足，第一轮 FAIL 已留痕，十项阻塞修订后第二轮技术复测通过 |
| 需求追踪矩阵存在 | 已满足 |
| 文档验证日志存在 | 已满足 |
| 编码启动签收包存在 | 已满足 |
| 编码启动签收记录存在 | 已满足，当前未签收 |
| 签收仓库基线规则存在 | 已满足，签收前必须确认提交哈希；如签收未提交工作区，manifest 必须覆盖 Markdown 与 JSON 机器契约 |
| 签收前预检命令包存在 | 已满足，签收前必须复查 Git 状态、索引、引用、Schema/样例同步、全文件 manifest、源码目录、签收状态和忽略规则 |
| 签收前最终审查表存在 | 已满足，签收前必须逐项确认产品、技术、AI、安全、合规、发布、S1 和变更控制 |
| 当前编码判定已明确 | 已满足，当前只满足签收前审查，不满足直接编码 |
| 文档准入不自动授权编码 | 已满足，仍需签收记录和启动口令 |
| 阶段关闭证据包规则存在 | 已满足，阶段完成必须有交付物、验证、越界检查、文档同步和残余风险证据 |
| S1 输出摘要包含关闭证据包 | 已满足，S1 完成时必须提交阶段关闭证据包，不能自动进入 S2 |
| S1 开工检查模板存在 | 已满足，签收后创建源码目录前仍需先检查签收、口令、目录基线、允许范围、禁止范围和 `admissionCard.result` |
| AI 工具使用模型口径 | 已成文，仍需人工签收 |
| 阶段任务分解不自动授权编码 | S1-S7 任务文档只是阶段施工依据，必须对应阶段已签收并由维护者明确启动 |
| AI 工具使用路径产品化 | 已满足 |
| 文档新增受控规则 | 已满足 |
| S1 工程骨架实施工作令存在 | 已满足 |
| MVP 技术决策 ADR 存在 | 已满足 |
| MVP 实现契约 ADR 存在 | 已满足 |
| AI 工具使用边界 ADR 存在 | 已满足 |
| S1 工程骨架规格存在 | 已满足 |
| S1 工程骨架任务分解存在 | 已满足 |
| S2 基础后台规格存在 | 已满足 |
| S2 基础后台任务分解存在 | 已满足 |
| MVP 演示用例规格存在 | 已满足 |
| S7 MVP 演示验收剧本存在 | 已满足 |
| API 与错误码规范存在 | 已满足 |
| 数据库基线规范存在 | 已满足 |

## 5. 下一步建议

文档层面已经具备进入 S1 工程骨架签收准备的基础。真正编码前应先阅读 `implementation-readiness-audit.md`、`coding-freeze-checklist.md`、`documentation-readiness-review.md`、`post-coding-change-control.md`、`pre-coding-reader-test.md`、`pre-coding-reader-test-results.md`、`requirements-traceability-matrix.md`、`documentation-verification-log.md`、`coding-start-signoff-package.md` 和 `coding-start-signoff.md` 并做一次人工签收：

| 评审项 | 目的 |
| --- | --- |
| P0 范围是否过大 | 防止 MVP 膨胀 |
| P0/P1 范围是否冻结 | 确认 P0 最小开发闭环和 P1 MVP 交付闭环都不继续扩范围 |
| Windows 开发包是否可交付 | 确认 runtime 和脚本策略 |
| AI 工作台是否过重 | 确认 P0 只做必要闭环 |
| 模型网关是否够轻 | 确认 OpenAI 兼容优先，不扩成通用模型平台 |
| 前端页面模式是否统一 | 确认列表、表单、权限按钮、动态菜单能支撑 AI 生成 |
| 质量门禁是否可执行 | 确认每个阶段都有明确命令、失败处理和验收标准 |
| 编码后变更控制是否清晰 | 确认开始编码后仍能防止新增依赖、阶段偷跑和范围漂移 |
| 安全底线是否明确 | 确认生产禁用代码编辑和密钥策略 |
| S1 工程骨架是否足够小 | 确认只搭地基，不提前做业务 |
| S2 基础后台是否够稳 | 确认权限、菜单、字典、日志能支撑后续 AI 生成 |
| 首个演示是否清晰 | 确认客户拜访记录模块和 S7 验收剧本作为端到端用例 |
| 读者测试是否通过 | 确认新维护者或外部 AI 能正确回答当前是否允许编码和 S1 边界 |
| 读者测试结果是否复核 | 确认当前测试结果仍然匹配最新文档 |
| 原始需求是否有证据 | 确认主要产品要求均能映射到文档证据 |
| 文档验证是否通过 | 确认索引、引用、签收状态、忽略规则和源码目录状态可复查 |
| 签收仓库基线是否确认 | 确认签收依据是已提交文档快照；如签收未提交工作区，确认 manifest 生成时间、文件数量、纳入范围和 SHA256 清单，覆盖 Markdown 与 JSON 机器契约 |
| 签收前预检是否执行 | 确认 `git status`、README 索引、Markdown 引用、签收文档 manifest、源码目录、签收状态和忽略规则检查已执行 |
| 签收前最终审查表是否确认 | 确认签收包第 3.2 节全部审查域已明确接受或退回修订 |
| 当前编码判定是否接受 | 确认当前只满足签收前审查，不满足直接编码；真正开工还缺签收基线、最终审查确认、签收记录、精确启动口令和 S1 开工检查 |
| 阶段关闭证据包是否接受 | 确认每个阶段完成时不能只说“已完成”，必须给出证据包，且下一阶段仍需维护者明确启动 |
| S1 输出摘要是否接受 | 确认 S1 输出摘要必须同时包含开工检查、准入卡、变更摘要、验证、越界检查和阶段关闭证据包 |
| 签收包是否接受 | 确认最终人工签收包中的产品、技术、AI、S1 和变更控制承诺 |
| 等价签收是否完整 | 确认等价签收必须包含签收包接受、S1 范围、全部签收项、签收人和签收日期 |
| 模糊签收是否排除 | 确认“同意”“可以开始”“按文档做”等表达不构成签收 |
| S1 启动口令是否精确 | 确认启动口令必须是 `开始 S1 工程骨架编码`，不得带句号、冒号或额外后缀 |
| S1 开工检查是否接受 | 确认签收和启动口令满足后，创建源码目录前仍必须先输出结构化 S1 开工检查 |
| AI 工具使用方式是否分层定稿 | 确认外部 AI Coding 工具、平台 AI 工作台、模型网关和生产业务 AI 的分工已定稿；如要改变，先修订 ADR 和签收材料 |
| AI 工具使用模型是否接受 | 确认首版不重新解释为完整 AI IDE、生产 Agent 或普通 Chat 外壳 |
| AI 工具使用路径是否接受 | 确认首次使用引导、外部 AI 交接包、企业用户不必懂源码和能力成熟度分层 |
| AI 工具责任边界是否接受 | 确认企业用户、实施人员、开发者、外部 AI Coding 工具、平台 AI 工作台和生产业务 AI 的分工 |
| AI 执行边界是否接受 | 确认补丁和文件写入只限开发工作区，生产不执行交接包、补丁、SQL 或 shell |
| 模型数据安全是否接受 | 确认企业业务数据进入模型前必须分类、最小化、脱敏和提示出境风险 |
| 生产 AI 白名单是否接受 | 确认生产模型配置不恢复代码生成、补丁应用、源码读取、文件写入、shell 或在线 SQL |
| 受控发布通道是否接受 | 确认生产发布只能走 build-prod、install/upgrade、版本化迁移和健康检查 |
| 开源合规边界是否接受 | 确认第三方依赖、runtime、工具来源和许可证清单必须进入开发包/生产包验收 |
| 文档新增是否受控 | 确认后续优先修订已有文档，非必要不新增文档 |
| 文档准入是否被误解为开工许可 | 确认文档准入、冻结清单和 S1 工作令都不单独授权编码 |
| 编码启动是否签收 | 确认 `coding-start-signoff.md` 已由维护者签收 |

## 6. 维护规则

| 规则 | 说明 |
| --- | --- |
| 新增技术依赖 | 先修改 ADR 或产品约束 |
| 新增模块 | 先修改模块设计和 MVP 路线 |
| 新增 AI 能力 | 先修改 AI 工作台和规则文档 |
| 修改 Skills/规则 | 先修改规则来源文档、`skill-rule-design.md` 和相关质量门禁；不得用临时提示词绕过 active 规则 |
| 新增模型上下文来源 | 先确认数据分类、最小化、脱敏、权限过滤和出境风险 |
| 新增第三方依赖或 runtime | 先确认来源、版本、用途、许可证和是否进入发行包 |
| 新增部署能力 | 先修改 Windows 开发包或生产安装包文档 |
| 修改安全策略 | 先修改安全治理文档 |
| 新增重要文档 | 先判断能否修订已有文档；确需新增时按 `documentation-maintenance-guide.md` 同步 README、准入审计和冻结清单 |
| 进入编码实现 | 必须确认本索引中的编码闸门仍然满足 |
