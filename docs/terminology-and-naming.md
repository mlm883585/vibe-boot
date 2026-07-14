# Vibe Boot 术语、命名与状态规范

## 1. 文档目的

本文统一 Vibe Boot 编码前必须遵守的术语、模块名、目录名、状态值、权限标识、脚本命名和文档引用口径。

它不是功能规格，而是避免后续编码时出现“同一个概念多个名字”的约束文件。任何新增模块、状态、目录、权限或脚本名称，都必须先确认是否符合本文。

## 2. 产品术语

| 术语 | 标准含义 | 禁止混用 |
| --- | --- | --- |
| Vibe Boot | 本项目产品名和工程名 | 不写成 VibeBoot 平台、Vibe-Boot |
| 开发模式 | 可使用外部 AI Coding 工具和平台内 AI 工作台迭代代码的模式 | 不等同于生产调试模式 |
| 生产模式 | 运行构建产物的稳定模式，默认禁用开发型 AI | 不允许在线改源码 |
| 外部 AI Coding 工具 | Codex、Cursor、Claude Code、通义灵码等 IDE/Agent 工具 | 不称为平台内 Agent |
| 平台内 AI 工作台 | Vibe Boot 管理端内置的受控 AI 任务入口 | 不称为完整 IDE |
| 模型网关 | 统一模型配置、调用、用量、脱敏和审计能力 | 业务模块不得直接调用模型 SDK |
| Skills/规则 | 项目规则、提示词模板、风险约束和上下文文件 | 不等同于插件市场 |
| 真实代码生成 | 生成 Java、Vue、SQL、权限、文档等可维护文件 | 不称为低代码运行时 |
| AI 使用准入卡 | 每次 AI 任务进入实现前的结构化准入结论，标准字段名为 `admissionCard` | 不称为审批流、生产授权或普通提示词 |

## 3. 优先级术语

| 术语 | 标准含义 |
| --- | --- |
| P0 | 最小开发闭环，先实现，支撑 S1-S5 |
| P1 | MVP 完整交付闭环，必须在宣称 MVP 完成前实现，支撑 S6-S7 |
| P2 | MVP 后增强，不阻塞首个闭环 |
| S0 | 文档收敛 |
| S1 | 工程骨架 |
| S2 | 基础后台 |
| S3 | 模型网关 |
| S4 | 代码生成闭环 |
| S5 | Windows 开发包 |
| S6 | 生产安装包 |
| S7 | MVP 端到端演示 |

## 4. 后端模块命名

| 模块 | 标准职责 | 命名约束 |
| --- | --- | --- |
| `vibe-starter` | Spring Boot 启动入口、配置装配、静态资源托管 | 只有启动模块可依赖业务模块 |
| `vibe-common` | 基础实体、统一响应、异常、工具、校验、分页 | 不依赖 Web Controller、业务模块或 Mapper |
| `vibe-security` | 登录认证、Token、权限校验、数据权限扩展 | 业务模块不得散落 Sa-Token 原始调用 |
| `vibe-system` | 用户、角色、菜单、部门、字典、参数、日志 | 系统基础能力集中在此模块 |
| `vibe-ai` | 模型供应商、模型网关、AI 任务、用量统计 | 所有模型调用入口 |
| `vibe-skill` | skills、规则集、提示词模板、项目上下文 | 不执行代码修改 |
| `vibe-gen` | 元模型、模板渲染、代码生成、产物记录 | 不直接绕过权限和迁移规则 |
| `vibe-file` | 本地文件、上传下载、存储策略接口 | P0 提供本地文件基础能力，P2 再增强业务附件和导入导出 |

暂不新增 `vibe-job`、`vibe-workflow`、`vibe-report`、`vibe-message` 等模块。若新增，必须先更新 `docs/module-design.md` 和本文。

## 5. 顶层目录命名

| 目录 | 标准用途 | Git 策略 |
| --- | --- | --- |
| `backend/` | Java 后端 Maven 多模块工程 | 提交源码 |
| `frontend/` | Vue 3.5.39 + Vite 8.1.3 管理端工程 | 提交源码和锁文件 |
| `scripts/` | Windows PowerShell 开发、构建、安装、备份脚本 | 提交脚本 |
| `docs/` | 产品、架构、规格、ADR、任务分解文档 | 提交文档 |
| `config/` | 配置模板和本地配置示例 | 提交示例，不提交密钥 |
| `runtime/` | JDK/Maven/Node/Redis 等运行时 | 源码仓库不提交大型二进制 |
| `data/` | 用户数据、文件数据 | 不提交 |
| `logs/` | 脚本、后端、前端、安装、备份日志 | 不提交 |
| `package/` | 构建出的开发包或生产安装包 | 不提交 |
| `reference/` | 参考项目和外部资料 | 不提交，已忽略 |

## 6. 脚本命名

| 脚本 | 标准用途 | 阶段 |
| --- | --- | --- |
| `scripts/common.ps1` | 公共函数、路径、日志、错误处理 | S1/S5/S6 |
| `scripts/doctor.ps1` | 开发环境诊断 | S1/S5 |
| `scripts/dev-start.ps1` | 启动开发模式 | S1/S5 |
| `scripts/dev-stop.ps1` | 停止开发模式 | S1/S5 |
| `scripts/setup-model.ps1` | 配置模型向导 | S5 |
| `scripts/build-prod.ps1` | 构建生产安装包 | S6 |
| `scripts/install.ps1` | 安装生产服务 | S6 |
| `scripts/start.ps1` | 启动生产服务 | S6 |
| `scripts/stop.ps1` | 停止生产服务 | S6 |
| `scripts/status.ps1` | 查看生产服务和健康状态 | S6 |
| `scripts/backup.ps1` | 备份数据库、文件、配置、版本 | S6 |
| `scripts/restore.ps1` | 恢复测试备份 | S6 |
| `scripts/uninstall.ps1` | 卸载生产服务，默认保留数据 | S6 |

脚本必须使用 kebab-case，不新增 `.bat` 作为主入口。

## 7. AI 任务状态

AI 工作台任务状态统一使用以下值。

| 状态 | 含义 | 允许流转 |
| --- | --- | --- |
| `draft` | 用户刚创建任务或提交原始需求 | -> `clarifying` / `planned` / `cancelled` |
| `clarifying` | 正在澄清需求和默认假设 | -> `planned` / `failed` / `cancelled` |
| `planned` | 已生成变更计划、风险和验证建议 | -> `waiting_confirm` / `confirmed` / `cancelled` |
| `waiting_confirm` | 等待用户确认计划或风险 | -> `confirmed` / `cancelled` |
| `confirmed` | 用户已确认计划或风险 | -> `applying` / `completed` / `cancelled` |
| `applying` | 正在应用补丁或生成产物 | -> `verifying` / `failed` |
| `verifying` | 正在执行验证 | -> `completed` / `failed` |
| `completed` | 任务完成 | 终态 |
| `failed` | 任务失败 | 终态或人工重开新任务 |
| `cancelled` | 用户取消 | 终态 |
| `reverted` | 已回滚已应用变更 | 终态 |

禁止使用 `planning`、`success`、`done`、`error` 作为持久化状态。界面文案可以显示“规划中/已成功”，但数据库、API 和日志必须使用上述标准值。

### 7.1 文件对象状态

| 状态 | 含义 | 允许流转 |
| --- | --- | --- |
| `uploading` | 已创建元数据，正在写临时文件 | -> `active` / `failed` |
| `active` | 文件可按权限下载或预览 | -> `deleting` |
| `failed` | 上传、移动或元数据收尾失败，不可访问 | -> `deleting` |
| `deleting` | 已禁止访问，正在物理删除 | -> `deleted` / `delete_failed` |
| `delete_failed` | 物理删除失败，等待管理员重试 | -> `deleting` |
| `deleted` | 物理文件已删除，元数据逻辑删除 | 终态 |

文件状态使用小写 snake_case。不得使用 `ACTIVE`、`DELETE_FAILED`、`removed` 或 `error` 作为数据库/API 状态值。

## 8. 代码生成状态

代码生成任务可复用 AI 任务状态，但元模型状态应保持更小集合。

| 状态 | 含义 |
| --- | --- |
| `draft` | 元模型草案 |
| `planned` | 已生成计划 |
| `confirmed` | 用户已确认元模型 |
| `generated` | 产物已生成或预览 |
| `verified` | 验证通过 |
| `failed` | 生成或验证失败 |

代码生成结果未验证通过前，不得标记业务任务 `completed`。

## 9. 验证结果状态

验证结果统一使用：

| 状态 | 含义 |
| --- | --- |
| `passed` | 已执行且通过 |
| `failed` | 已执行且失败 |
| `skipped` | 未执行，必须说明原因 |
| `warn` | 存在警告但不阻断当前阶段 |

验证结果状态不得与 AI 任务状态混用。

## 9.1 AI 使用准入卡命名

AI 使用准入卡用于外部 AI 交接包、AI 工作台任务详情和 AI 工具输出摘要。数据库、API、前端和 JSON 快照统一使用 `admissionCard` 字段名。

| 字段 | 含义 |
| --- | --- |
| `codingAllowed` | 当前签收和阶段启动是否允许编码 |
| `taskStage` | 当前任务所属阶段，例如 S1、S4、S7 |
| `executionEntry` | 执行入口，例如 external-ai、workbench、production-business-ai |
| `contextReady` | 上下文是否已包含 README、产品约束、ADR、阶段任务和质量门禁 |
| `riskConfirmed` | 风险是否已标注并在需要时确认 |
| `verificationReady` | 验证命令或免测原因是否明确 |
| `productionBoundarySafe` | 是否不包含生产在线改源码、任意 shell、直接改表或执行交接包 |
| `result` | `pass` 或 `fail` |

准入卡不是新的状态机。它是进入实现前的结构化检查结果，不得替代 `docs/coding-start-signoff.md` 的签收状态，也不得把 `fail` 解释为可以带风险继续编码。

## 10. 权限标识命名

权限标识统一使用：

```text
{domain}:{resource}:{action}
```

| 片段 | 示例 | 规则 |
| --- | --- | --- |
| domain | `system`、`ai`、`biz` | 小写 |
| resource | `user`、`role`、`customerVisit` | lowerCamelCase |
| action | `list`、`query`、`create`、`resetPassword`、`assignRoles` | 简单动作使用小写动词，复合动作使用 lowerCamelCase |

示例：

| 权限 | 含义 |
| --- | --- |
| `system:user:list` | 用户列表 |
| `ai:modelConfig:update` | 修改模型配置 |
| `biz:customerVisit:create` | 新增客户拜访记录 |

## 11. API 命名

| 类型 | 规则 | 示例 |
| --- | --- | --- |
| 后端路径 | `/api/{domain}/{resources}` | `/api/biz/customer-visits` |
| 分页路径 | `/api/{domain}/{resources}/page` | `/api/system/users/page` |
| 详情路径 | `/api/{domain}/{resources}/{id}` | `/api/biz/customer-visits/1001` |
| 前端 API 文件 | `frontend/src/api/{domain}/{resource}.ts` | `frontend/src/api/biz/customerVisit.ts` |
| Java 包名 | `com.vibeboot.{module}.{resource}` | `com.vibeboot.biz.customervisit` |

API、错误码、分页和响应体以 `docs/api-conventions.md` 为准，本文只做命名入口。

## 12. 数据库命名

| 类型 | 规则 | 示例 |
| --- | --- | --- |
| 表名 | `{domain}_{resource}`，snake_case | `biz_customer_visit` |
| 字段名 | snake_case | `customer_name` |
| 主键 | `id` | 雪花 ID |
| 逻辑删除 | `deleted` | Boolean/TinyInt |
| 时间字段 | `created_at`、`updated_at` | DateTime |
| 操作人字段 | `created_by`、`updated_by` | Long |

数据库基线以 `docs/database-baseline.md` 为准。

## 13. 文档引用命名

| 类型 | 规则 |
| --- | --- |
| 文档路径 | 使用 `docs/product-constraints.md` 这类真实路径 |
| ADR | 使用 `docs/adr/0001-mvp-tech-decisions.md` 这类真实路径 |
| 阶段任务 | 使用 `docs/s1-task-breakdown.md` 这类真实路径 |
| 总纲 | 使用 `vibe-boot-architecture.md` |
| 冻结清单 | 使用 `coding-freeze-checklist.md` |

文档中引用文件名时保持反引号包裹，避免中英文混排时歧义。

## 14. 编码准入

进入编码前必须确认：

| 准入项 | 状态 |
| --- | --- |
| 模块名 | 已由本文和 `docs/module-design.md` 确认 |
| 顶层目录 | 已由本文和 `docs/engineering-skeleton-spec.md` 确认 |
| 脚本名 | 已由本文、S5/S6 文档确认 |
| AI 任务状态 | 已由本文和 ADR-0002 统一 |
| 权限标识 | 已由本文和 `docs/api-conventions.md` 确认 |
| API/数据库命名 | 已由本文、API 规范和数据库基线确认 |

## 15. 一句话总结

Vibe Boot 的编码起点必须先统一语言：模块怎么叫、目录怎么放、状态怎么流转、权限怎么命名、脚本怎么执行。术语统一了，AI 和人类才不会在同一个项目里写出两套系统。
