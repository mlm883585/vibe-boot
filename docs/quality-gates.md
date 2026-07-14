# Vibe Boot 质量门禁与验证规格

## 1. 文档目的

本文定义 Vibe Boot 从工程骨架、基础后台、模型网关、AI 工作台、代码生成、Windows 开发包到生产安装包的质量门禁和验证规则。

质量门禁的目标不是追求复杂测试体系，而是防止“AI 生成了文件，但系统跑不起来”的假完成。后续人工编码和 AI 生成代码都必须以本文作为验证入口。

本文定义的是验证标准和失败处理，不是开工许可。即使本文所有门禁已经成文，未完成 `docs/coding-start-signoff.md` 签收且没有维护者启动口令前，仍不得创建源码目录或开始 S1 编码。

## 2. 核心原则

| 原则 | 说明 |
| --- | --- |
| 能跑优先 | 每个阶段都必须能被命令或人工步骤验证 |
| 失败显式 | 编译、构建、脚本、模型、安装失败都必须给中文原因 |
| 不假装通过 | 未执行验证必须说明原因，不能写成已通过 |
| 先授权后验证 | 先按 `docs/post-coding-change-control.md` 判断 C0-C4 和阶段授权，再执行验证 |
| 验证不改变范围 | 构建或测试通过不代表跨阶段能力、未签收任务、新依赖或生产高风险动作被接受 |
| 小步验证 | 每次 AI 变更后优先跑最小相关验证 |
| Windows 优先 | P0 验证命令和脚本必须在 Windows PowerShell 下可用 |
| 门禁分级 | 不同阶段使用不同验证强度，避免一开始过重 |
| 契约不漂移 | JSON Schema、标准样例、Markdown 内嵌副本、API 字段和逻辑 DDL 必须做机器化一致性检查，不能靠人工目测宣称同步 |

## 3. 验证命令总表

| 场景 | 命令 | P0/P1 | 说明 |
| --- | --- | --- | --- |
| 后端完整验证 | `scripts/mvn.ps1 -pl vibe-starter -am test` | P0 | ADR-0002 默认后端验证命令；受控 Maven 3.8.x 和国内/企业镜像 |
| 后端快速构建 | `scripts/mvn.ps1 -pl vibe-starter -am -DskipTests package` | P0 | 仅用于编码中的快速反馈；不能关闭 S2-S7，也不能替代完整验证 |
| 前端验证 | `npm run build` | P0 | 任意生成 Vue 页面后必须可构建 |
| Windows 诊断 | `scripts/doctor.ps1` | P0 | 检查 JDK、Maven、Node、MySQL、Redis、端口、镜像 |
| 开发启动 | `scripts/dev-start.ps1` | P0 | 启动开发模式 |
| 开发停止 | `scripts/dev-stop.ps1` | P0 | 停止开发模式 |
| 生产打包 | `scripts/build-prod.ps1` | P1 | 生成 Windows 安装包 |
| 生产安装 | `scripts/install.ps1` | P1 | 安装生产服务 |
| 生产状态 | `scripts/status.ps1` | P1 | 检查服务状态和健康检查 |
| 备份恢复 | `scripts/backup.ps1`、`scripts/restore.ps1` | P1 | 验证数据、文件、配置备份恢复 |

如果工程骨架初期模块名尚未创建，`vibe-starter` 作为目标模块名保留。

## 4. 阶段门禁

| 阶段 | 必须通过 | 可暂缓 | 不通过处理 |
| --- | --- | --- | --- |
| S1 工程骨架 | 后端快速构建、前端构建、doctor 基础检查、Actuator liveness/readiness 最小暴露和回环限制 | 后端完整测试 | 阻止进入 S2 |
| S2 基础后台 | 后端完整测试、关键 MockMvc/API 测试、登录/菜单/权限/用户角色/日志/文件服务真实 MySQL 8 验证、前端构建 | 浏览器 E2E 自动化 | 不能宣称基础后台完成 |
| S3 模型网关 | 后端完整测试、模型配置/密钥/SSRF/限流/连接测试/用量记录正反 API 用例、前端构建 | 流式响应 | 不能启用 AI 工作台生成流程 |
| S4 AI 工作台与生成闭环 | 后端完整测试、元模型 Schema/语义/模板/冲突单测、关键 API 测试、干净 MySQL 8 Flyway、前端构建、客户拜访数据隔离；交接包字段完整且写入仅限开发工作区 | 自动回滚 | 不能标记生成任务 completed |
| S5 Windows 开发包 | doctor/dev-start/dev-stop 可用，日志落盘；首次使用路径可引导用户配置模型并进入工作台 | 完整安装包 | 不能作为开发发行包 |
| S6 生产包 | build-prod/install/status/health、敏感备份、同版本恢复和升级失败整套回滚演练可用 | 自动数据库回滚、备份内置加密 | 不能作为生产交付包 |
| S7 演示 | 客户拜访记录端到端通过；企业用户路径、交接包、受控发布通道和生产业务 AI 边界可被演示证据证明 | 更多业务模块 | 不能宣称 MVP 闭环通过 |

## 5. AI 生成后的门禁

每次 AI 生成或修改代码后必须形成验证摘要。

验证摘要必须同时包含变更分级结论。缺少 C0-C4 判断的验证结果，只能证明命令曾经执行，不能证明任务可以合入或阶段可以推进。

| 字段 | 要求 |
| --- | --- |
| changeLevel | C0/C1/C2/C3/C4 |
| authorizationBasis | 签收记录、阶段启动指令、任务文档或文档同步说明 |
| scopeDecision | 可继续、需补文档、需补 ADR、默认拒绝 |
| verificationStatus | passed/failed/skipped |

| 变更类型 | 最小验证 | 补充验证 |
| --- | --- | --- |
| 仅文档 | Markdown 引用检查或人工检查 | 无 |
| 后端 Java | 编码中可先快速构建；任务完成前必须执行 `scripts/mvn.ps1 -pl vibe-starter -am test` | 相关 Service/Controller/MockMvc 测试 |
| 前端 Vue/TS | `npm run build` | 页面人工预览 |
| SQL/Flyway | 后端启动或迁移执行检查 | 开发库 dry-run |
| 权限/菜单 | 登录后菜单和按钮权限检查 | 接口 403 检查 |
| Windows 脚本 | PowerShell 执行脚本 dry-run 或实际运行 | 日志文件检查 |
| 生产包 | `build-prod.ps1` + `install.ps1` | 新 Windows 环境验证 |

未能执行验证时，AI 必须输出：

| 内容 | 说明 |
| --- | --- |
| 未执行命令 | 哪些命令没跑 |
| 未执行原因 | 缺少环境、耗时过长、依赖服务未启动等 |
| 风险影响 | 这会影响哪些结论 |
| 建议补验 | 用户或后续任务应运行什么 |

## 6. 测试分层

| 类型 | P0/P1 | 目标 |
| --- | --- | --- |
| 单元测试 | P0 少量 | 工具类、ID、脱敏、规则检查、生成器核心逻辑 |
| Spring Boot 测试 | P0 | 登录、权限、模型配置、核心 Controller |
| MockMvc/API 测试 | P0 | 登录、用户、角色、菜单、模型配置、AI 任务、生成任务、客户拜访记录等关键接口 |
| 数据库测试 | P0 本地 MySQL，P1 Testcontainers | 避免 H2 掩盖 MySQL 方言差异 |
| 前端单测 | P1 | request、权限、字典等工具函数 |
| E2E 测试 | P1/P2 | 登录、生成、预览、安装等端到端流程 |

P0 不追求覆盖率百分比，但关键链路必须有自动化正反用例。S2-S4 的后端完整测试、关键 MockMvc/API 测试和真实 MySQL 8 集成验证任一 skipped/failed，阶段均不得关闭；外部模型只允许使用本地可控 stub 验证协议和错误映射，阶段测试不得依赖公网模型稳定性。

## 7. 失败处理

验证失败不能被包装成“部分成功”。任务状态和摘要必须如实反映。

| 失败类型 | 处理 |
| --- | --- |
| 编译失败 | 标记 failed，输出失败模块、关键错误、可能原因 |
| 测试失败 | 标记 failed，输出失败测试和断言摘要 |
| 前端构建失败 | 标记 failed，输出 TypeScript/Vite 错误摘要 |
| Flyway 失败 | 停止后续安装或启动，提示检查迁移版本和 SQL |
| 脚本失败 | 输出脚本名、步骤、日志路径、修复建议 |
| 模型调用失败 | 输出 AI 错误码、中文解释、是否可重试 |
| 安装失败 | 不启动半成品服务，提示恢复或清理步骤 |

失败摘要必须包含 `traceId`、日志路径或命令输出位置中的至少一种定位方式。

## 8. 验证结果格式

AI 工作台、脚本和发布摘要应使用统一结构。

| 字段 | 说明 |
| --- | --- |
| status | passed/failed/skipped |
| command | 执行命令 |
| workingDirectory | 执行目录 |
| startedAt | 开始时间 |
| durationMs | 耗时 |
| summary | 中文摘要 |
| logPath | 日志路径 |
| nextAction | 下一步建议 |

示例：

```json
{
  "status": "failed",
  "command": "npm run build",
  "workingDirectory": "frontend",
  "durationMs": 18231,
  "summary": "前端构建失败：customerVisit.ts 中缺少导出的类型 CustomerVisitVO。",
  "logPath": "logs/scripts/frontend-build-20260628-153000.log",
  "nextAction": "补充类型定义后重新执行 npm run build。"
}
```

## 8.1 阶段关闭证据包

每个阶段完成时，必须输出阶段关闭证据包。质量门禁通过只是其中一项证据，不能单独证明阶段完成，也不能自动启动下一阶段。

| 字段 | 要求 |
| --- | --- |
| stage | S1-S7 |
| stageName | 阶段名称 |
| authorizationBasis | 签收记录、阶段启动指令或维护者协作记录 |
| deliverables | 对照阶段任务分解列出的交付物清单 |
| verificationResults | 命令、状态、日志路径、失败原因或未执行原因 |
| scopeCheck | 是否提前实现后续阶段、是否新增冻结外依赖、是否触碰生产禁区 |
| docsSync | README、阶段任务、质量门禁、签收材料是否需要同步 |
| residualRisks | 剩余风险、暂缓项、人工复核项 |
| nextStageRequest | 如需进入下一阶段，只能记录为请求，不得写成已授权 |

阶段关闭证据包的最低判定：

| 判定 | 处理 |
| --- | --- |
| 交付物缺失 | 阶段不得关闭 |
| 必需验证失败 | 阶段不得关闭 |
| 验证未执行且无合理原因 | 阶段不得关闭 |
| 发现越界实现 | 按 C2-C4 回到文档、ADR 或安全设计 |
| 文档未同步 | 先完成文档同步，再申请关闭 |
| 只有下一阶段请求 | 不能作为下一阶段启动许可 |

## 9. S1 工程骨架门禁

S1 门禁只在 S1 已经签收并获得启动口令后用于验收工程骨架；它不授权在未签收状态下创建 `backend/`、`frontend/`、`scripts/` 或 `config/`。

| 门禁 | 标准 |
| --- | --- |
| S1 阶段准入与开工检查 | 精确口令后先写 **docs/stage-records/S1-admission.md**；创建源码目录前输出 `signoffStatus`、`s1Allowed`、`launchPhraseExact`、`stageAdmissionPath`、`sourceDirsBefore`、`allowedScope`、`forbiddenScope` 和 `admissionCard.result`；任一失败不得编码 |
| AI 使用准入卡 | S1 开工和输出摘要必须包含 `admissionCard` 结论，且 `result=pass` 不能替代签收记录和启动口令 |
| S1 阶段关闭证据包 | S1 输出摘要必须包含阶段标识、启动依据、交付物清单、验证结果、越界检查、文档同步、残余风险和下一阶段请求；不得自动授权 S2 |
| 后端模块存在 | `backend/` 下 Maven 多模块结构创建 |
| 后端可构建 | 快速构建通过 |
| 前端可安装 | `npm install` 使用国内镜像可完成 |
| 前端可构建 | `npm run build` 通过 |
| doctor 可运行 | 输出 JDK、Maven、Node、npm、端口、目录权限检查 |
| README 可用 | 明确开发启动和验证命令 |

S1 不要求完整登录和权限业务，避免工程骨架阶段过早膨胀。

## 10. S2 基础后台门禁

| 门禁 | 标准 |
| --- | --- |
| 登录成功 | 管理员能登录首页 |
| 登录失败 | 错误密码返回中文错误并记录登录日志 |
| 初始管理员安全 | 生产初始化不含公开固定密码；`password_reset_required=true` 时只能访问改密、登出和当前用户基础信息 |
| 密码存储 | 使用 PBKDF2-HMAC-SHA256/600000 次、独立 salt 和自描述格式；禁止快速摘要、可逆加密和明文 |
| 密码策略 | 支持 15-128 Unicode code point、NFC 和密码管理器；弱密码表生效，不强制字符组合或定期改密 |
| 登录防爆破 | 账号/IP 双维度 Redis 限流、`AUTH_0429`、`Retry-After` 和未知账号虚拟密码校验可验证 |
| Cookie 会话 | 不透明 Token 只在 Redis 和 Host-only/HttpOnly/SameSite=Strict Cookie；响应体和 Web Storage 中无 Token |
| CSRF/Origin | 登录校验同源 Origin；已登录写请求缺失或伪造 `X-CSRF-Token` 时被拒绝 |
| 会话生命周期 | 绝对 8 小时、空闲 30 分钟、最多 3 会话；登出、改密、重置、禁用和删除的失效语义可验证 |
| 菜单权限 | 不同角色看到不同菜单 |
| 接口权限 | 无权限访问返回 `AUTH_0403` |
| 用户角色 | 用户可分配角色，角色可分配菜单 |
| 字典配置 | 字典类型和字典项可维护 |
| 操作日志 | 新增、修改、删除、重置密码有日志 |
| 数据权限基础 | 数据范围枚举、当前用户上下文、部门树、查询扩展点和未接入说明可验证 |
| 审计详情 | 操作日志详情包含 traceId、操作人、路径、目标对象、状态和脱敏错误摘要 |
| 请求追踪 | 业务响应体和 `X-Trace-Id` 一致，MDC 日志可定位同一请求；客户端 traceId 不能覆盖服务端生成值 |
| 乐观锁 | 两个会话编辑同一可编辑主记录，后提交者收到 `DATA_0409`，先提交内容不被覆盖 |
| 唯一约束 | 并发创建相同用户名、角色编码、权限标识或字典编码时，数据库只保留一份，冲突稳定映射为 `DATA_0409` |
| 关系幂等 | 重复保存用户角色或角色菜单目标集合，不产生重复关系且最终集合一致 |
| 事务回滚 | 写操作中途抛出运行时异常时数据库不保留半成品；模型、HTTP 和文件 I/O 不占用长事务 |
| 文件范围 | S2 只实现本地文件基础服务，不提前做业务附件、Office 在线预览、分片上传或 MinIO/OSS |
| 文件上传限制 | 单文件 20 MB、请求 25 MB、默认配额 10 GB、保留空间 2 GB；流式超限和磁盘不足使用稳定错误码 |
| 文件类型安全 | 扩展名、MIME、magic bytes/UTF-8 内容三重一致；危险类型、伪装类型和零字节文件被拒绝 |
| 文件路径安全 | 用户文件名和请求参数不能控制磁盘路径，normalize 后必须仍在 storage root 内，API 不返回内部路径 |
| Windows 文件目录 | storage root 不含符号链接/junction/reparse point，生产 ACL 只允许服务账号和管理员写入 |
| 文件访问安全 | 下载和图片预览必须鉴权；无静态映射、公开直链，响应包含 nosniff 和安全 Content-Disposition |
| 文件删除恢复 | active/failed 两阶段删除、delete_failed 重试、重复删除幂等和审计记录可验证 |
| 文件中断恢复 | 模拟上传中进程退出后，重启会把超过 1 小时的 uploading 标记 failed 并处理临时文件，不自动变成 active |
| 文件风险说明 | P0 不宣称病毒扫描，不自动把上传文件放入 AI 上下文 |
| 自动化验证 | `scripts/mvn.ps1 -pl vibe-starter -am test`、S2 关键 MockMvc/API 测试、真实 MySQL 8 集成用例和 `npm run build` 全部通过；快速构建不得替代 |

## 11. S3 模型网关门禁

| 门禁 | 标准 |
| --- | --- |
| 配置保存 | OpenAI 兼容模型配置可保存 |
| 密钥加密与响应最小化 | API Key 按 ADR-0002 使用 AES-GCM 密文入库；主密钥外置；前端只看到 `credentialConfigured`；错误主密钥返回 `AI_0503` |
| 连接测试成功 | 有效配置返回中文成功提示 |
| 连接测试失败 | 错误配置返回中文错误 |
| 用量记录 | 成功和失败调用都记录 |
| 限流配额 | 单次 maxTokens、每分钟限流、每日调用/token 上限可配置，超限返回 `AI_0428` 或 `AI_0430` |
| 用量摘要 | 用量页面能展示今日调用、token、失败次数和配额状态；token 未返回时明确显示未知 |
| 权限控制 | 无权限用户不能修改模型配置 |
| 生产限制 | 生产产物中不存在开发型页面/API/路由/任务处理器；`vibe.ai.dev-tools-enabled=false` 仅为防御性构建标记，配置为 true 必须启动失败且不能恢复缺失代码 |
| 数据最小化 | secret 数据阻断，sensitive 数据脱敏或确认，生产业务数据先经过权限和数据范围过滤 |
| 出境提示 | 境外或未知供应商在配置和调用前有中文风险提示 |
| SSRF 与出站安全 | API Base URI 校验、生产公网 HTTPS、开发仅回环 HTTP、DNS 复检、禁止地址、禁止重定向、TLS 主机名校验和 2 MB 响应上限均有正反用例 |
| 自动化验证 | `scripts/mvn.ps1 -pl vibe-starter -am test`、模型网关关键 MockMvc/API 与本地 stub 正反用例、真实 MySQL 8 持久化用例和 `npm run build` 全部通过；不得调用公网模型作为阶段通过依据 |

## 12. S4 AI 工作台与代码生成门禁

以客户拜访记录模块作为 P0 标尺。

| 门禁 | 标准 |
| --- | --- |
| 元模型确认 | `docs/contracts/codegen-meta-model-v1.schema.json` 结构校验、跨字段语义校验、规范化 hash 及字段/权限/页面/数据范围确认均通过 |
| 文档机器契约 | 两个 Draft 2020-12 Schema 均通过 strict 校验，两个标准样例通过对应 schema；安装 Schema/样例与 `release-package-design.md` 内嵌 JSON 归一化相等，API 分页字段和 P0 DDL 静态扫描无旧口径 |
| 外部 AI 交接包 | 任务阶段、业务目标、澄清结论、允许范围、禁止事项、风险等级、AI 使用准入卡、验证命令和输出格式齐全 |
| 开发工作区应用边界 | 补丁或文件写入只允许在开发工作区发生，生产环境不得应用代码补丁、执行任意 shell 或直接改表 |
| 文件预览 | 展示 Java、Vue、SQL、菜单、文档产物 |
| SQL 迁移 | Flyway 文件存在，表和字段有注释 |
| 后端验证 | `scripts/mvn.ps1 -pl vibe-starter -am test` 全部通过；包含 Schema/语义/模板/冲突、工作台与生成任务 API、客户拜访 CRUD 和数据隔离正反用例，快速构建不得替代 |
| 前端验证 | 生成后 `npm run build` 通过 |
| 迁移验证 | 在全新 MySQL 8 schema 和支持升级基线上分别运行同一 Jar preflight/migrate，Flyway 成功且生成表、索引、约束与元模型一致 |
| 权限菜单 | 菜单和按钮权限可见且后端强校验 |
| 数据范围实现 | 客户拜访记录必须接入 S2 数据权限扩展点并通过销售 A/销售 B/销售主管隔离测试；声明限制不能替代通过 |
| 二次生成安全 | 人工修改文件不会被静默覆盖，冲突必须展示 |
| 可维护性扫描 | 生成结果不得包含 TODO 占位、硬编码 API Base、无权限按钮、未版本化 SQL 或不可解释脚本 |
| Lombok 扫描 | P0 后端源码和生成结果不得包含 Lombok 依赖或 `@Data`、`@Getter`、`@Setter`、`@Builder` 等注解 |
| 摘要完整 | 输出变更文件、验证结果、风险和下一步 |

## 13. S5 Windows 开发包门禁

| 门禁 | 标准 |
| --- | --- |
| 解压可用 | 使用相对路径，不依赖全局 JDK/Maven/Node |
| doctor | 输出中文诊断报告 |
| dev-start | 启动后端、前端和必要开发服务 |
| dev-stop | 能停止由开发包启动的服务 |
| 国内镜像 | Maven/npm 默认使用国内镜像或明确可配置 |
| 网络模式 | doctor 能说明 online/mirror/intranet 当前模式、镜像地址、可达性和缓存缺失风险 |
| runtime manifest | doctor 能读取 JDK/Maven/Node/npm runtime 清单，版本异常时给中文提示 |
| 第三方 NOTICE | doctor 能检查 runtime 和预置工具的来源、许可证摘要与 `THIRD-PARTY-NOTICES` 是否存在 |
| 日志落盘 | 脚本和应用日志写入 `logs/` |
| 模型配置向导 | 未配置模型时提示用户配置 |
| 首次使用引导 | 用户能从脚本输出或管理端入口知道下一步应读取文档、配置模型、打开 AI 工作台并生成任务 |

## 13.1 AI 使用路径门禁

AI 使用路径产品化不是文案完成就算通过，必须在工作台、脚本或演示证据中可验证。

| 门禁 | 适用阶段 | 标准 |
| --- | --- | --- |
| 首次使用路径 | S5/S7 | 新用户按提示能完成环境检查、模型配置、打开工作台、创建任务 |
| 企业用户路径 | S4/S7 | 企业用户只需确认业务、澄清和风险，不要求直接理解源码目录 |
| 外部 AI 交接包 | S4/S7 | 交接包可复制给外部 AI Coding 工具，且包含阶段、范围、禁止事项、风险、AI 使用准入卡和验证命令 |
| AI 使用准入卡 | S1/S4/S7 | 每个交接包、开工检查和执行摘要必须明确编码许可、任务阶段、执行入口、上下文、风险、验证和生产边界结论 |
| 开发工作区执行 | S4/S7 | P0 通用补丁只由外部 AI Coding 工具承接；确定性生成器只写声明 owned 的路径；P1 本地受控执行器不得伪装为 P0 |
| 能力成熟度边界 | S4/S7 | A0-A2 可用，A3-A4 如未实现必须标明为 P1，完整内置 Agent IDE 不得伪装为已实现 |
| 生产边界 | S6/S7 | 生产模式不得出现代码编辑、补丁应用、任意 shell 或在线改表入口 |
| 生产 AI 白名单 | S6/S7 | 生产模型配置只允许业务问答、摘要、分类、文案、分析和连接测试，不得恢复外部 AI 交接包执行、代码生成补丁、源码读取、文件写入、shell 或在线 SQL |
| 模型数据安全 | S3/S4/S7 | 模型调用前必须有数据分类、最小化、脱敏策略、出境风险提示和审计记录 |

AI 工作台验收时还必须证明角色、状态和交接动作没有混在一起。

| 检查项 | 适用阶段 | 通过标准 |
| --- | --- | --- |
| 角色入口可区分 | S4/S7 | 企业管理员、实施人员、Java 开发者和生产用户的默认入口、可见信息和禁止动作不同，至少在任务详情中明确展示 |
| 状态机可追踪 | S4/S7 | 主路径 draft、clarifying、planned、waiting_confirm、handoff_ready、executing_external、verifying、completed 可追踪；failed/blocked/cancelled/reverted 分支有合法入口，`confirmed` 不得作为状态 |
| 确认不等于授权泛化 | S4/S7 | 用户确认计划只授权本任务、本阶段、本范围；不能被解释为允许跨阶段、生产执行或任意高风险操作 |
| 交接包不是执行器 | S4/S7 | P0 交接包只能复制给外部 AI Coding 工具，不得在平台服务端或生产环境直接运行；未来 P1 执行器需另行 ADR |
| 完成态包含证据 | S4/S7 | completed 状态必须包含变更摘要、验证结论、风险摘要和下一步；缺一项只能为 failed、blocked 或 waiting_confirm |

## 13.2 Skills/规则门禁

Skills/规则门禁用于证明 AI 任务不是裸模型输出，而是在可版本、可追溯、可阻断的规则体系下运行。

| 门禁 | 适用阶段 | 标准 |
| --- | --- | --- |
| active 规则加载 | S4/S7 | 任务只能把 `active` 规则作为强制规则加载，`draft/deprecated` 不能阻断或放行任务 |
| 规则快照 | S4/S7 | 任务必须保存 `skillSnapshot`、`ruleSnapshot`、`contextSnapshot` 和 `resolutionTrace` |
| 规则来源 | S4/S7 | 每条强制规则必须能追溯到产品约束、ADR、阶段文档或质量门禁 |
| 冲突裁决 | S4/S7 | 规则冲突必须有 block、ask_first、warn、verify 或 document 结论 |
| 阻断生效 | S4/S7 | 违反 active must/must-not 规则时，不得生成可执行交接包、补丁或发布动作 |
| 规则变更受控 | S4/S7 | 降低安全级别、放宽生产边界、扩大编码授权或改变技术栈必须先修订文档和 ADR |
| 审计可读 | S4/S7 | 工作台或任务详情必须展示阻断项、警告项和中文裁决原因 |

## 14. S6 生产安装包门禁

| 门禁 | 标准 |
| --- | --- |
| 构建成功 | 干净 Git 基线生成版本化 zip 与包外 `.sha256`；脏工作区不得生成生产包 |
| 包信任 | 全部 PowerShell 和 `PACKAGE-MANIFEST.psd1` Authenticode 有效，signer 与带外 thumbprint 一致，清单覆盖包内文件；未签名测试包被生产安装拒绝 |
| 不含密钥 | local 配置、模型凭据主密钥、API Key、数据库密码不进入默认包 |
| 配置边界扫描 | 源码仓库只允许提交模板/example；真实 `application-local.yml`、`model-local.yml`、`application-prod.yml`、`model-prod.yml`、`install.json` 不得包含真实密钥并进入 Git；生产 profile 检测到环境变量或 YAML 内嵌模型主密钥必须失败 |
| 合规清单 | `notices/RUNTIME-MANIFEST.json`、`notices/DEPENDENCY-MANIFEST.json`、`notices/THIRD-PARTY-NOTICES.txt` 齐全，版本、来源、许可证和交付产物 SHA256 可追踪 |
| 迁移源一致 | classpath 权威源、jar 内资源、`db/migration/` 审计副本和 `db/MIGRATION-MANIFEST.json` 哈希一致 |
| 迁移执行唯一 | 只有同一 Jar 的一次性 migrate 维护模式内 Flyway 执行；常驻服务禁用 Flyway，PowerShell 不执行 SQL/Flyway CLI，审计副本不能作为输入 |
| 可安装 | `install.ps1` 完成签名/JSON/secret 预检、一次性 migrate、bootstrap-admin、服务 ACL 和启动，readiness 为 `UP` |
| 安装预检 | 任何写盘、服务和数据库动作前完成 signer/package manifest；数据库写入前再完成端口、MySQL 双账号、Redis ACL/TLS、磁盘、迁移和 AI 白名单检查 |
| 服务身份与 ACL | Procrun 固定 LocalService + service SID；安装根及每个子目录关闭继承并写显式 ACE；普通用户和服务进程不能修改 app/runtime/service/scripts/notices/db/config/operations，secrets 只允许 service SID/SYSTEM/Administrators 读取，`operations/` 必须是 `data/` 的兄弟目录 |
| 数据最小权限 | 常驻 MySQL 账号只有 DML、迁移账号只进一次性子进程；Redis 只能访问实例前缀与 allowlist 命令；非回环连接强制 TLS |
| 初始管理员 | Flyway 不含密码；bootstrap-admin 只从 stdin 接收初始密码，事务创建 admin 并设置强制改密，重复初始化被拒绝 |
| 健康分层 | liveness 只检查进程；readiness 检查生产 MySQL、Redis、文件目录和迁移状态；模型供应商故障不得阻断基础 readiness |
| 健康访问边界 | Actuator 只监听 `127.0.0.1:8081` 且只暴露 health；业务端口不暴露 Actuator；`/api/system/health` 要求 `system:health:info` 权限并返回脱敏明细 |
| 健康响应 | Actuator 使用标准摘要和 200/503；系统接口使用统一响应和 `HEALTHY/DEGRADED/UNAVAILABLE` 三态 |
| 健康版本 | Maven build info、系统健康接口 version 和生产包 `app/VERSION` 完全一致 |
| 状态脚本 | `status.ps1` 对服务、liveness、readiness、配置错误和响应异常使用固定退出码 `0/10/11/12/20/21/30/31` |
| 启动门禁 | start/install/upgrade/restore 只有 readiness 在默认 60 秒内达到 `UP` 才能成功 |
| 生产访问模式 | local 只绑定 127.0.0.1；lan 必须启用 HTTPS、校验 PKCS12/主机名并配置精确 allowedOrigin，LAN HTTP 必须阻断 |
| 防火墙边界 | 默认不新增规则；显式开启时只存在产品自有 HTTPS 业务端口规则，8081/MySQL/Redis 未被安装器开放 |
| 外部数据服务责任 | 安装器不下载、安装、升级或卸载 MySQL/Redis；缺少外部服务、权限或兼容 MySQL Client 时预检中文失败 |
| 可停止启动 | start/stop/status 可用 |
| 可卸载 | uninstall 默认保留数据 |
| 可备份 | backup 包含数据库、文件、非敏感配置和版本；`config/secrets/**`、模型主密钥、密码和私钥全部排除 |
| 备份一致性 | 服务停止后创建备份；manifest 包含类型、完整产品版本、迁移版本、模型主密钥指纹、相对路径、大小和 SHA256，不含 secret、配置值或业务摘要 |
| 备份敏感边界 | 备份继承受限 ACL，不进入 Git、AI 上下文、日志附件、默认生产包或公开共享目录；P0 不宣称内置加密 |
| 可恢复 | restore 可恢复同一完整版本测试备份；校验模型密钥指纹，支持显式丢弃模型凭据，并在启动前清空本实例 Redis 会话/缓存；保护性备份失败不得继续 |
| 升级回滚 | 只运行已验证目标包脚本；同卷 staging、state v2 九资源子状态、全局 phase、maintenance.flag、migrationStarted 和支持升级路径可判定；迁移开始后用同一次回滚点整套恢复并清空 Redis |
| 生产 AI 白名单 | 模型配置成功不代表开发型 AI 开启；生产包不得出现开发需求澄清、项目文档问答、代码变更计划、代码生成、补丁、交接包执行、源码、命令或在线 SQL 入口 |
| 受控发布通道 | 生产变更只能来自 `build-prod.ps1` 产物、`install.ps1`/`upgrade.ps1` 和版本化迁移，不能通过复制源码、复制开发库、执行交接包、手工 SQL 或 shell 进入生产 |

## 15. 编码准入

进入编码实现前必须确认：

以下条件满足只表示质量标准已定义，不表示自动允许编码。编码许可仍以 `docs/coding-start-signoff.md` 和启动口令为准。

| 条件 | 状态 |
| --- | --- |
| 验证命令 | 已由 ADR-0002 和本文确认 |
| 阶段门禁 | 已由本文确认 |
| AI 生成后验证 | 已由本文确认 |
| 失败处理 | 已由本文确认 |
| Windows 开发包门禁 | 已由本文和 `docs/windows-devkit-design.md` 确认 |
| 生产安装包门禁 | 已由本文和 `docs/release-package-design.md` 确认 |
| AI 使用路径门禁 | 已由本文和 `docs/ai-tool-usage-guide.md` 确认 |
| Skills/规则门禁 | 已由本文和 `docs/skill-rule-design.md` 确认 |
| 开源合规门禁 | 已由本文、`docs/product-constraints.md`、`docs/windows-devkit-design.md` 和 `docs/release-package-design.md` 确认 |
| 模型数据安全门禁 | 已由本文、`docs/security-governance.md`、`docs/model-gateway-spec.md` 和 `docs/ai-workbench-task-breakdown.md` 确认 |

## 16. 一句话总结

Vibe Boot 的质量门禁只服务一个目标：让每次人工编码和 AI 生成都能被验证、被解释、被追踪，确保系统不是“看起来生成了”，而是真的能编译、能启动、能安装、能运行。
