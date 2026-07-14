# Vibe Boot S5 Windows 开发包任务分解

## 1. 文档目的

本文把 `docs/windows-devkit-design.md` 拆解为可执行的 S5 编码任务，明确 Windows 开发包的任务顺序、交付物、验证方式和禁止越界项。

S5 的目标是让用户在 Windows 上解压项目后，通过中文脚本完成环境诊断、开发启动、模型配置和停止服务。S5 是开发模式体验，不是生产安装包。

## 2. S5 总目标

| 目标 | 验收口径 |
| --- | --- |
| 解压可识别 | 项目目录、runtime、config、logs、scripts 结构清晰 |
| 环境可诊断 | `doctor.ps1` 输出 JDK、Maven、Node、MySQL、Redis、端口、镜像和模型配置状态 |
| 开发可启动 | `dev-start.ps1` 可启动后端、前端和必要开发服务 |
| 开发可停止 | `dev-stop.ps1` 可停止由开发包启动的进程 |
| 模型可配置 | `setup-model.ps1` 或管理端引导可写入本地模型配置 |
| 首次使用可引导 | 脚本和 README 能引导用户读取文档、配置模型、打开 AI 工作台、创建任务 |
| 国内网络友好 | Maven/npm 默认使用项目级国内镜像 |
| 弱网/内网可诊断 | doctor 能识别 online/mirror/intranet 模式，说明镜像、代理和缓存缺失原因 |
| 密钥不入 Git | local 配置、模型 API Key、数据库密码不显示在 Git 状态中 |
| 日志可定位 | 脚本、后端、前端日志落到约定目录 |

## 3. 前置条件

| 前置项 | 要求 |
| --- | --- |
| S1 工程骨架 | 后端、前端、scripts 目录存在 |
| S2 基础后台 | 开发启动后可登录验证 |
| S3 模型网关 | 模型配置字段和连接测试已定义 |
| S4 代码生成 | 生成后可通过开发启动预览 |
| 阶段签收与启动 | S1-S4 已按顺序完成并通过门禁，维护者明确启动 S5；本文本身不是当前编码许可 |
| 质量门禁 | `quality-gates.md` 已定义 S5 门禁 |
| 开发包规格 | `windows-devkit-design.md` 已确认 |

## 4. 任务顺序

| 顺序 | 任务 | 主要产物 | 依赖 |
| --- | --- | --- | --- |
| 1 | 开发包目录与忽略规则 | `scripts/`、`config/`、`runtime/`、`data/`、`logs/`、`.gitignore` | S1 工程骨架 |
| 2 | 公共脚本函数 | `scripts/common.ps1` | 目录结构 |
| 3 | 环境诊断脚本 | `scripts/doctor.ps1` | common |
| 4 | 本地配置模板 | `config/application-local.yml.example`、`config/model.local.yml.example`、`config/devkit.yml` | 配置规范 |
| 5 | 国内镜像与网络模式配置 | Maven `settings.xml`、`.npmrc`、`RUNTIME-MANIFEST.json`、`THIRD-PARTY-NOTICES.txt`、可选缓存清单 | runtime 策略 |
| 6 | 开发启动脚本 | `scripts/dev-start.ps1` | doctor、配置模板 |
| 7 | 开发停止脚本 | `scripts/dev-stop.ps1` | dev-start PID/端口记录 |
| 8 | 模型配置向导 | `scripts/setup-model.ps1` | 模型网关配置 |
| 9 | 日志与诊断报告 | `logs/scripts`、启动日志、doctor 报告 | 所有脚本 |
| 10 | 首次使用引导 | 下一步提示、AI 工作台入口、交接包说明 | setup-model、README |
| 11 | S5 验收与文档入口 | README、中文错误提示、质量门禁检查 | 全部 S5 任务 |

## 5. 任务明细

### 5.1 开发包目录与忽略规则

| 目录/文件 | 要求 |
| --- | --- |
| `scripts/` | PowerShell 脚本目录 |
| `runtime/` | 源码仓库不提交二进制，开发发行包包含 runtime |
| `config/` | example 提交，local 忽略 |
| `data/` | 用户数据，忽略 |
| `logs/` | 日志，忽略 |
| `package/` | 打包产物，忽略 |
| `.npmrc` | 默认国内 npm registry |
| `.gitignore` | 覆盖 local、data、logs、package、runtime 二进制 |

S5 不要求把 JDK/Maven/Node 二进制提交到 Git。

### 5.2 公共脚本函数

`scripts/common.ps1` 提供公共能力：

| 函数能力 | 要求 |
| --- | --- |
| 路径解析 | 以项目根目录为基准，不依赖当前执行目录 |
| 日志写入 | 标准化写入 `logs/scripts/` |
| 中文输出 | Info/Warn/Error/Success |
| 命令查找 | Java、Maven、Node、npm、Redis |
| 端口检查 | 后端、前端、MySQL、Redis |
| 敏感信息脱敏 | API Key、密码、Token |
| 进程记录 | 保存由开发脚本启动的 PID |

公共函数必须避免危险默认行为，不自动杀掉用户机器上无关进程。

### 5.3 `doctor.ps1`

| 检查项 | P0 要求 |
| --- | --- |
| PowerShell | 版本和执行策略提示 |
| Java | 查找项目 runtime、JAVA_HOME、PATH，确认 JDK 17 |
| Maven | 查找项目 runtime、MAVEN_HOME、PATH，确认 3.8.x |
| Node/npm | 查找项目 runtime、PATH，确认 Node.js 20.19+ LTS |
| Maven 镜像 | 检查项目级 `settings.xml` |
| npm 镜像 | 检查 `.npmrc` 是否指向国内镜像 |
| 网络模式 | 读取 `devkit.yml` 中 online/mirror/intranet 设置，检查镜像或企业私服可达 |
| runtime manifest | 读取 `runtime/RUNTIME-MANIFEST.json`，输出 JDK/Maven/Node/npm 版本和异常 |
| runtime NOTICE | 检查 runtime 和预置工具的来源、许可证摘要和 `THIRD-PARTY-NOTICES.txt` |
| 缓存清单 | intranet 模式下检查 Maven/npm 缓存清单，缺失时给补齐建议 |
| MySQL | 检查连接配置和端口可达 |
| Redis | 检查连接配置或开发 Redis |
| 端口 | 后端业务 8080、Actuator 管理 8081、前端 5173、Redis 6379 |
| 模型配置 | 检查模型配置是否存在，不打印 API Key |
| 写权限 | `data/`、`logs/`、`package/` |

输出必须包含整体状态：passed/warn/failed，并给出中文修复建议。

### 5.4 本地配置模板

| 文件 | 要求 |
| --- | --- |
| `config/application-local.yml.example` | 数据库、Redis、端口、本地路径示例 |
| `config/model.local.yml.example` | provider、apiBase、apiKey、modelName 示例 |
| `config/devkit.yml` | runtime 路径、端口、镜像、脚本策略 |
| `config/application-local.yml` | 首次运行可由脚本复制生成，Git 忽略 |
| `config/model.local.yml` | 模型配置，Git 忽略 |

配置模板必须中文注释清楚，不能把真实密钥写入 example。

### 5.5 国内镜像与网络模式配置

| 工具 | P0 要求 |
| --- | --- |
| Maven | 项目级 `settings.xml` 默认国内镜像，不改用户全局配置 |
| npm | `.npmrc` 使用 `https://registry.npmmirror.com` |
| 网络模式 | `devkit.yml` 明确 online/mirror/intranet，默认 online |
| runtime 清单 | 发行开发包包含 `runtime/RUNTIME-MANIFEST.json`，源码仓库可只提交示例或说明 |
| 内网缓存 | intranet 模式可携带 Maven/npm 缓存清单，缺失依赖必须显式提示 |
| 依赖版本 | 后端和前端依赖版本锁定 |
| 失败提示 | 下载失败时提示镜像、代理、网络排查方向 |

S5 不引入 pnpm/yarn，不扩大包管理器范围。

### 5.6 `dev-start.ps1`

| 步骤 | 要求 |
| --- | --- |
| 预检 | 调用 doctor 关键检查 |
| 环境变量 | 设置本次进程内 JAVA_HOME、MAVEN_HOME、PATH |
| 本地配置 | 缺失 local 配置时从 example 生成并提示 |
| Redis | 仅启动开发包内置 Redis 或提示外部 Redis |
| 后端 | 启动 Spring Boot，日志写入 `logs/backend/` |
| 前端 | 启动 Vite dev server，日志写入 `logs/frontend/` |
| 输出 | 打印后端地址、前端地址、日志路径、停止命令 |

启动脚本不得默认推送代码、不得执行生产安装、不得覆盖用户 local 配置。

### 5.7 `dev-stop.ps1`

| 能力 | 要求 |
| --- | --- |
| 停止后端 | 只停止由 dev-start 记录的 PID |
| 停止前端 | 只停止由 dev-start 记录的 PID |
| 停止 Redis | 只停止开发包启动的 Redis |
| 保留数据 | 默认不删除 `data/` |
| 输出 | 中文说明停止结果和未停止原因 |

如 PID 丢失，可提示用户手动检查端口，不自动杀端口上的未知进程。

### 5.8 `setup-model.ps1`

| 字段 | 要求 |
| --- | --- |
| provider | 供应商或 OpenAI Compatible |
| apiBase | API Base |
| apiKey | 输入不回显或提示谨慎 |
| modelName | 模型名 |
| timeout | 超时时间 |

输出：

| 产物 | 要求 |
| --- | --- |
| `config/model.local.yml` | 写入本地模型配置，Git 忽略 |
| 测试连接 | 可调用后端模型网关或提示用户在管理端测试 |
| 日志 | 不记录明文 API Key |

### 5.9 日志与诊断报告

| 日志 | 路径 |
| --- | --- |
| doctor 报告 | `logs/scripts/doctor-YYYYMMDD-HHmmss.log` |
| dev-start 日志 | `logs/scripts/dev-start-YYYYMMDD-HHmmss.log` |
| dev-stop 日志 | `logs/scripts/dev-stop-YYYYMMDD-HHmmss.log` |
| 后端日志 | `logs/backend/` |
| 前端日志 | `logs/frontend/` |

日志约束：

| 约束 | 说明 |
| --- | --- |
| 不打印密钥 | API Key、密码、Token 脱敏 |
| 错误可定位 | 保留关键命令、退出码、日志路径 |
| 中文摘要 | 失败时给下一步建议 |

### 5.10 首次使用引导

S5 不是只把服务启动起来，还必须告诉用户下一步如何进入 AI 开发闭环。

| 入口 | 必须提示 |
| --- | --- |
| `doctor.ps1` 结束 | 当前环境状态、缺失项、是否需要执行 `setup-model.ps1` |
| `setup-model.ps1` 结束 | 模型配置位置、如何测试连接、密钥不入 Git 的提醒 |
| `dev-start.ps1` 结束 | 后端地址、前端地址、AI 工作台入口、日志路径、停止命令 |
| 开发包 README | 首次使用顺序：doctor、setup-model、dev-start、登录、打开 AI 工作台、创建任务 |
| AI 工作台入口说明 | 企业用户描述需求，平台生成计划和外部 AI 交接包 |

首次使用引导不得暗示用户可以在生产服务器上执行 AI 代码修改。

## 6. 交付物清单

| 类型 | 交付物 |
| --- | --- |
| 脚本 | `common.ps1`、`doctor.ps1`、`dev-start.ps1`、`dev-stop.ps1`、`setup-model.ps1` |
| 配置 | `application-local.yml.example`、`model.local.yml.example`、`devkit.yml`、`.npmrc`、Maven `settings.xml` |
| 目录 | `runtime/` 占位说明、`data/`、`logs/`、`package/` |
| 合规清单 | `runtime/RUNTIME-MANIFEST.json`、`runtime/THIRD-PARTY-NOTICES.txt`、可选 `runtime/cache-manifest.json` |
| 文档 | 开发包 README 或根 README 开发启动章节 |
| 首次使用 | doctor/setup-model/dev-start 输出中的下一步提示和 AI 工作台入口 |
| 忽略规则 | local 配置、runtime 二进制、data、logs、package |

## 7. S5 禁止越界项

| 禁止 | 原因 |
| --- | --- |
| 提交 JDK/Maven/Node 二进制到源码仓库 | 仓库膨胀，发行包阶段处理 |
| 修改用户全局环境变量 | 影响用户机器其他项目 |
| 修改用户全局 Maven/npm 配置 | 破坏隔离 |
| 自动安装 MySQL | 复杂且高风险，P0 只做连接检查 |
| 自动杀端口上的未知进程 | 可能误杀用户进程 |
| 自动执行生产安装 | S6 范围 |
| 把 API Key 写入 Git 跟踪文件 | 安全风险 |
| 默认执行高风险重置 | dev-reset 必须单独确认 |

## 8. 验证门禁

S5 完成后必须满足：

| 门禁 | 验收方式 |
| --- | --- |
| doctor 可运行 | PowerShell 下输出中文诊断报告 |
| runtime 查找 | 能识别项目 runtime 或系统环境 |
| Maven 镜像 | 使用项目级 settings，不改全局 |
| npm 镜像 | `.npmrc` 生效 |
| 网络模式 | online/mirror/intranet 当前模式、镜像地址和可达性可诊断 |
| runtime manifest | 能输出 runtime 版本、来源和异常；缺失时给修复建议 |
| runtime NOTICE | 能提示 runtime 来源和许可证摘要；缺失时不得宣称开发发行包完整 |
| local 配置 | 缺失时可生成 example 副本，且 Git 忽略 |
| dev-start | 能启动后端和前端，打印访问地址 |
| dev-stop | 能停止由 dev-start 启动的进程 |
| setup-model | 能生成本地模型配置且不泄漏 API Key |
| 首次使用引导 | 新用户能按提示完成模型配置、进入 AI 工作台并创建任务 |
| 日志 | 脚本/后端/前端日志落盘 |

## 9. AI 实现提示

外部 AI Coding 工具执行 S5 时必须遵守：

| 规则 | 说明 |
| --- | --- |
| 先读文档 | `docs/README.md`、本文、`windows-devkit-design.md`、`quality-gates.md` |
| 不碰生产脚本 | S5 只做开发脚本 |
| 不写死绝对路径 | 所有路径基于项目根目录 |
| 不修改用户全局配置 | 只使用项目级配置 |
| 不输出密钥 | 所有日志和摘要脱敏 |
| 失败要中文化 | 每个失败步骤给修复建议 |

## 10. 完成定义

S5 只有在以下条件同时满足时才算完成：

| 条件 | 说明 |
| --- | --- |
| 诊断闭环 | doctor 能给出可读环境报告 |
| 启停闭环 | dev-start/dev-stop 可管理开发进程 |
| 配置闭环 | local 配置和模型配置可生成且安全 |
| 镜像闭环 | Maven/npm 国内镜像项目级生效 |
| 弱网闭环 | 网络模式、镜像可达性和内网缓存缺失能被 doctor 解释清楚 |
| 合规闭环 | runtime 来源、版本、校验和许可证摘要可被 doctor 和 README 解释清楚 |
| 日志闭环 | 所有关键脚本有日志路径 |
| 安全闭环 | 密钥不进入 Git、不进入日志 |
| 文档闭环 | README 告诉用户如何启动、停止、配置模型 |
| 使用路径闭环 | 脚本输出和 README 告诉用户如何进入 AI 工作台并获得外部 AI 交接包 |

## 11. 一句话总结

S5 Windows 开发包要把“能不能跑起来”这件事做成产品能力：项目内 runtime、国内镜像、中文诊断、本地配置、模型向导和可停止的开发进程，是中小企业用户开始 AI coding 的入口。
