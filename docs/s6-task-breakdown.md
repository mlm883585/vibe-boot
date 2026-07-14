# Vibe Boot S6 生产安装包任务分解

## 1. 文档目的

本文把 `docs/release-package-design.md` 拆解为可执行的 S6 编码任务，明确生产安装包的构建、安装、启停、状态检查、备份、恢复、升级、回滚和安全边界。

S6 的目标是把开发模式下由 AI 和人工生成的代码，变成可复制到 Windows 服务器、可安装、可运行、可维护的生产系统。S6 不运行源码开发环境，不启用开发型 AI 能力。

## 2. S6 总目标

| 目标 | 验收口径 |
| --- | --- |
| 生产包可构建 | `build-prod.ps1` 生成 zip 安装包 |
| 生产包不含密钥 | local 配置、模型凭据主密钥、API Key、数据库密码不进入默认包 |
| 生产包有合规清单 | `RUNTIME-MANIFEST`、依赖 manifest 和 NOTICE 随包生成并可校验 |
| 生产包可安装 | `install.ps1` 完成签名/配置预检、一次性 Jar migrate、管理员初始化、服务 ACL 和启动；常驻服务不持有 DDL 权限 |
| 安装前可预检 | `install.ps1` 在注册/启动服务和任何数据库写入前输出权限、端口、数据库、Redis、磁盘、迁移和生产 AI 白名单检查 |
| 服务可管理 | `start.ps1`、`stop.ps1`、`status.ps1` 可用 |
| 数据可备份 | `backup.ps1` 备份数据库、文件、配置和版本信息 |
| 数据可恢复 | `restore.ps1` 可恢复测试备份，且有二次确认 |
| 升级可回退 | `upgrade.ps1` 停服后创建整套回滚点；迁移或健康检查失败时保持停服并执行受控恢复 |
| 生产安全明确 | 不打包代码生成、脚本执行、数据库结构在线修改和外部 AI 交接包执行入口 |
| 发布通道唯一 | 生产只接受受控安装包、安装/升级脚本和版本化迁移，不接受复制源码、交接包执行或手工 SQL |

## 3. 前置条件

| 前置项 | 要求 |
| --- | --- |
| S1-S5 | 工程、基础后台、模型网关、AI 工作台、代码生成、开发包已具备基础能力 |
| 阶段签收与启动 | S5 阶段关闭证据已通过，`stageAdmission` 记录完整，并收到精确口令 `开始 S6 生产安装包编码`；本文本身不是当前编码许可 |
| 后端构建 | Maven 可生成生产 jar |
| 前端构建 | npm 可生成静态资源 |
| Flyway | classpath 权威迁移已打入 jar，且只由应用启动阶段执行 |
| 健康检查 | Actuator liveness/readiness、系统健康接口权限和脚本退出码已定义 |
| 安全治理 | 生产禁用开发型 AI 能力已确认 |
| 生产包设计 | `release-package-design.md` 已确认 |

## 4. 任务顺序

| 顺序 | 任务 | 主要产物 | 依赖 |
| --- | --- | --- | --- |
| 1 | 生产包目录与配置模板 | `app/`、`config/`、`runtime/`、`notices/`、`scripts/`、`db/`、`logs/`、`backup/` | S5 目录经验 |
| 2 | 构建脚本 | `scripts/build-prod.ps1` | Maven/npm 构建 |
| 3 | 安装公共脚本 | `scripts/common.ps1` | 生产脚本目录 |
| 4 | 安装脚本 | `scripts/install.ps1` | 生产配置、Procrun 1.6.1 |
| 4.1 | 安装预检 | 权限、端口、数据库、Redis、磁盘、迁移、生产 AI 白名单 | install |
| 5 | 服务启停状态脚本 | `start.ps1`、`stop.ps1`、`status.ps1` | 服务安装 |
| 6 | 卸载脚本 | `uninstall.ps1` | 服务管理 |
| 7 | 备份脚本 | `backup.ps1` | MySQL、文件、配置 |
| 8 | 恢复脚本 | `restore.ps1` | 备份产物 |
| 9 | 升级与回滚脚本 | `upgrade.ps1`、回滚说明 | 备份与安装 |
| 10 | S6 验收与文档入口 | 生产 README、质量门禁报告 | 全部生产脚本 |

## 5. 任务明细

### 5.1 生产包目录与配置模板

生产包目录：

```text
vibe-boot-release/
├── PACKAGE-MANIFEST.psd1
├── app/
├── config/
├── runtime/
├── service/
├── notices/
├── scripts/
├── db/
├── data/
├── logs/
├── backup/
├── staging/
└── README.md
```

| 路径 | 要求 |
| --- | --- |
| `app/` | jar、前端静态资源、VERSION |
| `config/` | `application-prod.yml`、`model-prod.yml`、`install.json`、`secrets/` |
| `runtime/` | JDK 17 runtime，不包含 Maven/Node |
| `notices/` | runtime manifest、依赖 manifest、NOTICE 和交付产物校验摘要 |
| `scripts/` | 生产运维脚本 |
| `db/` | jar 内迁移的只读审计副本和 `MIGRATION-MANIFEST.json`，不作为执行源 |
| `data/` | 文件数据目录 |
| `logs/` | app/install/backup 日志 |
| `backup/` | 备份归档目录 |
| `PACKAGE-MANIFEST.psd1` | Authenticode 签名的包内容、大小和 SHA256 清单 |
| `service/` | Procrun 1.6.1 x64 可执行文件；服务参数由签名安装脚本确定性注册 |
| `staging/`、`operations/` | 同卷升级暂存、可信启动器与原子状态记录，仅 Administrators/SYSTEM 可访问；不得放在服务拥有 Modify 权限的 `data/` 下 |

生产包默认不包含源码、node_modules、Maven 仓库、local 配置和密钥。

### 5.2 `build-prod.ps1`

| 步骤 | 要求 |
| --- | --- |
| 构建前检查 | Git 工作区必须干净；检查版本号、提交哈希和代码签名证书，任一不满足即阻断 |
| 后端构建 | 执行 Maven 构建，失败停止 |
| 前端构建 | 执行 npm build，失败停止 |
| 生成迁移审计副本 | 从 classpath 权威源生成 `db/migration/` 与清单，并校验源、jar、副本 SHA256 一致 |
| 生成配置 | 复制生产配置模板，不带密钥 |
| 复制 runtime | 复制 JDK 17 runtime |
| 生成合规清单 | 生成 `RUNTIME-MANIFEST.json`、`DEPENDENCY-MANIFEST.json` 和 `THIRD-PARTY-NOTICES.txt` |
| 复制脚本 | install/start/stop/status/backup/restore/upgrade/uninstall |
| 写 VERSION | 版本号、构建时间、提交哈希 |
| 签名与 package manifest | 先签名全部 PowerShell，再按其最终字节生成不自含的 `PACKAGE-MANIFEST.psd1`，随后签名 manifest 并复核 signer/哈希 |
| 压缩打包 | 输出 `VibeBoot-<version>-windows-x64.zip` 与包外发布的 `.zip.sha256` |

构建失败不得生成半成品包。

`build-prod.ps1` 是开发成果进入生产的唯一构建入口。

| 要求 | 说明 |
| --- | --- |
| 构建前验证 | 未通过必要构建或检查时不得生成生产包 |
| 产物可追踪 | VERSION 必须记录版本、构建时间和提交信息 |
| 不带开发环境 | 不包含源码、Maven、Node、node_modules、local 配置和密钥 |
| 迁移可追踪 | 唯一权威源打入 jar；审计副本和清单哈希一致，脚本不得执行 SQL/Flyway CLI |
| 合规可追踪 | `notices/RUNTIME-MANIFEST.json`、`notices/DEPENDENCY-MANIFEST.json`、`notices/THIRD-PARTY-NOTICES.txt` 必须存在 |
| 包信任可追踪 | 生产包必须有有效 Authenticode 和签名 package manifest；未签名测试包必须带标记且被生产 install/upgrade 拒绝 |
| 禁止旁路 | 不允许用复制开发目录、执行交接包或手工 SQL 替代生产包 |

### 5.3 生产公共脚本

`scripts/common.ps1` 提供：

| 能力 | 要求 |
| --- | --- |
| 路径解析 | 基于生产包根目录 |
| 日志写入 | 写入 `logs/install/` 或对应目录 |
| 中文输出 | Info/Warn/Error/Success |
| 敏感信息脱敏 | 数据库密码、Redis 密码、模型凭据主密钥、API Key、Token |
| 管理员权限检查 | 安装/卸载服务时提示 |
| 签名与清单校验 | install/upgrade 每次都要求必填 `-TrustedSignerThumbprint`；校验自身、全部脚本和 `PACKAGE-MANIFEST.psd1` 后才能写盘，不读取机器配置或环境变量替代 |
| 端口检查 | 检查生产端口占用 |
| 健康检查 | 调用 health 接口 |
| 服务名读取 | 通过 PowerShell 5.1 内置 `ConvertFrom-Json` 读取并校验 `serviceName` 严格等于 `VibeBoot`；标准 JSON 不允许注释或尾逗号，解析后拒绝未知字段 |

### 5.4 `install.ps1`

| 步骤 | 要求 |
| --- | --- |
| 权限检查 | 安装 Windows 服务时需要管理员权限 |
| 包信任 | 任何目录写入、服务注册或数据库动作前完成 Authenticode、signer 与 package manifest 校验 |
| 配置检查 | 按 `schemaVersion=1` 校验 `install.json`、访问模式、绑定地址、业务/管理端口、TLS、数据库和 Redis；密码只能来自受限 ACL 的 secret 文件 |
| 预检日志 | 注册/启动服务和任何数据库写入前写入 `logs/install/precheck-*.log` |
| 会话处理 | P0 使用 Redis 不透明会话，不生成 JWT Token Secret；Cookie/超时使用冻结默认值 |
| 数据库迁移 | preflight 只读；服务启动前只由同一 Jar 的 migrate 维护模式执行，迁移凭据只进子进程环境，常驻服务固定禁用 Flyway |
| 初始管理员 | 空库迁移后运行同一 Jar `bootstrap-admin`；默认交互输入并二次确认，只有显式 `-GenerateInitialAdminPassword` 才生成一次性 24 位值；两条路径都只经 stdin 并强制首次改密 |
| 服务安装 | Procrun 固定 LocalService，使用 JVM 内 `VibeBootWindowsService.start/stop`，启用 `NT SERVICE\VibeBoot` service SID，先注册但不启动 |
| ACL | app/runtime/service 只读执行，config/secrets 只读，data/logs 可写，scripts/staging/backup/operations 仅管理员；复核失败注销服务 |
| 启动服务 | 启动后等待健康检查 |
| 健康检查 | 本机 `/actuator/health/readiness`，系统健康接口不作为匿名安装探针 |
| 输出结果 | 访问地址、日志路径、服务名、下一步 |

安装失败时不得伪装成功，必须输出失败步骤和日志路径。

安装预检必须覆盖：

| 检查项 | 要求 |
| --- | --- |
| 包完整性 | 带外 signer、脚本 Authenticode、签名 package manifest、jar、public、runtime、service、db、config 模板和三个 notices 文件全部通过 |
| 端口 | 输出占用进程，不自动杀进程 |
| 数据库 | 运行账号仅 DML、迁移账号仅目标 schema DDL/DML；TLS/连接/权限任一失败即停止 |
| Redis | 生产必需；校验 ACL 用户、实例 key 前缀、命令 allowlist 和非回环 TLS；失败停止，内存降级只允许开发模式 |
| MySQL Client | 校验用户配置的 MySQL 8 `mysqldump`/`mysql` 路径和版本；缺失时停止生产安装 |
| 迁移 | Jar preflight stdout 只输出冻结 JSON；`migration-risk.json` 与 SQL 一一匹配；高风险必须同时具备 switch、精确短语、同一 operationId/highRiskListSha256，任一缺失或变化退出 44/43 且不写库 |
| 磁盘空间 | 备份、日志和数据目录空间不足时停止 |
| 文件目录 | storage root 可写、无 junction/reparse point、ACL 受限，并满足默认配额和 2 GB 保留空间 |
| 敏感配置 | 默认密码、数据库/Redis/TLS 私钥密码、模型凭据主密钥和明文 API Key 输出需阻断；缺少主密钥时由安装脚本生成并限制 ACL |
| 访问模式 | local 必须绑定 127.0.0.1；lan 必须启用 HTTPS、提供可读取 PKCS12、匹配主机名并设置精确 allowedOrigin |
| 管理端口 | 固定绑定 127.0.0.1，默认 8081；业务端口不得暴露 `/actuator/**` |
| TLS 证书 | 校验 PKCS12 密码、私钥、有效期、服务器认证用途和 SAN；密钥内容不得进入日志或 manifest |
| Windows 防火墙 | 默认不开放；仅在 `openFirewall=true` 且管理员确认时创建产品自有业务端口规则，永不开放管理端口/MySQL/Redis |
| 生产 AI 白名单 | 确认没有代码生成、补丁、shell、在线 SQL、交接包执行入口 |
| 第三方 NOTICE | 检查 runtime manifest、依赖 manifest 和 NOTICE 存在且内容/哈希有效 |
| 服务身份 | LocalService + service SID；普通用户或服务进程可写 app/runtime/service/scripts 时阻断 |

生产 MySQL 8 与 Redis 由客户或实施方安装、加固、监控、扩容和维护；Vibe Boot 校验运行/迁移账号分权、Redis ACL 前缀和非回环 TLS，只迁移自身 schema，并在用户配置兼容 MySQL Client 后提供产品逻辑备份。安装器不得下载、安装、升级、卸载外部 MySQL/Redis，也不得开放其防火墙端口。全新安装若 migrate/bootstrap 失败，必须停止并注销本次创建的服务、保留日志并提示恢复或重建目标库；升级失败按同一次回滚点整套恢复。

### 5.5 服务启停状态

| 脚本 | 要求 |
| --- | --- |
| `start.ps1` | 启动 Windows 服务或演示后台进程 |
| `stop.ps1` | 停止服务，等待退出 |
| `status.ps1` | 显示服务状态、端口、健康检查、版本 |

生产脚本健康契约：

| 项目 | 要求 |
| --- | --- |
| liveness | 请求 `http://127.0.0.1:<managementPort>/actuator/health/liveness`，默认管理端口 8081，只判断进程存活 |
| readiness | 请求 `http://127.0.0.1:<managementPort>/actuator/health/readiness`，作为启动和发布成功标准 |
| 默认等待 | start/install/upgrade/restore 最多等待 60 秒，可通过非敏感安装参数覆盖 |
| 成功条件 | HTTP 200 且 JSON `status` 严格等于 `UP` |
| 响应异常 | 超时、非 JSON、缺少 status、非 UP 都不得判定成功 |
| 输出边界 | 可向本机管理员显示脱敏日志路径，但不得输出密钥、连接串、完整敏感配置或接口原始错误体 |

`status.ps1` 退出码：

| 退出码 | 状态 |
| --- | --- |
| `0` | 服务运行且 readiness 为 `UP` |
| `10` | 服务未安装 |
| `11` | 服务已停止 |
| `12` | 服务启动中、停止挂起或状态未知 |
| `20` | 服务进程运行但 liveness 非 `UP` |
| `21` | liveness 为 `UP` 但 readiness 非 `UP` |
| `30` | 参数、安装配置或脚本执行环境错误 |
| `31` | 健康响应超时、无法连接或格式不可解析 |

### 5.6 `uninstall.ps1`

| 项目 | 要求 |
| --- | --- |
| 停止服务 | 卸载前停止服务 |
| 卸载服务 | 通过 Procrun 删除 `VibeBoot` 服务并回读确认 |
| 保留数据 | 默认保留 `data/`、`backup/`、`config/` |
| 删除程序 | 可选删除 `app/` 和服务文件 |
| 二次确认 | 删除数据必须单独确认，P0 默认不删 |

### 5.7 `backup.ps1`

| 内容 | 要求 |
| --- | --- |
| MySQL | 只使用 install 记录并逐次复核版本/SHA256 的 MySQL 8 Client；迁移密码每次交互读取，只在最小 try/finally 作用域写当前进程 `MYSQL_PWD`，启动单个子进程后立即删除并清零 BSTR；禁止参数、临时 option file、日志或磁盘落盘 |
| 文件 | 打包 `data/files/` |
| 配置 | 只打包 allowlist 非敏感配置；永远排除 `config/secrets/**`、模型主密钥、密码和私钥 |
| 版本 | 保存 `app/VERSION` |
| manifest | 写入备份类型、完整产品版本、数据库迁移版本、模型主密钥 SHA256 指纹、相对路径、大小、SHA256 和范围，不写 secret、配置值或业务数据摘要 |

`backup.ps1` 支持 `daily` 和 `upgrade-rollback` 两种类型。两者都必须先停止服务；独立执行 `daily` 并完成校验后恢复调用前的服务状态，由升级或恢复流程调用时保持停服。`upgrade-rollback` 还必须包含升级前 `app/runtime/service/scripts/notices/db/trusted-launcher`、SCM 注册快照与非敏感配置。数据库密文与模型主密钥不得进入同一备份：主密钥和其他 secret 永远排除，客户通过独立渠道托管。包含数据库导出或业务文件的备份整体视为敏感运维资产，只能默认写入安装目录下受限 ACL 的 `backup/`。P0 不承诺备份自身加密，不自动删除历史备份。

备份目录：

```text
backup/vibe-boot-backup-YYYYMMDD-HHmmss/
```

### 5.8 `restore.ps1`

| 步骤 | 要求 |
| --- | --- |
| 选择备份 | 指定备份目录 |
| 校验 manifest | 检查完整性和版本 |
| 停止服务 | 恢复前停止 |
| 版本检查 | 日常恢复只允许完整产品版本一致，跨版本默认阻断 |
| 恢复前备份 | 先备份当前状态，失败则终止恢复 |
| 二次确认 | 覆盖数据前确认 |
| 恢复数据库 | 导入 SQL |
| 恢复文件 | 恢复 `data/files/` |
| 恢复配置 | 只恢复 allowlist 非敏感配置；`config/secrets/` 永远原地保留且不被备份覆盖 |
| 模型密钥 | manifest 指纹必须匹配当前主密钥；不匹配时恢复独立托管密钥，或显式 `-DiscardModelCredentials` 后由同一 Jar 禁用模型配置并清空密文 |
| Redis 失效 | 数据库恢复后调用同一应用 classpath `--vibe.operation=clear-redis-namespace`，固定 SCAN MATCH COUNT 500、逐 key 校验前缀、每批最多 100 个 UNLINK；禁止 redis-cli/KEYS/FLUSH，失败保持停服 |
| 启动与检查 | 全部恢复成功后启动并健康检查；失败保持服务停止 |

日志和 manifest 不得输出密码、Token、API Key 或配置值。版本不兼容时必须阻断，不能只提示后继续。

### 5.9 `upgrade.ps1`

| 步骤 | 要求 |
| --- | --- |
| 认证目标包 | 只运行目标包签名有效的 upgrade.ps1；signer 来自带外，package manifest 全量通过 |
| 读取版本 | 当前版本、目标版本和 minUpgradableVersion；禁止降级与不支持跳跃 |
| 状态记录 | 原子写入 `operations/upgrade-<operationId>.json` schemaVersion=2，记录 package/版本兼容、phase、逐资源 before/target hash 与状态、migrationStarted、maintenanceGate、rollbackPoint 和结果 |
| 只读预检 | 目标 Jar preflight 返回 supportedUpgrade=true；高风险迁移按发布设计第 9 节完成 switch + 精确短语 + operationId + highRiskListSha256 双次复核 |
| 同卷暂存 | 完整目标产物写入 staging 并二次校验，不边复制边覆盖 live |
| 停止服务 | 停止旧版本 |
| 创建回滚点 | 停止服务后备份旧程序、runtime、数据库、文件和非敏感配置；secret 原地保留 |
| 执行迁移 | 启动目标 Jar migrate 前持久化 migration_started；独立迁移账号只进子进程环境 |
| 原子提升 | 同卷 rename 完整 app.next/runtime.next，避免半复制 live 目录 |
| 启动服务 | migrate 已成功后启动新版本常驻服务；运行账号无 DDL 权限且 Flyway disabled |
| 健康检查 | 失败后停止服务，禁止自动反复重试迁移 |
| 回滚说明 | P0 使用同一次升级回滚点整套恢复 |

升级资源固定为 `app/runtime/service/scripts/notices/db/config-public/trusted-launcher/service-registration`，每项状态固定 `pending/staged/live_moved/next_promoted/verified`。全局 phase 固定为 `created/verified/preflight_passed/staged/maintenance_enabled/stopped/backup_complete/migration_started/migration_succeeded/promoting/promoted/service_starting/readiness_passed/completed`；失败只允许 `rollback_required/rolling_back/rolled_back` 或 `failed_manual`。每次状态通过 temp flush + 同卷 rename 原子写入。`maintenance.flag` 必须在停服前建立并在 completed/rolled_back 落盘后删除；存在期间全部业务 API 返回 503。P0 不实现逆向 Flyway；只要 migrate 子进程已启动，就必须使用同一次回滚点恢复全部程序资源、SCM、数据库、文件和非敏感配置，并清空本实例 Redis，不能只换 jar。完整崩溃恢复矩阵以 `docs/release-package-design.md` 第 12 节为准。

### 5.10 生产安全限制

| 能力 | 生产默认 |
| --- | --- |
| AI 修改代码 | 禁用 |
| AI 执行脚本 | 禁用 |
| 数据库结构在线修改 | 禁用 |
| 代码生成应用补丁 | 禁用 |
| 外部 AI 交接包执行 | 禁用 |
| 业务 AI 问答 | 管理员可选启用 |
| 模型配置 | 管理员可维护 |
| 开发需求澄清/项目文档问答/代码变更计划 | 禁用，即使只读也不进入生产包 |

生产配置必须包含或支持：

```yaml
vibe:
  ai:
    dev-tools-enabled: false
```

生产 AI 能力必须使用白名单实现，不能复用开发模式的 AI 工作台执行入口。

| 能力 | S6 要求 |
| --- | --- |
| 模型连接测试 | 可保留，用于验证生产模型配置 |
| 业务问答/摘要/分类/文案/分析 | 管理员可选启用，必须经过权限、脱敏和审计 |
| 开发需求澄清/项目文档问答/代码变更计划 | 不进入生产包；不得用只读模式恢复开发链路 |
| 外部 AI 交接包与开发任务历史 | 不进入生产包，不提供页面或 API；生产只保留业务 AI 自身的记录与审计 |
| 代码生成补丁、源码读取、文件写入 | 不进入生产包 |
| PowerShell/shell 执行 | 不允许由模型触发 |
| 在线 DDL 或任意 SQL 执行 | 不提供入口，只能通过升级包和 Flyway 迁移 |

S6 验收时必须确认：生产模型配置成功不等于开发型 AI 开启；生产 profile 必须强制 `dev-tools-enabled=false`，配置为 true 时启动失败，且不得出现代码编辑、补丁应用、交接包、开发任务历史、源码读取或任意命令入口。

## 6. 交付物清单

| 类型 | 交付物 |
| --- | --- |
| 构建脚本 | `scripts/build-prod.ps1` |
| 生产脚本 | `install.ps1`、`uninstall.ps1`、`start.ps1`、`stop.ps1`、`status.ps1`、`backup.ps1`、`restore.ps1`、`upgrade.ps1`、`common.ps1` |
| 配置模板 | `application-prod.yml`、`model-prod.yml`、`install.json.example`、`secrets/README.txt` |
| 运行产物 | thin `vibe-boot.jar`、枚举后的 `app/lib/*.jar`、`public/`、`VERSION` |
| runtime | JDK 17 |
| 包信任与服务 | 签名 `PACKAGE-MANIFEST.psd1`、Procrun 1.6.1 x64、确定性服务注册参数、包外 `.zip.sha256` |
| 合规清单 | `notices/RUNTIME-MANIFEST.json`、`notices/DEPENDENCY-MANIFEST.json`、`notices/THIRD-PARTY-NOTICES.txt` |
| 文档 | 生产 README、安装/备份/恢复说明 |
| 日志目录 | `logs/app`、`logs/install`、`logs/backup` |

## 7. S6 禁止越界项

| 禁止 | 原因 |
| --- | --- |
| 生产包包含源码 | 增加泄漏和误操作风险 |
| 生产包包含 Maven/Node | 生产只运行构建产物 |
| 生产包缺少 NOTICE | 第三方依赖和 runtime 来源不可追踪 |
| 生产默认启用代码生成/改源码 | 违反安全治理 |
| 生产包提供外部 AI 交接包执行器 | 会把开发/实施协作材料误用为生产补丁、SQL 或 shell 入口 |
| 安装时自动删除数据 | 高风险 |
| 卸载默认删除数据 | 违反可恢复原则 |
| 迁移失败后继续启动 | 可能造成半安装状态 |
| 常驻服务持有迁移账号或 DDL 权限 | 违反最小权限和一次性迁移契约 |
| secret 进入备份或 package manifest | 会把模型密文、主密钥和基础设施密码重新合并或泄漏 |
| 日志输出密钥 | 安全风险 |
| 强制 Docker/Nginx/Kubernetes | 超出中小企业首版门槛 |

## 8. 验证门禁

S6 完成后必须满足：

| 门禁 | 验收方式 |
| --- | --- |
| 构建成功 | 生成 zip 安装包 |
| 包可信 | Authenticode、带外 signer 和签名 package manifest 全部有效；未签名测试包不能生产安装 |
| 不含密钥 | local 配置、模型凭据主密钥、API Key、数据库密码不进入默认包 |
| NOTICE 完整 | 三个 notices 文件齐全，版本、来源、许可证和交付产物 SHA256 可追踪 |
| 迁移执行唯一 | 只有同一 Jar 的一次性 migrate 维护模式内 Flyway 执行；常驻服务和审计副本不可执行，PowerShell 无 SQL/Flyway CLI 路径 |
| 外部服务责任 | 安装器不安装/升级/卸载 MySQL 或 Redis，不开放其端口；缺少服务或 MySQL Client 时预检明确失败 |
| 账号与 TLS | MySQL 运行/迁移账号分权，Redis ACL 限定实例前缀，非回环 MySQL/Redis 强制 TLS |
| 服务身份与 ACL | LocalService + service SID；安装根及各子目录关闭继承并写显式 ACE；普通用户和服务进程不能修改 app/runtime/service/scripts/notices/db/config/operations，`operations/` 与 `data/` 为兄弟目录 |
| 可安装 | `install.ps1` 完成签名校验、JSON/secret 配置、只读预检、一次性 migrate、bootstrap-admin、服务 ACL 和启动，readiness 为 `UP` |
| 预检证据 | `logs/install/precheck-*.log` 记录安装前检查结果 |
| 健康检查 | liveness/readiness 分层可用，系统健康接口鉴权脱敏，status 固定退出码可验证 |
| 可停止启动 | `start.ps1`、`stop.ps1`、`status.ps1` 可用 |
| 可卸载 | `uninstall.ps1` 默认保留数据 |
| 可备份 | `backup.ps1` 包含数据库、文件、非敏感配置、版本和密钥指纹，且排除全部 secret |
| 可恢复 | `restore.ps1` 可恢复测试备份，能处理模型密钥不匹配并清空本实例 Redis 会话/缓存 |
| 可升级回滚 | 目标包脚本、同卷 staging、原子状态、migrationStarted 与整套回滚路径可验证 |
| 生产限制 | 开发型 AI 页面/API/路由不打包，配置为 true 必须启动失败 |
| 交接包边界 | 不提供外部 AI 交接包执行入口，生产只接受受控安装包和迁移流程 |
| 发布通道 | 生产变更只能来自 `build-prod.ps1` 产物、`install.ps1`/`upgrade.ps1` 和版本化迁移，不接受复制源码、复制开发库、执行交接包或手工 SQL |

## 9. AI 实现提示

外部 AI Coding 工具执行 S6 时必须遵守：

| 规则 | 说明 |
| --- | --- |
| 先读文档 | `docs/README.md`、本文、`release-package-design.md`、`quality-gates.md`、`security-governance.md` |
| 不碰开发包语义 | 生产脚本不启动 Vite dev server |
| 不带源码和密钥 | 包内容必须可审查 |
| 失败即停止 | 构建、安装、迁移、健康检查失败不得继续 |
| 操作前备份 | 升级和恢复前必须保护现状 |
| 中文输出 | 所有脚本失败给中文原因和日志路径 |
| 不执行交接包 | 外部 AI 交接包只属于开发/实施链路，不能变成生产脚本输入 |
| 不走发布旁路 | 不得建议复制源码、复制开发数据库或手工 SQL 作为生产交付方式 |

## 10. 完成定义

S6 只有在以下条件同时满足时才算完成：

| 条件 | 说明 |
| --- | --- |
| 构建闭环 | 可生成不含密钥的生产 zip |
| 合规闭环 | zip 内三个 notices 文件齐全，安装预检能校验来源、许可证和 SHA256 |
| 安装闭环 | 可在 Windows 上安装为服务并健康检查通过 |
| 运维闭环 | 可 start/stop/status/uninstall |
| 数据闭环 | 可 backup/restore，且恢复前有确认和保护 |
| 升级闭环 | 可 upgrade，失败可按备份恢复 |
| 安全闭环 | 生产不携带开发型 AI 能力，不能由管理员配置恢复 |
| 交接边界闭环 | 生产包不包含交接包执行器，不接受补丁、SQL 或 shell 作为在线变更入口 |
| 发布通道闭环 | 开发成果只能通过构建、安装/升级、迁移和健康检查进入生产 |
| 文档闭环 | README 说明安装、启停、备份、恢复、升级 |

## 11. 一句话总结

S6 生产安装包要把 Vibe Boot 从“本地能开发”推进到“企业能交付”：构建产物清爽、安装过程可诊断、服务可管理、数据可备份恢复、升级有回退路径，且生产环境不携带开发型 AI 风险。
