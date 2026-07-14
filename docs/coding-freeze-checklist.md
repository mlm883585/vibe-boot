# Vibe Boot 编码前冻结确认清单

## 1. 文档目的

本文定义 Vibe Boot 从“文档优先阶段”进入“编码实现阶段”前必须完成的冻结确认。

它不是新的需求来源，而是最终闸门：把已经分散在产品约束、路线图、ADR、准入审计、质量门禁和任务分解中的关键约束，整理成一张可签收、可复查、可防止范围漂移的清单。

冻结项的实际签收记录见 `docs/coding-start-signoff.md`。本文定义“签什么”，签收记录定义“是否已经签”。

## 2. 冻结结论口径

| 状态 | 含义 |
| --- | --- |
| 已冻结 | 进入编码后默认不再讨论，除非走变更流程 |
| 可实现后验证 | 文档已定义标准，真实完成情况由代码、脚本、测试或演示证明 |
| 暂不冻结 | 仍有产品或技术分歧，不应开始相关编码 |
| 变更需重审 | 编码后如需调整，必须先更新文档、ADR 或路线图 |

冻结不表示产品完成，也不自动授权编码；它只表示文档已具备进入签收流程的基础，真正开工仍以 `docs/coding-start-signoff.md` 和启动口令为准。

## 3. 必须冻结的产品范围

| 项目 | 冻结内容 | 证据 |
| --- | --- | --- |
| 产品定位 | AI 原生 Java/Vue 模块化单体，不做传统低代码运行时 | `docs/product-constraints.md` |
| 目标用户 | 中国中小企业、实施人员、Java 全栈开发者 | `docs/product-constraints.md` |
| 首版平台 | Windows 优先，Linux/Docker 延后 | `docs/product-constraints.md`、`docs/windows-devkit-design.md` |
| MVP 闭环 | Windows 开发包、模型接入、AI 工作台、单表 CRUD、生产安装包 | `docs/mvp-roadmap.md` |
| 优先级口径 | P0 是最小开发闭环，P1 是 MVP 完整交付闭环，P2 是 MVP 后增强 | `docs/mvp-roadmap.md` |
| 术语与命名 | 模块、目录、脚本、状态、权限和 API 命名统一 | `docs/terminology-and-naming.md` |
| 文档维护规则 | 新增文档、修改文档、ADR 和引用同步规则明确 | `docs/documentation-maintenance-guide.md` |
| 编码后变更控制 | 编码开始后按 C0-C4 处理新增请求、范围变化和阶段推进 | `docs/post-coding-change-control.md` |
| 编码前读者测试结果 | 当前文档已通过一次自测式 Reader Test | `docs/pre-coding-reader-test-results.md` |
| 需求追踪矩阵 | 原始产品要求已映射到当前文档证据 | `docs/requirements-traceability-matrix.md` |
| 文档验证日志 | 当前文档索引、引用、签收状态、目录状态和忽略规则已有验证快照 | `docs/documentation-verification-log.md` |
| 编码启动签收包 | 最终人工确认入口已压缩产品、技术、AI、S1 和变更控制承诺 | `docs/coding-start-signoff-package.md` |
| 签收仓库基线 | 进入 S1 前必须明确提交哈希；如签收未提交工作区，必须生成包含路径和 SHA256 的签收文档 manifest，未纳入签收基线的草稿不得作为编码依据 | `docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md` |
| 签收前预检命令包 | 进入 S1 前必须执行 Git 状态、README 索引、Markdown 引用、签收文档 manifest、源码目录、签收状态和忽略规则检查 | `docs/coding-start-signoff-package.md`、`docs/documentation-maintenance-guide.md`、`docs/documentation-verification-log.md` |
| 签收前最终审查表 | 进入 S1 前必须逐项确认产品范围、技术栈、Windows 优先、AI 分层、安全、合规、发布、S1 范围和变更控制 | `docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md` |
| 文档收束规则 | 后续优先修订已有文档，新增文档必须有独立决策、证据或验收价值 | `docs/documentation-maintenance-guide.md`、`docs/coding-start-signoff-package.md` |
| 受控发布通道 | 开发成果进入生产只能走 `build-prod.ps1`、`install.ps1`/`upgrade.ps1`、版本化迁移和健康检查 | `docs/product-constraints.md`、`docs/release-package-design.md`、`docs/s6-task-breakdown.md`、`docs/quality-gates.md` |
| P0 文件基础 | S2 只做本地单文件白名单上传、鉴权下载、图片预览、配额和两阶段删除；不引入对象存储或业务附件 | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/module-design.md`、`docs/s2-task-breakdown.md`、`docs/quality-gates.md` |
| 开源合规边界 | 第三方依赖、runtime 和工具必须记录来源、版本、许可证、NOTICE 和依赖 manifest | `docs/product-constraints.md`、`docs/windows-devkit-design.md`、`docs/release-package-design.md`、`docs/quality-gates.md` |
| 首个演示 | 客户拜访记录模块 | `docs/customer-visit-demo-spec.md`、`docs/s7-demo-acceptance.md` |
| 不做事项 | 多租户、工作流、报表、插件市场、微服务、复杂低代码设计器 | `docs/mvp-roadmap.md` |

## 4. 必须冻结的技术决策

| 项目 | 冻结内容 | 证据 |
| --- | --- | --- |
| 后端 | JDK 17、Spring Boot 3.5.16、Maven 3.8.x | `docs/adr/0001-mvp-tech-decisions.md` |
| ORM | MyBatis-Plus 3.5.16 | `docs/adr/0001-mvp-tech-decisions.md` |
| 数据库 | MySQL 8 | `docs/product-constraints.md`、`docs/database-baseline.md` |
| 缓存 | Redis | `docs/product-constraints.md` |
| 前端 | Vue 3.5.39、Vite 8.1.3、TypeScript 6.0.3、Element Plus 2.14.2 | `docs/adr/0001-mvp-tech-decisions.md` |
| Node | Node.js 20.19+ LTS + npm | `docs/adr/0001-mvp-tech-decisions.md` |
| 权限 | Sa-Token 1.45.0 | `docs/adr/0001-mvp-tech-decisions.md` |
| 迁移 | Flyway | `docs/adr/0001-mvp-tech-decisions.md` |
| API 文档 | Springdoc OpenAPI 2.8.17 | `docs/adr/0001-mvp-tech-decisions.md` |
| 模板 | Velocity 2.4.1 | `docs/adr/0001-mvp-tech-decisions.md` |
| Windows 服务 | WinSW | `docs/adr/0001-mvp-tech-decisions.md` |
| AI 协议 | OpenAI 兼容接口优先 | `docs/adr/0001-mvp-tech-decisions.md` |
| Lombok | P0 不引入，后端手写代码和生成代码均不得使用 Lombok 注解 | `docs/adr/0001-mvp-tech-decisions.md`、`docs/backend-implementation-spec.md` |
| API 并发与重复提交 | P0 使用数据库唯一约束、version 乐观锁、状态条件更新和事务内关系保存；普通 CRUD 不引入 Redis 锁或通用 Idempotency-Key | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/api-conventions.md`、`docs/backend-implementation-spec.md` |
| 请求追踪 | 后端生成 traceId，同步到统一响应体、`X-Trace-Id` 和 MDC；客户端不得覆盖 | `docs/api-conventions.md`、`docs/quality-gates.md` |
| 密码存储 | JDK 17 PBKDF2-HMAC-SHA256/600000 次、独立 salt；不新增密码库、不使用 Sa-Token 快速摘要 | `docs/security-governance.md`、`docs/backend-implementation-spec.md` |
| 浏览器会话 | Sa-Token + Redis 不透明 Token、HttpOnly Cookie、CSRF/Origin 校验；P0 不使用 JWT/Token Secret 或 Web Storage | `docs/security-governance.md`、`docs/frontend-admin-spec.md` |
| 网络暴露 | 生产 local 只回环，lan 强制 HTTPS；Actuator 固定回环管理端口 8081 | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/release-package-design.md` |

## 5. 必须冻结的 AI 使用边界

| 项目 | 冻结内容 | 证据 |
| --- | --- | --- |
| 外部 AI Coding 工具 | 开发实现和真实源码修改主路径 | `docs/adr/0003-ai-tool-usage-boundary.md` |
| 平台内 AI 工作台 | 需求澄清、计划、风险、元模型、受控生成、验证摘要 | `docs/ai-workbench-design.md` |
| AI 用户入口 | 维护者用外部 AI Coding 工具，企业用户用平台 AI 工作台，生产用户只用业务 AI | `docs/ai-tool-usage-guide.md` |
| AI 工具责任边界 | 企业用户确认业务，平台组织上下文和交接包，实施人员/开发者使用外部 AI Coding 工具，生产只保留业务 AI | `docs/ai-tool-usage-guide.md`、`docs/product-constraints.md` |
| AI 工具当前决策状态 | “如何使用 AI 工具”已固化为外部 AI Coding 工具、平台 AI 工作台、模型网关和生产业务 AI 分层，不再作为未定问题悬空 | `docs/ai-tooling-strategy.md`、`docs/ai-tool-usage-guide.md` |
| AI 工具使用模型 | 首版不替代 Codex、Cursor、Claude Code，而是适配并约束这些工具 | `docs/ai-tool-usage-guide.md` |
| AI 工具使用路径产品化 | 首次使用有引导，工作台能输出外部 AI 交接包，企业用户不必直接懂源码 | `docs/ai-tool-usage-guide.md`、`docs/product-constraints.md` |
| 企业用户不会 AI 工具时的托底路径 | 企业用户先用平台 AI 工作台，实施人员/开发者再使用外部 AI Coding 工具执行工程动作 | `docs/ai-tool-usage-guide.md`、`docs/product-constraints.md` |
| AI 使用准入卡 | 每次 AI 任务先确认编码许可、任务阶段、执行入口、上下文、风险、验证和生产边界 | `docs/ai-tool-usage-guide.md`、`docs/product-constraints.md` |
| S1 开工检查 | 签收和启动口令满足后，创建源码目录前仍必须输出 `signoffStatus`、`s1Allowed`、`launchPhraseExact`、`sourceDirsBefore`、`allowedScope`、`forbiddenScope` 和 `admissionCard.result` | `docs/s1-implementation-work-order.md`、`docs/external-ai-coding-prompt.md`、`docs/quality-gates.md` |
| S1 输出与关闭证据 | S1 输出摘要必须包含阶段关闭证据包；阶段关闭只申请关闭 S1，不自动授权 S2 | `docs/s1-implementation-work-order.md`、`docs/external-ai-coding-prompt.md`、`docs/quality-gates.md` |
| AI 能力成熟度 | A0-A2 是首版承诺，A3-A4 为 P1 增强，完整内置 Agent IDE 不做 | `docs/ai-tool-usage-guide.md` |
| 生产业务 AI | 只做业务问答、摘要、分类、文案、分析 | `docs/ai-tool-usage-guide.md` |
| 生产 AI 白名单 | 生产模型配置只允许业务问答、摘要、分类、文案、分析和连接测试 | `docs/security-governance.md`、`docs/release-package-design.md`、`docs/quality-gates.md` |
| 模型数据安全 | 模型调用前必须做数据分类、最小化、脱敏、数据权限过滤和出境风险提示 | `docs/security-governance.md`、`docs/model-gateway-spec.md`、`docs/quality-gates.md` |
| P0 不做完整 AI IDE | 不自研完整 Agent Runtime，不提供服务端任意 shell | `docs/adr/0003-ai-tool-usage-boundary.md` |
| 生产禁用代码修改 | 默认关闭代码生成、脚本执行、数据库结构修改 | `docs/security-governance.md` |
| C0 授权边界 | C0 只在阶段已签收、维护者发出阶段启动指令且请求完全落在阶段任务内时成立 | `docs/post-coding-change-control.md`、`docs/coding-start-signoff-package.md` |
| 开发工作区执行边界 | 补丁和文件写入只限开发工作区，由外部 AI Coding 工具或本地受控执行器承接，不进入生产服务端 | `docs/adr/0002-mvp-implementation-contracts.md`、`docs/adr/0003-ai-tool-usage-boundary.md`、`docs/ai-tooling-strategy.md` |
| 交接包生产边界 | 外部 AI 交接包不能作为生产补丁、SQL 或 shell 执行入口 | `docs/external-ai-coding-prompt.md`、`docs/s4-task-breakdown.md`、`docs/windows-devkit-design.md` |
| 交接包授权边界 | 外部 AI 交接包只是执行上下文，不能绕过签收状态、阶段启动口令、允许范围和质量门禁 | `docs/ai-tool-usage-guide.md`、`docs/adr/0003-ai-tool-usage-boundary.md` |
| 高风险确认 | L2/L3 风险必须显式确认，L3 建议备份 | `docs/skill-rule-design.md` |

## 6. 必须接受的交付取舍

| 取舍 | 接受内容 | 不接受则影响 |
| --- | --- | --- |
| Windows 优先 | 先把 Windows 开发和生产跑顺 | 不能开始开发包和安装包实现 |
| 技术栈克制 | 不为首版引入 Spring Cloud、MQ、ES、K8s | 需要重新审计架构和部署成本 |
| P0 单表 CRUD | 首个生成闭环只做客户拜访记录级别复杂度 | S4/S7 验收无法稳定 |
| P1 交付闭环 | 生产包和备份恢复在 MVP 完成前跑通，但不抢 S1/S2 顺序 | MVP 无法宣称可交付 |
| 通用导入导出延后 | Excel 导入导出、模板和错误回执属于 P2，不阻塞 S1-S7 | 需要重新审计生成范围和依赖 |
| 生产外部 MySQL/Redis | 生产默认连接外部服务，演示包可选内置 | 安装包复杂度需要重新设计 |
| 外部 AI 工具协作 | 首版不把平台做成完整 IDE | AI 工作台范围需要重写 |
| 质量门禁优先 | 编译、构建、脚本失败不能假装通过 | MVP 成功标准失效 |

## 7. 编码启动许可

进入编码只允许从 S1 工程骨架开始。

S1 工作令只能在签收后使用。未签收时，`docs/s1-implementation-work-order.md` 只能作为审阅和修订对象，不能作为创建 `backend/`、`frontend/`、`scripts/` 或 `config/` 的授权。

| 允许做 | 不允许做 |
| --- | --- |
| 创建 `backend/` Maven 多模块骨架 | 直接实现客户拜访记录 |
| 创建 `frontend/` Vue/Vite/Element Plus 骨架 | 直接做 AI 工作台完整页面 |
| 创建 `scripts/doctor.ps1`、`dev-start.ps1`、`dev-stop.ps1` 骨架 | 直接生成生产安装包 |
| 创建配置模板和 ignored local 配置示例 | 引入额外中间件 |
| 保证后端和前端能最小构建 | 一边写代码一边扩大 P0 范围 |

S1 的完成标准见 `docs/engineering-skeleton-spec.md` 和 `docs/s1-task-breakdown.md`。

## 8. 编码后变更流程

编码开始后仍然遵守文档优先。

| 变更类型 | 必须先更新 |
| --- | --- |
| 新增技术依赖 | `docs/adr/` 或 `docs/product-constraints.md` |
| 扩大 P0 范围 | `docs/mvp-roadmap.md` 和 `docs/implementation-readiness-audit.md` |
| 修改 AI 工具边界 | `docs/adr/0003-ai-tool-usage-boundary.md`、`docs/ai-tooling-strategy.md`、`docs/ai-tool-usage-guide.md` |
| 修改代码生成范围 | `docs/code-generation-design.md`、`docs/s4-task-breakdown.md` |
| 修改开发包策略 | `docs/windows-devkit-design.md`、`docs/s5-task-breakdown.md` |
| 修改生产包策略 | `docs/release-package-design.md`、`docs/s6-task-breakdown.md` |
| 修改演示路径 | `docs/customer-visit-demo-spec.md`、`docs/s7-demo-acceptance.md` |
| 新增或拆分文档 | `docs/documentation-maintenance-guide.md`、`docs/README.md`、相关准入审计 |
| 修改编码启动签收口径 | `docs/coding-start-signoff.md`、本文、`docs/implementation-readiness-audit.md` |
| 修改签收包承诺 | `docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md`、本文 |
| 修改编码后变更级别 | `docs/post-coding-change-control.md`、本文、`docs/implementation-readiness-audit.md` |

## 9. 冻结确认表

进入编码前，维护者应逐项确认。

| 确认项 | 期望结论 |
| --- | --- |
| 是否接受 P0 不再扩大 | 是 |
| 是否接受 P1 只补齐 MVP 交付闭环 | 是 |
| 是否接受 Windows 首版优先 | 是 |
| 是否接受最小技术栈 | 是 |
| 是否接受 P0 不自研完整 AI IDE | 是 |
| 是否接受外部 AI Coding 工具作为 P0 真实源码修改主路径 | 是 |
| 是否接受首版不替代 Codex、Cursor、Claude Code，而是围绕它们建立项目约束 | 是 |
| 是否接受平台 AI 工作台作为企业用户的产品化入口 | 是 |
| 是否接受 AI 工具责任边界，企业用户、实施人员/开发者、平台工作台、外部 AI Coding 工具和生产业务 AI 不相互越界 | 是 |
| 是否接受平台必须提供首次使用引导和外部 AI 交接包，而不是假设用户自己会用 AI 工具 | 是 |
| 是否接受“如何使用 AI 工具”已按外部 AI Coding 工具、平台 AI 工作台、模型网关和生产业务 AI 分层定稿 | 是 |
| 是否接受企业用户不会 AI Coding 工具时，默认由平台工作台托底、实施人员/开发者接力、外部 AI Coding 工具执行 | 是 |
| 是否接受每次 AI 任务必须先给出准入卡结论 | 是 |
| 是否接受签收后创建源码目录前仍必须先输出结构化 S1 开工检查 | 是 |
| 是否接受 S1 输出摘要必须包含阶段关闭证据包且不能自动授权 S2 | 是 |
| 是否接受企业用户不必懂源码，源码修改可由实施人员或开发者使用外部 AI 工具完成 | 是 |
| 是否接受生产禁用开发型 AI | 是 |
| 是否接受生产 AI 白名单，生产模型配置只允许业务问答、摘要、分类、文案、分析和连接测试 | 是 |
| 是否接受模型数据安全，企业业务数据进入模型前必须分类、最小化、脱敏、权限过滤和提示出境风险 | 是 |
| 是否接受开源合规边界，第三方依赖、runtime 和工具来源、版本、许可证清单必须进入验收 | 是 |
| 是否接受 C0 不绕过签收和阶段启动指令 | 是 |
| 是否接受补丁和文件写入只限开发工作区，生产不得在线执行 | 是 |
| 是否接受外部 AI 交接包不能作为生产执行入口 | 是 |
| 是否接受外部 AI 交接包不是编码授权书，不能绕过签收、启动口令、允许范围和质量门禁 | 是 |
| 是否接受生产发布只能走受控发布通道，不能复制源码、复制开发库、执行交接包或手工 SQL | 是 |
| 是否接受首个演示只做客户拜访记录 | 是 |
| 是否接受从 S1 工程骨架开始 | 是 |
| 是否接受 S1 工作令不等于开工许可，仍需签收记录和启动口令 | 是 |
| 是否接受“同意”“可以开始”“按文档做”等表达不构成等价签收 | 是 |
| 是否接受等价签收必须包含签收包接受、S1 范围、最终审查表全部确认、全部签收项、签收人、签收日期和签收基线 | 是 |
| 是否接受质量门禁失败不得宣称完成 | 是 |
| 是否接受文档维护必须同步索引、准入审计和冻结清单 | 是 |
| 是否接受后续优先修订已有文档，非必要不新增文档 | 是 |
| 是否接受编码后新增请求必须按 C0-C4 变更级别处理 | 是 |
| 是否复核编码前读者测试结果 | 是 |
| 是否确认原始产品要求已有文档证据 | 是 |
| 是否复核文档验证日志中的检查结果 | 是 |
| 是否确认签收仓库基线，且提交哈希或签收文档 manifest 清楚 | 是 |
| 是否执行签收前预检命令包并处理失败项 | 是 |
| 是否确认签收前最终审查表全部审查域 | 是 |
| 是否接受编码启动签收包中的全部承诺 | 是 |
| 是否已更新 `docs/coding-start-signoff.md` 为已签收 | 是 |

## 10. 签收要求

| 项目 | 要求 |
| --- | --- |
| 签收文件 | `docs/coding-start-signoff.md` |
| 签收基线 | 推荐使用已提交文档快照；如工作区未提交，必须在签收记录中明确 manifest 生成时间、`ManifestDocs` 数量、纳入范围和 SHA256 清单 |
| 未签收状态 | 不允许创建源码目录，只能继续修订 `docs/` |
| 已签收状态 | 只允许按 S1 工作令创建工程骨架 |
| S1 开工检查 | 已签收并收到精确口令后，仍需先输出结构化开工检查；任一关键项失败时不得编码 |
| 外部 AI 口令 | 维护者明确说精确口令 `开始 S1 工程骨架编码`，不得带句号、冒号或额外后缀 |

## 11. 不满足时的处理

| 情况 | 处理 |
| --- | --- |
| 某项冻结结论不接受 | 先修改对应文档或 ADR，不进入编码 |
| 需要新增能力 | 先判断 P0/P1/P2，再更新路线图 |
| 技术选型要替换 | 先新增或修订 ADR |
| S1 范围想扩大 | 先更新 `docs/s1-task-breakdown.md` 和准入审计 |
| 用户只想试验性编码 | 可新建实验分支，但不能宣称进入正式实现阶段 |

## 12. 一句话总结

这张清单的作用是把“可以开始编码”变成可验证的承诺：范围冻结、技术冻结、AI 边界冻结、S1 起步冻结；没有这些确认，继续写文档比开始写代码更便宜。
