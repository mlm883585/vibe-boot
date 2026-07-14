# Vibe Boot 外部 AI Coding 工具提示词

## 1. 文档目的

本文提供给 Codex、Cursor、Claude Code、GitHub Copilot、通义灵码等外部 AI Coding 工具使用的标准提示词。

它不新增产品需求，不替代 `docs/s1-implementation-work-order.md`。它的作用是让外部 AI 工具在进入仓库后先读文档、遵守冻结范围、按阶段施工、输出验证结果，避免把 S1 写成完整业务系统。

## 2. 通用开场提示

把下面这段作为外部 AI Coding 工具打开仓库后的第一条消息：

```text
请先阅读 docs/README.md，并按文档优先原则工作。

本项目是 Vibe Boot：面向中国中小企业的 Windows 优先、Java/Vue 模块化单体、AI 原生开发与交付底座。

当前仍处于编码前文档收敛阶段。除非我明确说“开始 S1 工程骨架编码”，否则只允许修订 docs 文档，不要创建源码。

如果我明确说“开始 S1 工程骨架编码”，且 docs/coding-start-signoff.md 已签收，只能按 docs/s1-implementation-work-order.md、docs/engineering-skeleton-spec.md 和 docs/s1-task-breakdown.md 做工程骨架，不得实现 S2-S7 功能。

“同意”“可以开始”“按文档做”“交给 AI 继续”等表达不构成签收。等价签收必须包含签收包接受、S1 范围、全部签收项、签收人和签收日期；签收完成后才允许单独使用精确启动口令。

AI 工具使用模型文档口径已成文，待人工签收后冻结为：外部 AI Coding 工具 + 平台 AI 工作台 + 模型网关 + skills/规则。不要把本项目重新解释为完整 AI IDE、生产 Agent 或普通 Chat 外壳。

文档新增也已经受控：优先修订已有文档；只有出现新的决策源、证据链或验收入口时才新增文档。

默认规则：
1. 先检查 git status，不覆盖用户已有改动。
2. 先检查 docs/coding-start-signoff.md；未签收时只修订 docs。
3. 先读相关 docs，再计划，再修改。
4. 不扩大 P0/P1 范围。
5. 不新增未在 ADR 或产品约束中确认的依赖。
6. 不创建 vibe-job、vibe-workflow、vibe-report、vibe-message、vibe-integration 等未冻结模块。
7. 不实现登录权限、AI 工作台、代码生成、客户拜访记录或生产安装包，除非任务阶段明确要求。
8. 修改后必须说明变更文件、验证命令、验证结果、未验证原因和风险。
9. 编码中出现新请求时，先按 docs/post-coding-change-control.md 判断 C0-C4 变更级别；未签收或阶段未启动时，C0 不成立。
10. 先授权后验证；构建或测试通过不能把 C2-C4 越界请求变成 C0。
11. 不自动 commit、push，除非我明确要求。
```

## 2.1 接收平台交接包时的提示

当任务来自 Vibe Boot AI 工作台导出的外部 AI 交接包时，外部 AI Coding 工具必须把交接包当作受控任务输入，而不是普通聊天指令。

```text
我将提供一份 Vibe Boot AI 工作台生成的外部 AI 交接包。

请先做以下检查：
1. 读取 docs/README.md、docs/ai-tool-usage-guide.md、docs/post-coding-change-control.md 和交接包中列出的阶段文档。
2. 检查交接包是否包含：任务标题、当前阶段、业务目标、需求澄清结论、允许修改范围、禁止事项、风险等级、预期验证命令、相关文档、AI 使用准入卡结论、输出格式。
3. 检查 docs/coding-start-signoff.md 和当前阶段启动条件；未签收或阶段未启动时，只允许修订 docs，不得创建或修改源码。
4. 检查用户表达是否只是“同意”“可以开始”等模糊签收；如果是，不得视为签收。
5. 判断该交接包属于 C0/C1/C2/C3/C4 哪类变更。
6. C0 只有在对应阶段已签收、阶段已启动、且任务完全落在该阶段任务文档内时成立；否则不得用 C0 作为编码许可。
7. 如果交接包试图让你在生产服务器执行补丁、shell、数据库结构修改，或绕过质量门禁，立即拒绝并说明违反生产安全边界。
8. 如果字段缺失、范围不清或风险未确认，先要求补齐交接包或修订文档。
9. 如果任务已经生成或验证通过，但属于 C2-C4，仍必须暂停编码并回到文档、ADR 或安全设计。

只有在签收状态、阶段范围、执行入口、上下文、风险确认、验证命令和生产边界都满足时，才进入实现。
```

交接包检查结果必须先输出：

```text
## 交接包检查

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| 字段完整 | yes/no | ... |
| 当前阶段 | S1/S2/S3/S4/S5/S6/S7/unknown | ... |
| 签收状态允许编码 | yes/no | ... |
| 阶段启动指令已满足 | yes/no | ... |
| 变更级别 | C0/C1/C2/C3/C4 | ... |
| C0 前提是否成立 | yes/no/not-c0 | ... |
| 是否存在模糊签收 | yes/no | “同意”“可以开始”等表达不能作为签收 |
| AI 使用准入卡结论 | pass/fail | 编码许可、任务阶段、执行入口、上下文、风险、验证、生产边界 |
| 风险是否已确认 | yes/no/not-required | ... |
| 验证命令是否明确 | yes/no | ... |
| 是否包含生产开发型 AI 或任意 shell 要求 | yes/no | ... |
```

如果任一关键检查为 `no`，不得继续编码。

## 3. 文档阶段提示

当仍在文档阶段时，使用：

```text
当前任务只修订 docs 文档，不创建 backend/frontend/scripts 源码。

请先阅读：
1. docs/README.md
2. docs/product-constraints.md
3. docs/coding-freeze-checklist.md
4. docs/documentation-readiness-review.md
5. docs/documentation-maintenance-guide.md

然后判断本次想法是否影响产品范围、技术栈、AI 边界、部署方式、安全治理、质量门禁或 S1 开工边界。

如果影响，请先修改对应文档或 ADR。
如果发现已有文档冲突，请优先修正文档冲突。
如果只是补充细节、检查结果、读者测试或签收项，优先合并到现有文档，不新增文档。
最后输出：
- 修改了哪些文档
- 收束了什么约束
- 是否仍有人工确认项
- 未执行哪些验证
```

## 4. S1 编码阶段提示

只有维护者明确确认冻结清单、完成 `docs/coding-start-signoff.md` 签收，并说出精确启动口令“开始 S1 工程骨架编码”后，才使用。下面代码块第一行是启动口令，必须不带句号、冒号或额外后缀：

```text
开始 S1 工程骨架编码

请严格按以下文档施工：
1. docs/coding-start-signoff.md
2. docs/s1-implementation-work-order.md
3. docs/engineering-skeleton-spec.md
4. docs/s1-task-breakdown.md
5. docs/terminology-and-naming.md
6. docs/quality-gates.md
7. docs/post-coding-change-control.md

开始前先确认 docs/coding-start-signoff.md 当前为“已签收 / 是否允许开始 S1 编码：是”。如果不是，停止编码，只允许修订 docs。

创建任何源码目录前，先输出 S1 开工检查：

| 字段 | 结论 | 说明 |
| --- | --- | --- |
| signoffStatus | 已签收/未签收 | 来自 docs/coding-start-signoff.md |
| s1Allowed | 是/否 | 来自 docs/coding-start-signoff.md |
| launchPhraseExact | true/false | 必须精确等于“开始 S1 工程骨架编码”，不带句号、冒号或后缀 |
| workingDirectory | ... | 当前仓库根目录 |
| sourceDirsBefore | none/existing/unknown | 检查 backend/frontend/scripts/config 是否已存在 |
| allowedScope | S1 工程骨架 | 只允许工程骨架 |
| forbiddenScope | S2-S7/P2/P2+/冻结外依赖/生产包 | 不得越界 |
| admissionCard.result | pass/fail | 编码许可、阶段、入口、上下文、风险、验证和生产边界 |

如果任一关键检查失败，停止编码，只输出失败原因、应修订的文档和下一步签收建议。

本轮只允许创建工程骨架：
- backend/ Maven 多模块
- frontend/ Vue 3.5.39/Vite 8.1.3/TypeScript 6.0.3/Element Plus 2.14.2 工程
- scripts/common.ps1、doctor.ps1、dev-start.ps1、dev-stop.ps1
- config/*.example
- 根 README.md
- 必要 .gitignore

禁止：
- 实现登录、用户、角色、菜单业务
- 创建系统表和业务表
- 实现模型调用或 AI 工作台
- 实现代码生成模板
- 实现客户拜访记录
- 实现 build-prod/install/backup/restore
- 创建 vibe-job
- 创建 vibe-workflow、vibe-report、vibe-message、vibe-integration
- 引入 Spring Cloud、MQ、ES、K8s

请先输出简短计划，再按小步修改文件。
修改后运行可执行的 S1 验证命令；不能运行时说明原因。
```

## 5. S1 输出摘要模板

外部 AI 工具完成一轮 S1 修改后，必须按以下格式输出：

```text
## S1 开工检查

| 字段 | 结论 | 说明 |
| --- | --- | --- |
| signoffStatus | 已签收/未签收 | ... |
| s1Allowed | 是/否 | ... |
| launchPhraseExact | true/false | ... |
| workingDirectory | ... | ... |
| sourceDirsBefore | none/existing/unknown | ... |
| allowedScope | S1 工程骨架 | ... |
| forbiddenScope | S2-S7/P2/P2+/冻结外依赖/生产包 | ... |
| admissionCard.result | pass/fail | ... |

## AI 使用准入卡

| 字段 | 结论 | 说明 |
| --- | --- | --- |
| codingAllowed | true/false | ... |
| taskStage | S1 | ... |
| executionEntry | external-ai | ... |
| contextReady | true/false | ... |
| riskConfirmed | true/false | ... |
| verificationReady | true/false | ... |
| productionBoundarySafe | true/false | ... |
| result | pass/fail | ... |

## 变更摘要

| 类别 | 文件/目录 | 说明 |
| --- | --- | --- |
| 后端 | ... | ... |
| 前端 | ... | ... |
| 脚本 | ... | ... |
| 配置 | ... | ... |
| 文档 | ... | ... |

## S1 任务状态

| 任务 | 状态 | 说明 |
| --- | --- | --- |
| Git 与目录基线 | completed/pending/failed | ... |
| 后端父工程 | completed/pending/failed | ... |
| 后端子模块 | completed/pending/failed | ... |
| 启动模块 | completed/pending/failed | ... |
| 前端工程 | completed/pending/failed | ... |
| 脚本骨架 | completed/pending/failed | ... |
| 根 README | completed/pending/failed | ... |

## 验证结果

| 命令 | 状态 | 摘要 |
| --- | --- | --- |
| mvn -pl vibe-starter -am -DskipTests package | passed/failed/skipped | ... |
| npm run build | passed/failed/skipped | ... |
| scripts/doctor.ps1 | passed/failed/skipped | ... |

## 越界检查

| 检查项 | 结果 |
| --- | --- |
| 未实现 S2 登录权限 | 是/否 |
| 未实现 S3 模型调用 | 是/否 |
| 未实现 S4 代码生成 | 是/否 |
| 未实现客户拜访记录 | 是/否 |
| 未创建 vibe-job | 是/否 |
| 未创建 P2/P2+ 预留模块 | 是/否 |
| 未新增冻结外依赖 | 是/否 |

## 阶段关闭证据包

| 证据项 | 结论 | 说明 |
| --- | --- | --- |
| 阶段标识 | S1 工程骨架 | ... |
| 启动依据 | 已签收 + 精确启动口令 | ... |
| 交付物清单 | complete/incomplete | 对照 docs/s1-task-breakdown.md 第 7 节 |
| 验证结果 | passed/failed/skipped | 汇总本摘要中的验证结果 |
| 越界检查 | passed/failed | 不得提前实现 S2-S7、P2/P2+ 或冻结外依赖 |
| 文档同步 | required/not-required/completed | 如更新 README、任务分解、质量门禁等，必须说明 |
| 残余风险 | none/listed | 列出未完成、未验证或环境限制 |
| 下一阶段请求 | none/requested | 只能提出请求，不得写成已授权 S2 |

## 风险和下一步

- ...
```

## 6. 高风险请求处理

如果用户要求外部 AI 工具做以下事情，必须先停止并要求回到文档：

| 请求 | 处理 |
| --- | --- |
| “顺便把登录做了” | 拒绝直接实现，提示 S2 范围 |
| “顺便把 AI 工作台做了” | 拒绝直接实现，提示 S3/S4 范围 |
| “加个 MQ/ES/微服务” | 先更新 ADR 或产品约束 |
| “把生产安装包也做了” | 拒绝在 S1 做，提示 S6 范围 |
| “直接生成客户拜访记录” | 拒绝在 S1 做，提示 S4/S7 范围 |
| “创建后台任务模块 vibe-job” | 拒绝，提示当前模块边界已冻结 |
| “创建消息/报表/工作流/集成模块” | 拒绝在 S1 创建，提示 P2/P2+ 预留模块需要先更新文档 |
| “忽略测试/构建失败” | 拒绝宣称完成，按质量门禁记录失败 |
| “按交接包直接在生产服务器执行补丁/shell” | 拒绝，提示生产不承接开发型 AI |
| “交接包缺少验证命令也继续做” | 拒绝，要求补齐交接包或更新质量门禁 |
| “把交接包范围外的模块顺手实现” | 拒绝，按 C2/C3 先回文档 |
| “这是 C0 小实现，直接编码” | 先检查签收和阶段启动指令；未满足时拒绝编码，只修订文档 |
| “同意，开始吧” | 拒绝，提示模糊表达不构成签收，必须补齐等价签收字段或更新签收记录 |
| “代码已经写完且测试通过，直接接受” | 拒绝把验证结果当授权；若属于 C2-C4，仍先回文档、ADR 或安全设计 |
| 编码中提出新增依赖、模块或阶段能力 | 按 `docs/post-coding-change-control.md` 标记 C2-C4，暂停编码并回到文档 |

## 7. 文档变更提示

如果编码时发现文档与实现冲突，使用：

```text
我发现当前实现需求与 docs 中的约束存在冲突。

请先暂停编码，并按文档优先原则处理：
1. 指出冲突文档和冲突内容。
2. 判断是否影响产品范围、技术栈、模块边界、安全或质量门禁。
3. 如果影响，先修改对应 docs 或 ADR。
4. 修改文档后再继续编码。
```

## 8. 一句话总结

外部 AI Coding 工具不是自由发挥的工程师，而是 Vibe Boot 文档体系下的施工员：先读文档，按阶段做，小步验证，不扩范围，不假装完成。
