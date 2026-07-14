# Vibe Boot MVP 路线与实现准入

## 1. 文档目的

本文定义 Vibe Boot 从文档阶段进入编码实现前的 MVP 范围、阶段路线、任务拆分、验收标准和决策收敛状态。

本文遵守“文档优先”原则：未完成编码准入前，不进入工程骨架编码。

## 2. MVP 定义

Vibe Boot MVP 不是完整低代码平台，也不是功能丰富的 Admin 系统。MVP 只验证一个核心闭环：

> Windows 开发包启动后，用户配置大模型，通过 AI 工作台生成一个简单业务 CRUD 模块，系统能自动验证，并生成可安装的 Windows 生产包。

## 3. MVP 成功标准

| 标准 | 说明 |
| --- | --- |
| Windows 可启动 | 解压开发包后可运行 doctor 和 dev-start |
| 大模型可接入 | 至少支持 OpenAI 兼容模型配置 |
| 基础后台可用 | 登录、用户、角色、菜单、字典、日志 |
| AI 工作台可用 | 可需求澄清、生成计划、展示风险、应用变更 |
| CRUD 可生成 | 生成后端、前端、SQL、菜单权限 |
| 质量可验证 | 后端编译、前端构建至少可运行 |
| 生产可打包 | 生成 Windows 安装包 |
| 生产可安装 | install 可启动系统并健康检查 |

## 4. P0/P1/P2 范围

本文中的 P0/P1/P2 表示“实现优先级”，不等同于“是否属于 MVP”。

| 口径 | 含义 |
| --- | --- |
| P0 | 最小开发闭环，必须先实现，支撑 S1-S5 |
| P1 | MVP 完整交付闭环，必须在宣称 MVP 完成前实现，支撑 S6-S7 |
| P2 | MVP 后增强，不阻塞首个闭环验收 |

因此，生产安装包、备份恢复等能力虽然列为 P1，但仍属于 MVP 完成前必须跑通的交付能力；它们不是 S1 开工前要编码的内容，也不是可以无限期延后的“后续版本”。

### 4.1 P0 必做

| 模块 | 能力 |
| --- | --- |
| 文档体系 | 架构、约束、模块、AI、规则、生成、Windows、安全、路线 |
| 工程骨架 | Maven 多模块、Vue 前端、基础配置 |
| 基础后台 | 登录、用户、角色、菜单、字典、操作日志 |
| 文件基础 | 本地单文件上传、鉴权下载、图片预览、元数据、配额和两阶段删除 |
| 模型网关 | OpenAI 兼容模型配置、调用、用量记录 |
| AI 工作台 | 需求输入、上下文摘要、计划、风险、摘要 |
| AI 使用路径 | 首次使用引导、外部 AI 交接包、企业用户路径、能力成熟度分层 |
| 代码生成 | 单表 CRUD 生成 |
| Windows 开发包 | doctor、dev-start、dev-stop、国内镜像 |
| 最小验证 | 后端构建、前端构建、doctor/dev-start 可执行 |

### 4.2 P1 必做

| 模块 | 能力 |
| --- | --- |
| 测试门禁 | 后端测试、前端构建、生成后验证 |
| 生产安装包 | build-prod、install、start、stop、status |
| 备份恢复 | backup、restore |
| 数据库迁移 | Flyway 或确认后的迁移方案 |
| 安全治理 | 密钥脱敏、AI 审计、生产禁用代码编辑 |
| CRUD 增强 | 详情页、字典字段 |

文件基础不等同于业务附件或导入导出。P0 `vibe-file` 在 S2 完成本地存储基础能力；业务附件绑定、Office/音视频/压缩包、在线文档预览、分片上传、MinIO/OSS 和 CDN 不属于 S1-S7 必做范围。

### 4.3 P2 延后

| 模块 | 能力 |
| --- | --- |
| 工作流 | 审批、状态机 |
| 报表 | 图表、仪表盘、查询设计 |
| 第三方集成 | Webhook、ERP/CRM/企业微信/钉钉 |
| 多租户 | SaaS 化 |
| Docker/Linux | 跨平台部署 |
| 插件市场 | skill/template 生态 |
| 通用导入导出 | Excel 导入导出、导入模板和错误回执 |

P2 不得作为 S1-S7 的阻塞项。任何把 P2 提前为 P0/P1 的变更，必须先更新本文、`docs/coding-freeze-checklist.md` 和 `docs/implementation-readiness-audit.md`。

## 5. 阶段路线

| 阶段 | 名称 | 目标 | 交付 |
| --- | --- | --- | --- |
| S0 | 文档收敛 | 完成编码前约束和关键决策 | docs 完整、决策项收敛 |
| S1 | 工程骨架 | 搭建最小可启动项目 | backend/frontend/scripts 初版 |
| S2 | 基础后台 | 完成企业应用基础盘 | 登录、权限、菜单、字典、日志 |
| S3 | AI 接入 | 完成模型网关和 AI 工作台基本流程 | 模型配置、对话、任务 |
| S4 | 生成闭环 | 完成单表 CRUD 生成和验证 | Java/Vue/SQL/权限 |
| S5 | Windows 开发包 | 开发模式一键启动 | doctor/dev-start/dev-stop |
| S6 | 生产包 | 生成并安装生产系统 | build-prod/install/backup |
| S7 | MVP 演示 | 打通端到端演示 | 客户拜访记录模块演示 |

## 6. S0 文档收敛清单

| 文档 | 状态要求 |
| --- | --- |
| `vibe-boot-architecture.md` | 总纲完整 |
| `product-constraints.md` | 产品约束和编码准入完整 |
| `competitive-analysis.md` | 竞品定位完整 |
| `adr/0003-ai-tool-usage-boundary.md` | AI 工具使用边界决策完整，分层定稿状态明确 |
| `module-design.md` | 模块和依赖边界完整 |
| `terminology-and-naming.md` | 术语、命名、状态和目录规范完整 |
| `frontend-admin-spec.md` | Vue 管理端页面、路由、权限和生成规范完整 |
| `ai-tooling-strategy.md` | 外部 AI coding 工具、平台内 AI 工作台、模型网关分工完整 |
| `ai-tool-usage-guide.md` | 开发者、企业用户和生产模式的 AI 工具使用路径完整 |
| `ai-tool-usage-guide.md` 的使用路径产品化 | 首次使用引导、外部 AI 交接包、企业用户不必懂源码和能力成熟度分层完整 |
| `external-ai-coding-prompt.md` | 外部 AI Coding 工具提示词完整 |
| `model-gateway-spec.md` | S3 模型网关施工规格完整 |
| `s3-task-breakdown.md` | S3 模型网关任务分解完整 |
| `ai-workbench-design.md` | AI 工作台流程完整 |
| `ai-workbench-task-breakdown.md` | AI 工作台基础任务分解完整 |
| `skill-rule-design.md` | Skills 和规则完整 |
| `code-generation-design.md` | 生成元模型和流程完整 |
| `s4-task-breakdown.md` | S4 代码生成闭环任务分解完整 |
| `quality-gates.md` | 质量门禁、验证命令和失败处理完整 |
| `windows-devkit-design.md` | Windows 开发包完整 |
| `s5-task-breakdown.md` | S5 Windows 开发包任务分解完整 |
| `release-package-design.md` | 生产安装包完整 |
| `s6-task-breakdown.md` | S6 生产安装包任务分解完整 |
| `security-governance.md` | 安全治理完整 |
| `mvp-roadmap.md` | MVP 路线完整 |
| `implementation-readiness-audit.md` | 编码实现准入审计完整 |
| `coding-freeze-checklist.md` | 编码前冻结确认清单完整 |
| `documentation-readiness-review.md` | 编码前文档就绪审计报告完整 |
| `s1-implementation-work-order.md` | S1 工程骨架实施工作令完整 |
| `engineering-skeleton-spec.md` | S1 工程骨架施工规格完整 |
| `s1-task-breakdown.md` | S1 工程骨架任务分解完整 |
| `basic-admin-spec.md` | S2 基础后台施工规格完整 |
| `s2-task-breakdown.md` | S2 基础后台任务分解完整 |
| `customer-visit-demo-spec.md` | MVP 客户拜访记录演示规格完整 |
| `s7-demo-acceptance.md` | S7 MVP 端到端演示验收剧本完整 |

## 7. 编码前必须决策

| 决策 | 当前建议 | 状态 |
| --- | --- | --- |
| UI 组件库 | Element Plus | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| Spring Boot 基线 | Spring Boot 3.5.16，P0 只允许 3.5.x patch 线 | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| 权限框架 | Sa-Token 1.45.0 | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| 数据库迁移 | Flyway | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| Node 版本 | Node.js 20.19+ LTS | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| 前端版本基线 | Vue 3.5.39、Vite 8.1.3、TypeScript 6.0.3、Element Plus 2.14.2 | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| 包管理器 | npm | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| Windows 服务 | WinSW | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| Redis 策略 | 开发可选内置，生产外部连接 | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| ID 策略 | 雪花 ID | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| 后端外部依赖基线 | MyBatis-Plus 3.5.16、Springdoc OpenAPI 2.8.17、Velocity 2.4.1 | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| 模板引擎 | Velocity 2.4.1 | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| 测试数据库 | P0 本地 MySQL，P1 Testcontainers | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| Lombok | P0 不引入，后端和生成模板不使用 Lombok 注解 | 已确认，见 `docs/adr/0001-mvp-tech-decisions.md` |
| AI 工具边界 | 三层 AI 工具模式，P0 不自研完整 AI IDE | 已确认，见 `docs/adr/0003-ai-tool-usage-boundary.md` |
| AI 工具分层定稿状态 | 外部 AI Coding 工具 + 平台 AI 工作台 + 模型网关 + 生产业务 AI 已定稿，不再作为未定问题悬空；实现仍需人工签收 | 已确认，见 `docs/adr/0003-ai-tool-usage-boundary.md`、`docs/product-constraints.md`、`docs/coding-start-signoff.md` |
| AI 使用路径产品化 | 首次使用有引导，工作台能输出外部 AI 交接包，企业用户不必懂源码 | 已确认，见 `docs/ai-tool-usage-guide.md` |

## 8. 第一条端到端演示

MVP 演示使用“客户拜访记录”模块，业务规格见 `docs/customer-visit-demo-spec.md`，端到端验收剧本见 `docs/s7-demo-acceptance.md`。

| 步骤 | 演示内容 |
| --- | --- |
| 1 | 解压 Windows 开发包 |
| 2 | 执行 `scripts/doctor.ps1` |
| 3 | 执行 `scripts/dev-start.ps1` |
| 4 | 配置大模型 API Key |
| 5 | 登录管理端 |
| 6 | 打开 AI 工作台 |
| 7 | 输入“帮我做客户拜访记录模块” |
| 8 | AI 澄清字段和权限 |
| 9 | AI 生成计划和风险说明 |
| 10 | 用户确认 |
| 11 | 生成后端、前端、SQL、菜单权限 |
| 12 | 自动编译/构建验证 |
| 13 | 本地预览新增模块 |
| 14 | 执行 `build-prod.ps1` |
| 15 | 在另一台 Windows 机器执行 `install.ps1` |

## 9. 客户拜访记录模块 MVP 字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| customerName | string | 客户名称 |
| contactName | string | 联系人 |
| visitTime | datetime | 拜访时间 |
| visitType | enum | 电话、上门、线上会议 |
| summary | text | 拜访纪要 |
| nextAction | string | 下一步动作 |
| ownerUserId | ref | 负责人 |
| status | enum | 草稿、已完成、已取消 |

该模块足够简单，但能覆盖实体、字段、枚举、列表、表单、权限、SQL 和菜单。

## 10. 质量门禁

详细质量门禁、验证命令和失败处理见 `docs/quality-gates.md`。本节只保留阶段摘要。

| 阶段 | 门禁 |
| --- | --- |
| S1 工程骨架 | 后端启动、前端启动 |
| 前端管理端 | 布局、登录、菜单、权限按钮模式符合 `docs/frontend-admin-spec.md` |
| S2 基础后台 | 登录和权限可用 |
| S3 AI 接入 | 模型调用成功，用量记录 |
| S4 生成闭环 | 生成代码后编译/构建成功 |
| S5 开发包 | doctor/dev-start/dev-stop 可用 |
| S6 生产包 | install/start/stop/backup 可用 |
| S7 演示 | 客户拜访记录端到端通过 |

## 11. 里程碑验收

| 里程碑 | 验收方式 |
| --- | --- |
| 文档阶段完成 | 所有 S0 文档存在，决策项已列明并收敛 |
| 工程骨架完成 | 按 `docs/engineering-skeleton-spec.md` 和 `docs/s1-task-breakdown.md` 完成本地启动 |
| 基础后台完成 | 按 `docs/basic-admin-spec.md` 和 `docs/s2-task-breakdown.md` 完成登录、权限、菜单、字典、日志闭环 |
| AI 接入完成 | 按 `docs/model-gateway-spec.md` 和 `docs/s3-task-breakdown.md` 完成模型配置、连接测试和用量记录 |
| AI 工作台完成 | 按 `docs/ai-workbench-design.md` 和 `docs/ai-workbench-task-breakdown.md` 创建 AI 任务并生成计划 |
| 代码生成完成 | 按 `docs/code-generation-design.md`、`docs/s4-task-breakdown.md` 和 `docs/customer-visit-demo-spec.md` 生成客户拜访记录模块 |
| 开发包完成 | 按 `docs/windows-devkit-design.md` 和 `docs/s5-task-breakdown.md` 完成新环境解压、诊断、启动、停止和模型配置 |
| 生产包完成 | 按 `docs/release-package-design.md` 和 `docs/s6-task-breakdown.md` 在新 Windows 机器可安装、启停、备份和恢复 |
| MVP 演示完成 | 按 `docs/customer-visit-demo-spec.md` 和 `docs/s7-demo-acceptance.md` 完成端到端演示 |

每个里程碑关闭时，必须形成阶段关闭证据包，至少包含交付物清单、验证结果、越界检查、文档同步状态、残余风险和下一阶段请求。阶段关闭证据包只证明当前阶段可申请关闭，不自动授权下一阶段。

## 12. 风险与应对

| 风险 | 应对 |
| --- | --- |
| 技术栈膨胀 | 任何新增依赖先改文档 |
| AI 生成不稳定 | 强化元模型、模板和验证门禁 |
| Windows 脚本脆弱 | doctor 优先，错误中文化 |
| 生产安装复杂 | 首版减少依赖，不强制 Docker/Nginx |
| 安全边界模糊 | 生产禁用代码编辑，L2/L3 确认 |
| AI 工具边界模糊 | 按 `docs/ai-tooling-strategy.md` 区分外部 coding 工具和平台内工作台 |
| 用户不知道如何使用 AI 工具 | 按 `docs/ai-tool-usage-guide.md` 固化首次使用引导、外部 AI 交接包、企业用户路径和生产限制 |
| 项目像 RuoYi 换皮 | 强化 AI 工作台、开发包、安装包闭环 |

## 13. 实现准入结论

进入编码前，至少应完成：

| 项目 | 要求 |
| --- | --- |
| S0 文档 | 全部存在 |
| 实现准入审计 | 按 `docs/implementation-readiness-audit.md` 完成人工确认 |
| 冻结确认清单 | 按 `docs/coding-freeze-checklist.md` 确认范围、技术栈、AI 边界和 S1 起步 |
| AI 使用路径 | 确认 AI 工具分层定稿状态、首次使用引导、外部 AI 交接包、企业用户不必懂源码和能力成熟度分层 |
| 文档就绪审计 | 按 `docs/documentation-readiness-review.md` 复核文档完整性和 S1 开工边界 |
| S1 工作令 | 签收并获得精确启动口令 `开始 S1 工程骨架编码` 后，按 `docs/s1-implementation-work-order.md` 启动第一轮编码 |
| 关键技术决策 | UI、权限、迁移、Node、服务工具已由 ADR-0001 确认 |
| MVP 演示路径 | 客户拜访记录模块和 S7 端到端验收剧本确认 |
| P0/P1 范围 | P0 先实现最小开发闭环，P1 补齐 MVP 交付闭环，均不再扩大 |
| 不做事项 | 团队明确接受 |

## 14. 一句话总结

Vibe Boot MVP 只验证一个足够锋利的闭环：Windows 一键开发、AI 生成真实 CRUD、自动验证、生产一键安装。这个闭环跑通前，不扩展复杂平台能力。
