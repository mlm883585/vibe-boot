# Vibe Boot Skills 与规则设计草案

## 1. 文档目的

本文定义 Vibe Boot 中 skills、规则集、项目约束和 AI 执行边界的设计。它用于确保 AI coding 不是自由发挥，而是在产品定位、技术栈、模块边界、安全策略和质量门禁内工作。

Vibe Boot 的 skills 不是简单提示词集合，而是项目知识、工程规范、业务规则、安全禁令和验证要求的组合。

## 2. 核心定义

| 概念 | 定义 |
| --- | --- |
| Skill | 面向某类任务的结构化能力说明，例如 Java 后端、Vue 前端、测试、文档、代码生成 |
| Rule | 明确可检查的约束，例如禁止直接拼接 SQL、接口必须声明权限 |
| Constraint | 产品级或工程级边界，例如 Windows 优先、最小技术栈、文档优先 |
| Context | AI 执行任务时必须读取的文档、代码、元模型和历史记录 |
| Gate | 任务进入下一阶段前必须通过的检查，例如用户确认、编译、测试 |
| Policy | 多条规则和门禁的组合，例如“高风险变更策略” |

一句话：

> Skill 告诉 AI 怎么做，Rule 告诉 AI 什么不能做，Gate 决定 AI 什么时候可以继续做。

## 3. Skill 类型

| 类型 | 示例 | P0/P1 | 用途 |
| --- | --- | --- | --- |
| 产品 Skill | Vibe Boot 定位、用户、竞品差异 | P0 | 防止偏离产品方向 |
| 文档 Skill | 架构文档、约束文档、ADR 规范 | P0 | 支持文档优先 |
| Java Skill | Spring Boot、MyBatis-Plus、模块边界 | P0 | 指导后端代码 |
| 前端 Skill | Vue3、Vite、TypeScript、UI 组件库 | P0 | 指导前端页面 |
| 数据库 Skill | MySQL8、表命名、迁移脚本 | P0 | 指导表结构和 SQL |
| 安全 Skill | RBAC、数据权限、密钥脱敏、日志审计 | P0 | 降低安全风险 |
| 测试 Skill | JUnit5、MockMvc、构建验证、测试门禁 | P1 | 支持质量闭环 |
| Windows Skill | PowerShell、开发包、安装包、国内镜像 | P0 | 支持 Windows 首版体验 |
| 业务 Skill | 客户、订单、库存、审批等行业术语 | P2 | 支持行业模板 |

## 4. Skill 存储模型

首版可以先用文件存储 skills，后续再同步到数据库。

```text
skills/
├── product/
│   └── vibe-boot-positioning.md
├── engineering/
│   ├── java-spring-boot.md
│   ├── vue-frontend.md
│   ├── mysql-schema.md
│   └── windows-devkit.md
├── security/
│   └── security-baseline.md
├── testing/
│   └── spring-boot-testing.md
└── business/
    └── README.md
```

数据库表可后续使用：

| 表 | 用途 |
| --- | --- |
| `skill_definition` | skill 基本信息、版本、类型、启用状态 |
| `skill_rule` | 规则定义 |
| `skill_context` | skill 关联的文档、文件、元模型 |
| `skill_version` | skill 版本记录 |
| `skill_execution_log` | skill 被任务使用的记录 |

## 5. Skill 文件格式

建议使用 Markdown + YAML Front Matter，便于人读、AI 读、Git 管理。

```markdown
---
id: java-spring-boot
name: Java Spring Boot 工程规范
type: engineering
version: 0.1.0
priority: 100
status: active
severity: must
owner: core
effectiveFrom: 2026-06-30
appliesTo:
  - backend
  - code-generation
sourceRefs:
  - docs/product-constraints.md
  - docs/module-design.md
---

# 目标

说明该 skill 适用的任务。

# 必须遵守

- ...

# 禁止事项

- ...

# 验证方式

- ...
```

字段约束：

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `id` | 是 | 全局唯一 |
| `name` | 是 | 中文名称 |
| `type` | 是 | product/engineering/security/testing/business |
| `version` | 是 | 语义化版本 |
| `priority` | 是 | 规则冲突时优先级 |
| `status` | 是 | active/draft/deprecated |
| `severity` | 是 | must/should/must-not/ask-first/verify/document |
| `owner` | 是 | 规则责任域，例如 core/security/backend/frontend |
| `effectiveFrom` | 是 | 生效日期，便于追溯 |
| `appliesTo` | 是 | 适用任务 |
| `sourceRefs` | 是 | 规则来源文档，必须能追溯到产品约束、ADR 或阶段文档 |

P0 不要求把所有字段都做成复杂后台配置，但文件、数据库和审计记录中必须保留同等语义。AI 不能通过临时提示词降低 `severity`、删除 `sourceRefs` 或绕过 `status`。

## 6. 规则分类

| 分类 | 示例 | 处理方式 |
| --- | --- | --- |
| Must | 新接口必须有权限标识 | 不满足则阻断 |
| Should | 新业务模块应补充模块说明 | 不满足则警告 |
| Must Not | 禁止提交 API Key | 不满足则阻断 |
| Ask First | 删除数据前必须确认 | 等待用户确认 |
| Verify | 后端修改后必须编译 | 执行验证 |
| Document | 技术栈变化先更新文档 | 要求文档变更 |

规则表达建议：

```yaml
id: security.require-permission
level: must
scope: backend.controller
description: 除公开接口外，Controller 接口必须声明权限标识。
check:
  type: static
  pattern: "@RequiresPermission|@SaCheckPermission|@PreAuthorize"
onFail: block
```

## 7. P0 规则集

### 7.1 产品方向规则

| 规则 | 等级 | 说明 |
| --- | --- | --- |
| 文档优先 | Must | 编码前未明确的范围变化先修订文档 |
| 真实代码优先 | Must | 不生成只能由平台运行时解释的业务配置 |
| Windows 首版 | Must | 首版所有开发/交付设计优先服务 Windows |
| 技术栈最小化 | Must | 新增技术依赖前必须修订约束文档 |
| 中小企业优先 | Should | 不为大型企业复杂场景牺牲首版简洁性 |

### 7.2 后端工程规则

| 规则 | 等级 | 说明 |
| --- | --- | --- |
| Controller 不直接访问 Mapper | Must | 必须通过 Service |
| Entity 不直接暴露前端 | Should | 入参 DTO、出参 VO |
| 模块禁止循环依赖 | Must | Maven 模块单向依赖 |
| 新接口必须统一响应 | Must | 使用 `Result<T>` |
| 分页必须统一结构 | Must | 使用 `PageResult<T>` |
| 跨模块访问走服务接口 | Should | 不直接访问对方 Mapper |

### 7.3 数据库规则

| 规则 | 等级 | 说明 |
| --- | --- | --- |
| 首版只支持 MySQL8 | Must | 不做多数据库适配 |
| 表字段使用 snake_case | Must | 保持命名统一 |
| 必须有审计字段 | Should | created/updated 信息 |
| 禁止直接拼接 SQL | Must Not | 防止注入 |
| 高风险 SQL 必须确认 | Ask First | DROP/DELETE/批量更新 |
| 数据库变更版本化 | Must | 不散落 SQL |

### 7.4 安全规则

| 规则 | 等级 | 说明 |
| --- | --- | --- |
| API Key 不入库明文 | Must | 加密或本地安全配置 |
| 密钥不提交 Git | Must Not | `.env`、local 配置必须忽略 |
| 新接口必须鉴权 | Must | 公开接口需明确标记 |
| 删除/导出记录操作日志 | Should | 支持审计 |
| 生产禁用代码编辑 | Must | 防止在线改源码 |
| 敏感信息发模型前脱敏 | Must | 防止泄漏 |

### 7.5 前端规则

| 规则 | 等级 | 说明 |
| --- | --- | --- |
| UI 库固定 | Must | 首版固定 Element Plus，不允许引入第二套 UI |
| API 按模块组织 | Must | `src/api/<module>` |
| 页面按模块组织 | Must | `src/views/<module>` |
| 权限按钮同源 | Should | 与后端权限标识一致 |
| 工作台状态明确 | Must | AI 任务必须展示状态 |
| 中文优先 | Must | 首版面向中国用户 |

### 7.6 Windows 与交付规则

| 规则 | 等级 | 说明 |
| --- | --- | --- |
| 脚本必须中文输出 | Must | 面向目标用户 |
| 失败必须给建议 | Must | 不只输出异常堆栈 |
| 安装脚本尽量幂等 | Should | 重复执行可诊断 |
| 数据删除前确认 | Must | 防止误操作 |
| 生产包不包含源码编辑入口 | Must | 开发/生产隔离 |

## 8. 规则冲突处理

当多个 skill 或规则冲突时，按以下优先级处理：

| 优先级 | 来源 |
| --- | --- |
| 1 | 用户当前明确指令，但不能违反安全底线 |
| 2 | 安全规则 |
| 3 | 产品约束 |
| 4 | 模块设计 |
| 5 | 技术栈规则 |
| 6 | 业务 skill |
| 7 | 风格建议 |

安全底线不可被普通用户指令覆盖，例如提交密钥、删除数据、绕过权限。

冲突处理必须产出可审计结论，不能只在模型上下文中口头判断。

| 冲突结果 | 适用场景 | 必须动作 |
| --- | --- | --- |
| block | 违反安全、生产边界、未授权编码、强制技术栈等底线 | 阻断任务，记录 `blockedRules` 和中文原因 |
| ask_first | 涉及 L2/L3 风险、规则语义不明确或用户意图与文档冲突 | 进入 `waiting_confirm`，保存确认问题 |
| warn | 不违反强制规则，但偏离建议或存在可接受风险 | 继续任务，记录 `warnings` |
| verify | 可继续但必须补验证，例如构建、测试、脚本 dry-run | 生成验证计划并在完成摘要中回填结果 |
| document | 需要先补文档或 ADR | 不进入编码执行，仅允许文档修订 |

禁止把质量门禁通过解释为规则冲突自动解决。构建、测试或页面预览只能证明结果可运行，不能把 C2-C4、未签收任务或生产高风险动作降级为 C0。

## 9. 任务加载策略

不同任务加载不同 skill，避免上下文过大。

| 任务 | 必须加载 |
| --- | --- |
| 文档修订 | 产品 Skill、文档 Skill、竞品分析 |
| 后端 CRUD | Java Skill、数据库 Skill、安全 Skill、测试 Skill |
| 前端页面 | 前端 Skill、安全 Skill |
| AI 工作台 | 产品 Skill、AI Skill、安全 Skill、模块设计 |
| Windows 脚本 | Windows Skill、交付规则、安全 Skill |
| 生产打包 | Windows Skill、发布规则、安全 Skill |

加载结果必须在 AI 工作台中显示为上下文摘要。

加载结果还必须形成规则快照，确保同一个任务后续可复现。

| 快照字段 | 说明 |
| --- | --- |
| `skillSnapshot` | skill id、name、version、status、priority、checksum |
| `ruleSnapshot` | rule id、level/severity、priority、onFail、sourceRefs、checksum |
| `contextSnapshot` | 使用的文档、阶段任务、ADR、质量门禁和读取时间 |
| `resolutionTrace` | 规则冲突、优先级裁决、风险等级和最终动作 |
| `blockedRules` | 造成阻断的规则列表 |
| `warnings` | 放行但需要提示的规则列表 |

快照只能追加到任务审计记录，不得在任务执行后被静默覆盖。规则文件发生变化后，新任务使用新快照，历史任务仍按当时快照解释。

## 10. 风险确认策略

| 触发项 | 风险等级 | 必须动作 |
| --- | --- | --- |
| 修改登录认证 | L3 | 二次确认 |
| 修改权限校验 | L3 | 二次确认 |
| 删除数据或字段 | L3 | 二次确认 + 备份建议 |
| 引入新依赖 | L2 | 说明原因、替代方案、文档更新 |
| 修改安装脚本 | L2 | 说明影响范围 |
| 修改生产配置 | L2 | 用户确认 |
| 新增普通 CRUD | L1 | 展示计划和验证结果 |
| 修改文档 | L0 | 可直接应用并摘要 |

## 11. 检查方式

首版不追求复杂规则引擎，可以先组合静态检查、关键词检查和人工确认。

| 检查方式 | 用途 |
| --- | --- |
| 文档检查 | 是否已更新相关设计文档 |
| 文件路径检查 | 是否改动禁止区域 |
| 关键词检查 | SQL 高风险词、密钥字段、权限注解 |
| 依赖检查 | pom/package 是否新增依赖 |
| 编译检查 | Maven、前端构建 |
| 测试检查 | 单元/集成测试 |
| 人工确认 | L2/L3 风险 |

P0 可以先用代码规则和脚本检查；P1 再考虑可配置规则引擎。

## 12. Skill 生命周期

| 阶段 | 说明 |
| --- | --- |
| draft | 草案，不能作为强制规则 |
| active | 生效，AI 任务必须遵守 |
| deprecated | 已废弃，仅供历史任务查看 |

版本规则：

| 变更 | 版本 |
| --- | --- |
| 修正文案 | patch |
| 增加规则 | minor |
| 改变强制规则 | major |

规则变更流程：

| 步骤 | 要求 |
| --- | --- |
| draft | 新规则先进入草案，不能阻断任务 |
| review | 对照来源文档、阶段范围、质量门禁检查是否冲突 |
| active | 只有 active 规则才能作为强制门禁参与任务执行 |
| deprecated | 废弃后保留历史，不再被新任务加载为强制规则 |

任何降低安全级别、放宽生产边界、扩大编码授权或改变技术栈的规则变更，都属于 C2/C3 以上变更，必须先修订文档和 ADR。AI 不得为了完成当前任务临时修改规则、降级规则或把 `draft/deprecated` 规则当作 active 规则使用。

## 13. 审计记录

每次 AI 任务应记录使用了哪些 skill 和规则。

| 字段 | 说明 |
| --- | --- |
| taskId | AI 任务 |
| skillIds | 使用的 skill 列表 |
| skillSnapshot | 使用的 skill 版本、状态、优先级和 checksum |
| ruleIds | 触发的规则列表 |
| ruleSnapshot | 使用的规则版本、等级、来源和 checksum |
| resolutionTrace | 冲突处理、优先级裁决和最终动作 |
| blockedRules | 阻断任务的规则 |
| warnings | 警告规则 |
| userConfirmations | 用户确认记录 |
| verification | 验证结果 |

P0 管理端可先只读展示 skill、规则和快照；规则编辑、启停、批量导入和在线发布属于 P1。生产模式不得提供会影响代码生成、源码修改或交接包执行的规则编辑入口。

## 14. 已收敛决策项

| 决策 | 取舍口径 | 当前结论 |
| --- | --- | --- |
| Skill 首版存储 | 文件 / 数据库 | P0 文件优先，P1 同步数据库 |
| 规则检查实现 | 简单 Java 服务 / Drools 等规则引擎 | P0 简单服务，避免重依赖 |
| Skill 编辑入口 | 管理端页面 / 文件编辑 | P0 管理端只读，P1 再做受控编辑 |
| 规则强制级别 | 全部强制 / 按任务类型 | 按任务类型加载 |
| 业务 Skill 来源 | 手工维护 / AI 生成 | P0 手工维护，P1 AI 辅助生成 |
| 规则快照 | 仅看最新规则 / 任务级快照 | P0 必须记录任务级快照 |
| 规则冲突 | 模型自行判断 / 固定裁决表 | P0 使用固定裁决表并审计 |

## 15. 编码准入

进入 skill/rule 相关编码前必须满足：

| 条件 | 状态 |
| --- | --- |
| P0 Skill 类型确认 | 已由 ADR-0002 确认 |
| Skill 文件格式确认 | 已由 ADR-0002 确认为 YAML Front Matter + Markdown |
| 规则等级确认 | 已由 ADR-0002 确认 |
| L2/L3 风险确认策略确认 | 已由 ADR-0002 确认 |
| 首版检查方式确认 | 已由 ADR-0002 确认为静态检查 + 人工确认 |
| 审计记录字段确认 | 已由 ADR-0002 确认 |
| 规则快照字段确认 | 已在本文第 9、13 节确认 |
| 规则冲突裁决确认 | 已在本文第 8 节确认 |
| 规则变更流程确认 | 已在本文第 12 节确认 |

## 16. 一句话总结

Vibe Boot 的 skills 与规则系统要把 AI 的能力变成可控工程能力：知道项目是什么、知道该怎么做、知道什么不能做、知道什么时候必须停下来问人。
