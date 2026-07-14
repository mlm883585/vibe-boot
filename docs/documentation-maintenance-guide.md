# Vibe Boot 文档维护规则

## 1. 文档目的

本文定义 Vibe Boot 文档体系的维护规则，防止文档数量增加后出现索引缺失、决策冲突、引用失效和编码准入口径漂移。

Vibe Boot 当前坚持文档优先。文档优先不只是“先写文档”，还要求每次文档变更都能被后续读者、外部 AI Coding 工具和平台内 AI 工作台稳定发现、理解和执行。

## 2. 维护原则

| 原则 | 要求 |
| --- | --- |
| 一个入口 | 所有重要文档必须能从 `docs/README.md` 找到 |
| 一个决策源 | 技术选型、产品边界、AI 边界和交付策略不得在多个文档中给出不同结论 |
| 先改上游 | 重大变更先改 ADR、产品约束或路线图，再改任务分解 |
| 小步同步 | 新增文档时同步索引、准入审计、冻结清单和相关总纲 |
| 控制膨胀 | 优先修订已有文档；只有已有文档无法承载新的决策、证据或验收入口时才新增文档 |
| 可验证 | 每次维护后至少检查文件存在性、关键引用和相反表述 |
| 中文优先 | 面向中国中小企业和实施人员的文档默认使用中文 |

## 3. 文档分层

| 层级 | 文档类型 | 作用 | 变更要求 |
| --- | --- | --- | --- |
| L0 入口层 | `docs/README.md` | 阅读顺序、关键决策、编码闸门 | 新增重要文档必须同步 |
| L1 决策层 | 产品约束、ADR、MVP 路线 | 决定做什么、不做什么、为什么 | 重大变更先改这里 |
| L2 架构层 | 总纲、模块设计、后端/前端/API/数据库规范 | 定义系统结构和实现口径 | 必须服从 L1 |
| L3 能力层 | AI、模型网关、代码生成、开发包、生产包、安全治理 | 定义具体能力设计 | 变更后同步任务分解 |
| L4 任务层 | S1-S7 任务分解、工作令、验收剧本 | 指导编码和验收 | 不得自行扩大范围 |
| L5 审计层 | 准入审计、冻结清单、文档就绪审计、读者测试结果、需求追踪、文档验证日志、编码后变更控制、签收包 | 判断能否进入编码以及编码后如何控变更 | 关键文档变化后同步 |

## 4. 新增文档规则

新增文档前必须先判断是否真的需要新增。当前文档体系已经包含入口、决策、架构、能力、任务和审计层，后续默认优先修订已有文档。

| 判断问题 | 如果答案为是 | 处理 |
| --- | --- | --- |
| 是否只是补充已有章节细节 | 是 | 修改已有文档，不新增 |
| 是否只是补充检查结果 | 是 | 优先追加到 `docs/documentation-verification-log.md` 或相关审计文档 |
| 是否只是补充读者测试结果 | 是 | 优先追加到 `docs/pre-coding-reader-test-results.md` |
| 是否只是补充原始需求映射 | 是 | 优先追加到 `docs/requirements-traceability-matrix.md` |
| 是否改变产品、技术、AI 或安全决策 | 是 | 优先修订产品约束或 ADR |
| 是否出现新的独立证据链或验收入口 | 是 | 可以新增文档，但必须完成下方同步 |

新增文档时必须完成以下同步。

| 步骤 | 必须动作 |
| --- | --- |
| 1 | 明确文档属于 L0-L5 哪一层 |
| 2 | 普通文档使用 kebab-case 风格命名，ADR 使用 docs/adr/0001-example.md 这类编号风格命名 |
| 3 | 在 `docs/README.md` 阅读顺序中加入该文档 |
| 4 | 如影响编码闸门，在 `docs/README.md` 编码闸门中加入检查项 |
| 5 | 如影响产品边界，在 `docs/product-constraints.md` 中同步约束 |
| 6 | 如影响实现准入，在 `docs/implementation-readiness-audit.md` 中同步证据 |
| 7 | 如影响冻结项，在 `docs/coding-freeze-checklist.md` 中同步确认项 |
| 8 | 如影响文档完整性，在 `docs/documentation-readiness-review.md` 中同步审计 |
| 9 | 如属于总纲引用范围，在 `docs/vibe-boot-architecture.md` 中同步文档清单 |

## 5. 修改文档规则

| 修改类型 | 必须先改 | 必须同步 |
| --- | --- | --- |
| 产品定位变化 | `docs/product-constraints.md` | README、MVP 路线、准入审计、冻结清单 |
| 技术栈变化 | ADR | 产品约束、模块设计、质量门禁、准入审计 |
| AI 工具边界变化 | `docs/adr/0003-ai-tool-usage-boundary.md` | README、AI 策略、使用指南、工作台设计、安全治理、需求追踪、冻结清单、签收包、签收记录、读者测试、验证日志 |
| AI 工具分层定稿状态变化 | `docs/adr/0003-ai-tool-usage-boundary.md`、`docs/ai-tooling-strategy.md` | README、需求追踪、冻结清单、准入审计、文档就绪审计、签收包、签收记录、读者测试、读者测试结果、验证日志 |
| AI 使用路径变化 | `docs/ai-tool-usage-guide.md`、`docs/product-constraints.md` | README、需求追踪、路线图、冻结清单、签收包、读者测试、准入审计 |
| 外部 AI 交接包格式变化 | `docs/ai-tool-usage-guide.md` | 外部 AI 提示词、AI 工作台设计、读者测试、签收包 |
| S1 开工检查变化 | `docs/s1-implementation-work-order.md`、`docs/external-ai-coding-prompt.md` | README、需求追踪、质量门禁、冻结清单、签收包、签收记录、准入审计、读者测试、验证日志 |
| 阶段关闭证据包变化 | `docs/post-coding-change-control.md`、`docs/quality-gates.md`、`docs/s1-implementation-work-order.md`、`docs/external-ai-coding-prompt.md` | README、需求追踪、冻结清单、签收包、读者测试、读者测试结果、验证日志 |
| C0 授权边界变化 | `docs/post-coding-change-control.md`、`docs/coding-start-signoff-package.md` | 外部 AI 提示词、S1 工作令、准入审计、读者测试、需求追踪、冻结清单、签收记录、验证日志 |
| 签收等价确认或模糊签收规则变化 | `docs/coding-start-signoff.md`、`docs/coding-start-signoff-package.md` | README、冻结清单、准入审计、需求追踪、读者测试、读者测试结果、验证日志 |
| 签收仓库基线变化 | `docs/coding-start-signoff.md`、`docs/coding-start-signoff-package.md` | README、冻结清单、准入审计、需求追踪、文档验证日志 |
| 签收前预检命令变化 | `docs/coding-start-signoff-package.md`、`docs/documentation-maintenance-guide.md` | README、冻结清单、准入审计、需求追踪、文档验证日志 |
| 签收前最终审查表变化 | `docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md` | README、冻结清单、准入审计、需求追踪、读者测试、读者测试结果、文档验证日志 |
| 直接应用/补丁执行语义变化 | ADR-0002、ADR-0003、`docs/ai-tooling-strategy.md` | AI 使用指南、AI 工作台设计、代码生成设计、S4 任务、安全治理、需求追踪、冻结清单、签收记录、验证日志 |
| AI 能力成熟度变化 | `docs/ai-tool-usage-guide.md`、`docs/mvp-roadmap.md` | 冻结清单、签收记录、准入审计、文档就绪审计 |
| 模块边界变化 | `docs/module-design.md` | 术语命名、工程骨架、任务分解 |
| API 或数据库规范变化 | 对应规范文档 | 后端规格、代码生成、质量门禁 |
| Windows 开发包变化 | `docs/windows-devkit-design.md` | S5 任务、质量门禁、README |
| 生产安装包变化 | `docs/release-package-design.md` | S6 任务、安全治理、质量门禁 |
| S1-S7 范围变化 | `docs/mvp-roadmap.md` | 对应任务分解、准入审计、冻结清单 |

## 6. ADR 使用规则

以下情况必须新增或修订 ADR。

| 场景 | 处理 |
| --- | --- |
| 替换核心框架或工具 | 新增 ADR 或修订既有 ADR |
| 引入新中间件 | 新增 ADR，说明替代方案和运维成本 |
| 修改 AI 工具边界 | 修订 ADR-0003 |
| 修改 Patch/Runner 执行主体、执行位置或服务端能力 | 修订 ADR-0002 和 ADR-0003，并同步 AI 策略、工作台、代码生成和 S4 任务 |
| 把 P1/P2 AI 能力提前为 P0 | 修订 ADR-0003 或新增 ADR，并同步路线图和冻结清单 |
| 允许生产环境承接开发型 AI | 默认不得只靠文档修改通过，必须重新设计安全治理并形成 ADR |
| 修改实现契约 | 修订 ADR-0002 |
| 修改 MVP 技术选型 | 修订 ADR-0001 |
| 只补充任务细节 | 不一定新增 ADR，可更新任务分解 |

ADR 必须包含状态、背景、决策、影响、替代方案和后续约束。已接受 ADR 不应被任务文档绕开。

## 7. 引用规则

| 规则 | 说明 |
| --- | --- |
| 文档引用使用相对路径 | 例如 `docs/quality-gates.md` |
| 文件名必须真实存在 | 示例路径要明确标为示例或未来生成物 |
| 不引用本地绝对路径 | 避免换机器后失效 |
| 不用“见上文”代替文档名 | 让 AI 工具能准确检索上下文 |
| 新文档必须有入口 | 不能只在聊天记录里提到 |

推荐检查命令：

```powershell
$actual = Get-ChildItem docs -Recurse -Filter *.md | ForEach-Object { (Resolve-Path -LiteralPath $_.FullName -Relative).Replace('.\docs\','').Replace('\','/') } | Sort-Object
$indexed = Select-String -Path docs\README.md -Pattern '^\| \d+ \| `([^`]+)`' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Sort-Object
$actual | Where-Object { $_ -notin $indexed -and $_ -ne 'README.md' }
$indexed | Where-Object { $_ -notin $actual }
rg -n "TODO|待定|未决|暂定|还没有确定|没有确定|待进一步|planning" docs
rg -n "生产.*允许.*改代码|P0.*自研完整|服务端任意 shell" docs
rg -n "Node\\.js 22|pnpm|yarn|Naive UI|Spring Security|Spring Cloud|MQ|Elasticsearch|Kubernetes" docs
rg -n "首版不替代 Codex|外部 AI Coding 工具作为 P0 真实源码修改主路径|P0 不自研完整 AI IDE" docs/coding-freeze-checklist.md docs/coding-start-signoff.md
rg -n "AI 工具使用方式已分层定稿|不再作为未定问题悬空|AI 工具分层定稿状态变化" docs/README.md docs/adr/0003-ai-tool-usage-boundary.md docs/requirements-traceability-matrix.md docs/coding-freeze-checklist.md docs/coding-start-signoff-package.md docs/coding-start-signoff.md docs/documentation-verification-log.md
rg -n "C0|C1|C2|C3|C4|编码后变更控制" docs/post-coding-change-control.md docs/coding-freeze-checklist.md docs/coding-start-signoff.md docs/pre-coding-reader-test.md
rg -n "读者测试结果|pre-coding-reader-test-results|Reader Test" docs/README.md docs/pre-coding-reader-test-results.md docs/coding-start-signoff.md docs/coding-freeze-checklist.md docs/implementation-readiness-audit.md
rg -n "签收包|coding-start-signoff-package|编码启动签收包" docs/README.md docs/coding-start-signoff-package.md docs/coding-start-signoff.md docs/coding-freeze-checklist.md docs/implementation-readiness-audit.md
rg -n "签收基线|仓库基线|提交哈希|工作区文档范围|签收文档 manifest|SHA256|ManifestDocs|未纳入签收基线" docs/README.md docs/coding-start-signoff-package.md docs/coding-start-signoff.md docs/coding-freeze-checklist.md docs/implementation-readiness-audit.md docs/requirements-traceability-matrix.md docs/documentation-verification-log.md
rg -n "签收前预检|预检命令包|MissingFromIndex|MissingMarkdownRefs|ManifestDocs|SourceDirs|git status --short" docs/README.md docs/coding-start-signoff-package.md docs/coding-freeze-checklist.md docs/documentation-maintenance-guide.md docs/documentation-verification-log.md docs/implementation-readiness-audit.md docs/requirements-traceability-matrix.md
rg -n "签收前最终审查|最终审查表|第 3.2 节|产品范围、技术栈、Windows 优先" docs/README.md docs/coding-start-signoff-package.md docs/coding-start-signoff.md docs/coding-freeze-checklist.md docs/implementation-readiness-audit.md docs/requirements-traceability-matrix.md docs/pre-coding-reader-test.md docs/pre-coding-reader-test-results.md docs/documentation-verification-log.md
rg -n "需求追踪|requirements-traceability-matrix|原始产品要求" docs/README.md docs/requirements-traceability-matrix.md docs/coding-start-signoff.md docs/coding-freeze-checklist.md docs/implementation-readiness-audit.md
rg -n "文档验证日志|documentation-verification-log|MissingMarkdownRefs|ReadmeNumbering" docs/README.md docs/documentation-verification-log.md docs/coding-start-signoff.md docs/coding-freeze-checklist.md docs/implementation-readiness-audit.md
rg -n "等价签收|模糊签收|同意|可以开始|不构成等价确认" docs/README.md docs/coding-start-signoff-package.md docs/coding-start-signoff.md docs/coding-freeze-checklist.md docs/requirements-traceability-matrix.md docs/implementation-readiness-audit.md docs/pre-coding-reader-test.md docs/pre-coding-reader-test-results.md docs/documentation-verification-log.md
rg -n "首次使用|交接包|企业用户不必懂源码|能力成熟度|AI 使用路径产品化" docs/README.md docs/mvp-roadmap.md docs/requirements-traceability-matrix.md docs/documentation-readiness-review.md docs/ai-tool-usage-guide.md docs/product-constraints.md docs/coding-freeze-checklist.md docs/coding-start-signoff-package.md docs/coding-start-signoff.md docs/pre-coding-reader-test.md docs/pre-coding-reader-test-results.md docs/implementation-readiness-audit.md
rg -n "S1 开工检查|signoffStatus|s1Allowed|launchPhraseExact|sourceDirsBefore|admissionCard.result" docs/README.md docs/requirements-traceability-matrix.md docs/s1-implementation-work-order.md docs/external-ai-coding-prompt.md docs/quality-gates.md docs/coding-freeze-checklist.md docs/coding-start-signoff-package.md docs/coding-start-signoff.md docs/implementation-readiness-audit.md docs/pre-coding-reader-test.md docs/pre-coding-reader-test-results.md docs/documentation-verification-log.md
rg -n "阶段关闭证据包|S1 关闭证据|S1 输出摘要|自动授权 S2|下一阶段请求" docs/README.md docs/post-coding-change-control.md docs/quality-gates.md docs/s1-implementation-work-order.md docs/external-ai-coding-prompt.md docs/s1-task-breakdown.md docs/coding-freeze-checklist.md docs/coding-start-signoff-package.md docs/pre-coding-reader-test.md docs/pre-coding-reader-test-results.md docs/requirements-traceability-matrix.md docs/documentation-verification-log.md
rg -n "C0 不成立|C0 自动降级|阶段启动指令|C0 前提是否成立|C0 不替代|C0 不绕过" docs/post-coding-change-control.md docs/coding-start-signoff-package.md docs/implementation-readiness-audit.md docs/pre-coding-reader-test.md docs/pre-coding-reader-test-results.md docs/s1-implementation-work-order.md docs/external-ai-coding-prompt.md docs/requirements-traceability-matrix.md docs/coding-freeze-checklist.md docs/coding-start-signoff.md
rg -n "开发工作区|本地受控执行器|服务端任意文件写入|任意 shell|生产环境不得.*写源码|生产模式不得应用代码补丁|生产补丁.*SQL.*shell|生产执行入口" docs/adr/0002-mvp-implementation-contracts.md docs/adr/0003-ai-tool-usage-boundary.md docs/ai-tooling-strategy.md docs/ai-workbench-design.md docs/code-generation-design.md docs/s4-task-breakdown.md docs/ai-tool-usage-guide.md docs/security-governance.md docs/requirements-traceability-matrix.md docs/coding-freeze-checklist.md docs/coding-start-signoff-package.md docs/coding-start-signoff.md
```

说明：`vibe-job`、`待确认`、`还没有确定` 等词可能出现在“明确禁止项”“读者测试反例”或“历史收敛说明”中，检查时应结合上下文判断；真正需要处理的是仍把它们当成待实现范围或未冻结决策的表述。
技术替代项也可能出现在“放弃方案”或“暂不支持”说明中，只有当它们被描述为首版实现选择时才需要修订。

## 8. 编码前文档检查

进入编码前至少执行以下检查。

| 检查项 | 通过标准 |
| --- | --- |
| README 索引 | 除 `docs/README.md` 自身外，所有重要 Markdown 文档均出现在阅读顺序中，且阅读顺序不指向不存在的文件 |
| 编码闸门 | 新增准入文档在闸门中标记 |
| ADR 一致性 | 技术选型、AI 边界、实现契约无冲突 |
| 阶段边界 | S1-S7 没有跨阶段偷跑 |
| 禁止项 | 未出现生产在线改代码、P0 自研完整 IDE、额外中间件等反向表述 |
| 技术栈选择 | Node.js 20.19+ LTS、npm、Vue 3.5.39、Vite 8.1.3、TypeScript 6.0.3、Element Plus 2.14.2、Sa-Token 等首版选择没有被替代项覆盖 |
| 引用完整 | 新增引用的文档存在，示例路径已标注 |
| 冻结清单 | 进入编码前需要人工确认的事项完整 |
| 签收记录 | `docs/coding-start-signoff.md` 明确当前是否允许开始 S1 |
| 签收仓库基线 | 签收记录必须明确提交哈希；如签收未提交工作区，必须明确 manifest 生成时间、`ManifestDocs` 数量、纳入范围和 SHA256 清单 |
| 签收前预检命令 | Git 状态、README 索引、Markdown 引用、签收文档 manifest、源码目录、签收状态和忽略规则检查必须可执行 |
| 签收前最终审查表 | `docs/coding-start-signoff-package.md` 第 3.2 节必须逐项确认，但不得替代 `docs/coding-start-signoff.md` 签收记录 |
| 启动口令 | 精确文本必须保持为 `开始 S1 工程骨架编码`，不得添加句号、冒号或额外后缀 |
| 等价签收 | 等价确认必须包含签收包接受、S1 范围、最终审查表全部确认、全部签收项、签收人、签收日期和签收基线；模糊表达不得视为签收 |
| 冻结与签收同步 | `docs/coding-freeze-checklist.md` 新增的签收项必须同步到 `docs/coding-start-signoff.md` |
| 编码后变更控制 | C0-C4 分级在变更控制、冻结清单、签收记录和读者测试中保持一致 |
| C0 授权边界 | C0 不绕过签收记录和阶段启动指令；未签收时 C0 不成立，只允许修订文档 |
| 读者测试结果 | 修改签收、阶段边界、AI 工具边界后重新执行并更新 `docs/pre-coding-reader-test-results.md` |
| AI 使用路径产品化 | 首次使用引导、外部 AI 交接包、企业用户路径和能力成熟度在 README、路线图、需求追踪、冻结、签收和读者测试中保持一致 |
| AI 使用准入卡 | `admissionCard` / `admission_card_json` 命名和语义在术语、API、数据库、AI 工作台、代码生成、外部提示词、质量门禁、冻结清单和签收记录中保持一致 |
| S1 开工检查 | `signoffStatus`、`s1Allowed`、`launchPhraseExact`、`sourceDirsBefore`、`allowedScope`、`forbiddenScope` 和 `admissionCard.result` 在 README、需求追踪、S1 工作令、外部提示词、质量门禁、冻结清单、签收包、签收记录和读者测试中保持一致 |
| 阶段关闭证据包 | 交付物、验证、越界检查、文档同步、残余风险、下一阶段请求在 README、变更控制、质量门禁、S1 工作令、外部提示词、读者测试和签收材料中保持一致 |
| 直接应用语义 | 补丁/文件写入只限开发工作区，由外部 AI Coding 工具或本地受控执行器承接，不得被改写成服务端任意文件写入、任意 shell 或生产在线改源码 |
| 交接包生产边界 | 外部 AI 交接包只用于开发/实施链路，不能作为生产补丁、SQL 或 shell 执行入口 |
| 需求追踪矩阵 | 原始产品要求变化时同步 `docs/requirements-traceability-matrix.md` 和签收包 |
| 文档验证日志 | 关键文档变化后重新执行检查，并更新 `docs/documentation-verification-log.md` |
| 签收包 | `docs/coding-start-signoff-package.md`、`docs/coding-start-signoff.md`、README、冻结清单和准入审计保持一致 |
| 读者测试 | `docs/pre-coding-reader-test.md` 能验证读者是否理解当前状态和 S1 边界 |

## 9. AI 工具维护规则

外部 AI Coding 工具修改文档时必须遵守：

| 规则 | 要求 |
| --- | --- |
| 先读入口 | 从 `docs/README.md` 开始 |
| 先判断层级 | 明确修改的是决策层、架构层、能力层还是任务层 |
| 先找上游 | 如果任务文档和 ADR 冲突，优先修订上游决策 |
| 不扩大范围 | 不借文档维护顺手新增产品能力 |
| 不弱化 AI 路径 | 不把首次使用引导、外部 AI 交接包或企业用户路径删成口头约定 |
| 不弱化准入卡 | 不删除 `admissionCard`，不把准入卡降级为普通备注、审批流或生产授权 |
| 不弱化 S1 开工检查 | 不把结构化开工检查删成口头确认，也不允许跳过签收、精确口令、目录基线或禁止范围检查 |
| 不弱化阶段关闭证据 | 不把阶段关闭证据包删成“已完成”一句话，也不允许用关闭证据自动授权下一阶段 |
| 不弱化执行边界 | 不把开发工作区补丁应用改写成服务端任意文件写入、任意 shell 或生产在线执行 |
| 不弱化 C0 边界 | 不把 C0 当成未签收或未启动阶段的编码许可 |
| 不弱化启动口令 | 不把精确启动口令改成“开始 S1 编码”、带句号版本或其他近似表达 |
| 不弱化签收动作 | 不把“同意”“可以开始”“按文档做”等模糊表达当成等价签收 |
| 不弱化签收基线 | 不把未确认草稿、未纳入签收文档 manifest 的工作区文件或来源不明的文档快照作为编码依据 |
| 不弱化最终审查 | 不把签收前最终审查表删成一句口头确认，也不把最终审查表当成正式签收或启动口令 |
| 输出摘要 | 说明修改了哪些文档、影响哪些准入项、是否需要人工确认 |

平台内 AI 工作台生成文档摘要时，也必须使用本文作为维护约束。

## 10. 一句话总结

Vibe Boot 的文档维护规则是：所有重要信息必须能从 README 进入，所有重大决策必须有上游来源，所有范围变化必须同步准入和冻结清单；否则文档越多，AI coding 越容易偏航。
