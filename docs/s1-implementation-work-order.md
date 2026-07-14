# Vibe Boot S1 工程骨架实施工作令

## 1. 文档目的

本文是 S1 工程骨架编码的签收后执行入口，用于交给人类开发者或外部 AI Coding 工具作为第一轮施工指令。

本文不新增需求，不替代 `docs/engineering-skeleton-spec.md` 和 `docs/s1-task-breakdown.md`。它只把签收后 S1 允许做什么、禁止做什么、按什么顺序做、如何验证，压缩成一份施工工作令；未签收时只能作为审阅和修订对象。

## 2. 开工前必须阅读

| 顺序 | 文档 | 目的 |
| --- | --- | --- |
| 1 | `docs/README.md` | 确认文档入口和编码闸门 |
| 2 | `docs/coding-start-signoff.md` | 确认当前是否已签收并允许 S1 编码 |
| 3 | `docs/coding-freeze-checklist.md` | 确认范围冻结 |
| 4 | `docs/documentation-readiness-review.md` | 确认当前只允许 S1 签收准备，签收后才可开工 |
| 5 | `docs/terminology-and-naming.md` | 确认模块、目录、脚本和状态命名 |
| 6 | `docs/engineering-skeleton-spec.md` | 确认 S1 规格 |
| 7 | `docs/s1-task-breakdown.md` | 确认 S1 任务顺序 |
| 8 | `docs/quality-gates.md` | 确认验证命令和失败口径 |
| 9 | `docs/documentation-maintenance-guide.md` | 确认文档同步、ADR 和引用规则 |
| 10 | `docs/post-coding-change-control.md` | 确认编码后新增请求的 C0-C4 分级处理 |
| 11 | `docs/external-ai-coding-prompt.md` | 如果使用外部 AI Coding 工具，确认提示词和输出格式 |

未读完以上文档，不得开始编码。

开工还必须同时满足四个条件：

| 条件 | 要求 |
| --- | --- |
| 签收状态 | `docs/coding-start-signoff.md` 当前必须为“已签收 / 是否允许开始 S1 编码：是” |
| 启动口令 | 维护者必须明确说出“开始 S1 工程骨架编码” |
| 阶段准入记录 | 收到精确口令后，先创建 **docs/stage-records/S1-admission.md**，完整记录 `stageAdmission` 且 `decision=pass` |
| AI 使用准入卡 | 外部 AI Coding 工具必须先给出 `admissionCard` 结论，确认编码许可、任务阶段、执行入口、上下文、风险、验证和生产边界 |

缺少任一条件时，本文只能作为施工准备文档，不得据此创建源码目录。

说明：`docs/post-coding-change-control.md` 中的 C0 已授权小实现不替代本节签收状态和启动口令。未签收或未收到启动口令时，C0 不成立，外部 AI Coding 工具只能修订文档。

## 3. S1 开工检查输出

在创建任何源码目录之前，人类开发者或外部 AI Coding 工具必须先输出 S1 开工检查。该检查不是新的授权来源，只是把签收记录、启动口令、目录基线和允许范围显式化。

| 检查字段 | 必须值 | 失败处理 |
| --- | --- | --- |
| `signoffStatus` | `已签收` | 停止编码，只允许修订 `docs/` |
| `s1Allowed` | `是` | 停止编码，只允许修订 `docs/` |
| `launchPhraseExact` | `true`，且口令精确等于 `开始 S1 工程骨架编码` | 停止编码，提示补齐精确口令 |
| `stageAdmissionPath` | **docs/stage-records/S1-admission.md**，且完整记录的 `decision=pass` | 停止编码，补齐并持久化准入记录 |
| `workingDirectory` | 项目根目录 | 停止编码，切换到正确仓库根目录 |
| `sourceDirsBefore` | 未创建 `backend/`、`frontend/`、`scripts/`、`config/`，或说明这些目录来自已授权的 S1 变更 | 如果来源不明，停止并先审计 |
| `allowedScope` | 只允许 S1 工程骨架 | 停止越界任务，回到阶段文档 |
| `forbiddenScope` | S2-S7 功能、P2/P2+ 模块、冻结外依赖、生产安装包 | 停止越界任务，回到文档或 ADR |
| `admissionCard.result` | `pass` | 停止编码，补齐准入卡或修订文档 |

推荐输出格式：

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
```

任一关键字段失败时，不得创建或修改源码目录；本轮只能输出失败原因、应修订的文档和下一步签收建议。

## 4. 本轮目标

S1 只建立最小可启动、可构建、可诊断的工程骨架。

| 目标 | 成功标准 |
| --- | --- |
| 后端骨架 | `backend/` Maven 多模块存在，`vibe-starter` 可快速构建 |
| 前端骨架 | `frontend/` Vue 3.5.39 + Vite 8.1.3 + TypeScript 6.0.3 + Element Plus 2.14.2 + Pinia 3.0.4 + Vue Router 4.6.4 + Axios 1.18.1 可构建 |
| 脚本骨架 | `scripts/doctor.ps1`、`dev-start.ps1`、`dev-stop.ps1` 有中文输出 |
| 配置骨架 | dev/prod/local example 分离，密钥不入库 |
| 根 README | 指向 docs、开发检查、启动和验证命令 |
| 忽略规则 | `reference/`、`runtime/`、`data/`、`logs/`、`package/`、local 配置均忽略 |

## 5. 允许创建的后端模块

| 模块 | 是否允许 | S1 内容 |
| --- | --- | --- |
| `vibe-common` | 是 | 空模块或最小公共包 |
| `vibe-security` | 是 | 空模块或权限封装占位 |
| `vibe-system` | 是 | 空模块 |
| `vibe-ai` | 是 | 空模块 |
| `vibe-skill` | 是 | 空模块 |
| `vibe-gen` | 是 | 空模块 |
| `vibe-file` | 是 | 空模块 |
| `vibe-starter` | 是 | 启动类、基础配置、健康检查 |
| `vibe-job` | 否 | P1 如需后台任务，先改文档 |
| `vibe-workflow` | 否 | P2 |
| `vibe-report` | 否 | P2 |
| `vibe-message` | 否 | P2+ |
| `vibe-integration` | 否 | P2 |

## 6. 禁止越界

| 禁止 | 原因 |
| --- | --- |
| 实现登录、用户、角色、菜单业务 | S2 范围 |
| 创建系统表和初始化菜单 SQL | S2 范围 |
| 实现模型配置和模型调用 | S3 范围 |
| 实现 AI 工作台页面和任务流 | S4 范围；S3 只做模型网关 |
| 实现代码生成模板 | S4 范围 |
| 实现客户拜访记录 | S4/S7 范围 |
| 实现生产打包和安装脚本 | S6 范围 |
| 新增 Spring Cloud、MQ、ES、K8s | 违反技术栈冻结 |
| 创建 `vibe-job` 模块 | 当前模块边界已冻结 |
| 创建 `vibe-workflow`、`vibe-report`、`vibe-message`、`vibe-integration` 模块 | P2/P2+ 预留，S1 不创建 |

## 7. 实施顺序

| 顺序 | 动作 | 验收 |
| --- | --- | --- |
| 1 | 检查当前 Git 状态 | 不覆盖用户已有改动 |
| 2 | 更新 `.gitignore` | 忽略 runtime/data/logs/package/reference/local 配置 |
| 3 | 创建顶层目录 | `backend/`、`frontend/`、`scripts/`、`config/` |
| 4 | 创建 `backend/pom.xml` | Maven 父工程可识别所有允许模块 |
| 5 | 创建后端子模块 | 只创建允许模块 |
| 6 | 创建 `vibe-starter` 启动类和配置 | 可快速构建；Actuator 在 `127.0.0.1:8081` 提供标准摘要，业务端口不暴露管理路由 |
| 7 | 创建 Vue 前端骨架 | `npm install`、`npm run build` 可执行 |
| 8 | 创建 PowerShell 脚本骨架 | doctor/dev-start/dev-stop 有中文输出 |
| 9 | 创建配置模板 | example 文件存在，真实 local 文件忽略 |
| 10 | 更新根 README | 指向 docs 和验证命令 |
| 11 | 执行 S1 验证 | 输出通过、失败或未执行原因 |

S1 不实现匿名 `/api/system/health`，也不开放 Actuator 详细信息或其他管理端点。受权限保护的系统健康明细属于 S2，生产依赖和脚本退出码属于 S6。

## 8. 默认验证命令

| 验证 | 命令 | 说明 |
| --- | --- | --- |
| 后端快速构建 | `scripts/mvn.ps1 -pl vibe-starter -am -DskipTests package` | 在仓库根目录执行，脚本内部切换到 `backend/` |
| 后端完整验证 | `scripts/mvn.ps1 -pl vibe-starter -am test` | 测试就绪后执行 |
| 前端构建 | `npm run build` | 在 `frontend/` 下执行 |
| 环境诊断 | `scripts/doctor.ps1` | 在项目根目录执行 |
| 开发启动 | `scripts/dev-start.ps1` | 可失败，但必须给中文原因 |
| 开发停止 | `scripts/dev-stop.ps1` | 不误杀无关进程 |

如果某条命令未执行，必须记录未执行原因和补验建议。

## 9. 输出摘要要求

S1 每轮编码结束必须输出：

| 内容 | 要求 |
| --- | --- |
| 开工检查结果 | 给出 `signoffStatus`、`s1Allowed`、`launchPhraseExact`、`sourceDirsBefore` 和失败处理结论 |
| 变更文件 | 列出新增和修改的文件 |
| AI 使用准入卡 | 给出 `admissionCard.result`，并说明编码许可、任务阶段、执行入口、上下文、风险、验证和生产边界 |
| 完成任务 | 对照本文第 7 节标记完成项 |
| 未完成任务 | 说明原因 |
| 验证结果 | 命令、状态、摘要 |
| 风险 | 是否存在依赖下载、环境、脚本、构建问题 |
| 越界检查 | 明确说明没有实现 S2-S7 功能 |
| 阶段关闭证据包 | 对照 `docs/post-coding-change-control.md` 和 `docs/quality-gates.md`，给出阶段标识、启动依据、交付物清单、验证结果、越界检查、文档同步、残余风险和下一阶段请求 |

S1 阶段关闭证据包的最低要求：

| 证据项 | S1 要求 |
| --- | --- |
| 阶段标识 | `S1 工程骨架` |
| 启动依据 | `docs/coding-start-signoff.md` 已签收，且维护者给出精确启动口令 |
| 交付物清单 | 对照 `docs/s1-task-breakdown.md` 第 7 节逐项标记完成、未完成或不适用 |
| 验证结果 | 至少记录后端快速构建、前端构建、`scripts/doctor.ps1` 的执行状态或未执行原因 |
| 越界检查 | 明确未实现登录权限、模型调用、AI 工作台、代码生成、客户拜访记录、生产安装包、P2/P2+ 模块和冻结外依赖 |
| 文档同步 | 说明是否更新根 README、docs 文档、质量门禁或任务分解 |
| 残余风险 | 列出环境、依赖下载、未执行验证、脚本限制或需要人工复核的事项 |
| 下一阶段请求 | 只能写“申请进入 S2”或“无”，不得写成 S2 已授权 |

## 10. 失败处理

| 失败 | 处理 |
| --- | --- |
| Maven 构建失败 | 停止推进后续后端任务，先修复 POM 或模块依赖 |
| npm 安装失败 | 检查 `.npmrc` 和 Node/npm 版本 |
| 前端构建失败 | 修复 TypeScript/Vite 错误后重跑 |
| doctor 失败 | 输出中文原因，不用静默跳过 |
| dev-start 失败 | 写日志，说明失败步骤和下一步 |
| S1 开工检查失败 | 停止创建或修改源码目录，只输出失败字段、原因和应修订文档 |
| 发现需要新增依赖 | 先更新 ADR 或产品约束，不直接添加 |
| 发现新增请求超出 S1 | 按 `docs/post-coding-change-control.md` 标记 C2-C4，先暂停编码并修订文档 |

## 11. 一句话总结

S1 工作令只有一个目的：让第一轮编码把地基搭稳，不偷跑业务、不偷跑 AI、不偷跑生产包。工程能构建、能启动、能诊断，才进入 S2。
