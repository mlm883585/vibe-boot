# Vibe Boot Windows 开发包设计草案

## 1. 文档目的

本文定义 Vibe Boot 首版 Windows 开发包的目标体验、目录结构、运行时依赖、国内镜像、启动脚本、诊断脚本和实现约束。

Windows 开发包的目标不是展示技术能力，而是让中国中小企业用户尽可能少配置环境：解压项目、执行脚本、配置大模型，即可进入 AI coding 开发模式。

## 2. 核心目标

| 目标 | 说明 |
| --- | --- |
| 解压即开发 | 用户不需要先全局安装 JDK、Maven、Node.js |
| 国内网络友好 | Maven 和 npm 默认使用国内镜像 |
| 问题可诊断 | 启动失败时给中文原因和修复建议 |
| 本地配置安全 | API Key、数据库/Redis密码和 TLS 私钥密码不进入 Git；P0 不使用 JWT Token Secret |
| 开发生产分离 | 开发包用于生成和验证代码，不等于生产安装包 |
| AI 路径清晰 | 用户能按提示配置模型、打开工作台、生成外部 AI 交接包 |
| Windows 优先 | 首版只保证 Windows 10/11、Windows Server 2019+ |

一句话：

> Windows 开发包是 Vibe Boot 的第一体验，它必须让用户把注意力放在业务和 AI 需求上，而不是环境配置上。

## 3. 支持范围

| 项目 | 首版范围 |
| --- | --- |
| 操作系统 | Windows 10/11、Windows Server 2019+ |
| Shell | PowerShell 5.1+，优先兼容 Windows 自带版本 |
| JDK | JDK 17 |
| Maven | Maven 3.8.x |
| Node.js | Node.js 20.19+ LTS，已由 ADR-0001 确认 |
| MySQL | MySQL 8.x，默认外部安装，开发包可提供连接检查 |
| Redis | Redis 7.x 或兼容版本，开发包可提供可选内置实例 |
| 浏览器 | Edge / Chrome |

暂不承诺：

| 暂不支持 | 原因 |
| --- | --- |
| Linux/Mac 一键开发包 | 首版聚焦 Windows |
| Docker 强依赖 | 降低中小企业门槛 |
| 多 JDK 版本 | 减少测试矩阵 |
| 多 Node 包管理器并行 | 首版固定 npm，pnpm/yarn 作为后续重新决策项 |

## 4. 开发包目录结构

```text
vibe-boot/
├── backend/                    # Java 后端源码
├── frontend/                   # Vue 前端源码
├── docs/                       # 项目文档
├── scripts/
│   ├── doctor.ps1              # 环境诊断
│   ├── dev-start.ps1           # 开发启动
│   ├── dev-stop.ps1            # 开发停止
│   ├── dev-reset.ps1           # 开发环境重置，危险操作需确认
│   ├── setup-model.ps1         # 大模型配置向导
│   └── common.ps1              # 公共脚本函数
├── runtime/
│   ├── jdk17/                  # 预置 JDK，发行包包含，源码仓库不提交
│   ├── maven-3.8/              # 预置 Maven，含 settings.xml
│   ├── node/                   # 预置 Node.js
│   └── redis/                  # 可选开发 Redis
├── config/
│   ├── application-local.yml.example
│   ├── model.local.yml.example
│   └── devkit.yml
├── data/
│   ├── mysql/                  # 可选开发数据
│   ├── redis/                  # 可选 Redis 数据
│   └── files/                  # 本地文件
├── logs/
│   ├── backend/
│   ├── frontend/
│   └── scripts/
├── package/                    # 生产安装包输出，Git 忽略
├── .npmrc
└── README.md
```

Git 约束：

| 路径 | 是否提交 | 说明 |
| --- | --- | --- |
| `runtime/` | 否或仅提交说明文件 | 大型二进制不进 Git |
| `data/` | 否 | 用户数据 |
| `logs/` | 否 | 日志 |
| `package/` | 否 | 构建产物 |
| `config/*.example` | 是 | 配置模板 |
| `config/*.local.*` | 否 | 本地密钥配置 |

## 5. 运行时准备策略

首版可以采用“源码仓库不提交 runtime，发行开发包包含 runtime”的方式。

| 场景 | 策略 |
| --- | --- |
| GitHub 源码仓库 | 不提交 JDK/Maven/Node 二进制，只提交脚本和说明 |
| 开发包 zip | 包含 JDK、Maven、Node，必要时包含 Redis |
| 企业内网包 | 允许将 Maven/npm 缓存打包 |
| 用户已有环境 | 脚本优先使用项目内 runtime，避免受全局环境影响 |

runtime 选择顺序：

| 工具 | 查找顺序 |
| --- | --- |
| Java | `runtime/jdk17/bin/java.exe` -> `JAVA_HOME` -> `PATH` |
| Maven | `runtime/maven-3.8/bin/mvn.cmd` -> `MAVEN_HOME` -> `PATH` |
| Node | `runtime/node/node.exe` -> `PATH`，版本为 Node.js 20.19+ LTS |
| npm | `runtime/node/npm.cmd` -> `PATH` |
| Redis | `runtime/redis/redis-server.exe` -> 外部连接 |

### 5.1 网络模式与 runtime 清单

开发包必须明确自己处于哪种网络模式，不能在弱网或企业内网场景下只给出“依赖下载失败”的模糊错误。

| 模式 | 适用场景 | 开发包要求 |
| --- | --- | --- |
| online | 可访问公网和国内镜像 | 使用项目级 Maven settings 与 `.npmrc` 下载依赖 |
| mirror | 可访问企业 Nexus/npm 私服 | `devkit.yml` 可覆盖 Maven/npm 镜像地址 |
| intranet | 不能访问公网，只能使用预置缓存 | 开发发行包可携带 Maven/npm 缓存清单，doctor 必须提示缺失依赖 |

发行开发包必须包含 runtime manifest，用于脚本诊断和用户排障。

| 文件 | 内容 |
| --- | --- |
| `runtime/RUNTIME-MANIFEST.json` | JDK、Maven、Node、npm、可选 Redis 的完整版本、来源、下载地址、许可证、SHA256 校验摘要 |
| `runtime/THIRD-PARTY-NOTICES.txt` | runtime 与预置工具的许可证摘要、版权声明和替换说明 |
| runtime 说明文件 | runtime 获取方式、替换方式、许可证提醒和企业内网替换路径 |
| `runtime/cache-manifest.json` | 可选，记录 Maven/npm 缓存包范围和生成时间 |

约束：

| 约束 | 说明 |
| --- | --- |
| 源码仓库不提交大型 runtime | 只在发行开发包中包含 |
| doctor 必须读取 manifest | 缺少、版本不符或校验失败时给中文提示 |
| patch 可替换但必须可追踪 | JDK 17、Maven 3.8.x、Node 20.19+、Redis 7.x 兼容线内允许安全补丁升级，但 manifest 必须记录完整版本和 SHA256 |
| 许可证信息必须可见 | manifest 或 NOTICE 缺失时，doctor 必须提示不能作为正式开发发行包 |
| 内网包不得暗示依赖完整 | 缓存缺失必须提示如何补齐或切换镜像 |
| 不修改用户全局代理 | 代理只通过项目配置或当前 PowerShell 会话生效 |

## 6. 国内镜像配置

### 6.1 Maven

开发包必须提供项目级 Maven 配置：

```text
runtime/maven-3.8/conf/settings.xml
```

默认镜像：

| 镜像 | 用途 |
| --- | --- |
| 阿里云 Maven Central 镜像 | 默认公共依赖下载 |
| 企业 Nexus | 可通过 `devkit.yml` 覆盖 |

约束：

| 约束 | 说明 |
| --- | --- |
| 不修改用户全局 Maven 配置 | 只使用项目内 settings |
| 失败提示中文化 | 说明是否网络、代理、仓库不可用 |
| 依赖版本锁定 | 禁止动态版本 |

### 6.2 npm

项目根目录和 `frontend/` 下至少一个位置提供 `.npmrc`：

```text
registry=https://registry.npmmirror.com
```

约束：

| 约束 | 说明 |
| --- | --- |
| 默认国内源 | `npmmirror` |
| 锁文件必提交 | `package-lock.json` |
| 不要求全局 npm 配置 | 只影响项目 |
| 安装失败可诊断 | 给中文错误提示 |

## 7. 脚本设计

### 7.1 `doctor.ps1`

环境诊断脚本必须先于开发启动可单独执行。

| 检查项 | 处理 |
| --- | --- |
| PowerShell 版本 | 不满足则提示升级 |
| Java 版本 | 必须为 17 |
| Maven 版本 | 必须为 3.8.x 或兼容 |
| Node 版本 | 必须为 Node.js 20.19+ LTS |
| Maven 镜像 | 检查 settings.xml |
| npm 镜像 | 检查 `.npmrc` |
| 网络模式 | 检查 online/mirror/intranet 配置和可达性 |
| runtime manifest | 检查 JDK/Maven/Node/npm 版本、来源和校验摘要 |
| 依赖缓存 | intranet 模式下检查 Maven/npm 缓存清单是否存在 |
| MySQL 连接 | 检查地址、端口、账号、数据库 |
| Redis 连接 | 检查地址、端口 |
| 端口占用 | 后端、前端、Redis 等 |
| 大模型配置 | 检查是否配置供应商和 API Key |
| 写权限 | 检查 `data/`、`logs/`、`package/` |

输出要求：

| 输出 | 说明 |
| --- | --- |
| 通过 | 绿色或明确“通过”字样 |
| 警告 | 可继续但建议处理 |
| 失败 | 必须给修复建议 |
| 汇总 | 最后输出整体状态 |

### 7.2 `dev-start.ps1`

开发启动脚本职责：

| 步骤 | 说明 |
| --- | --- |
| 1 | 加载 `common.ps1` |
| 2 | 调用 doctor 的关键检查 |
| 3 | 设置 JAVA_HOME、MAVEN_HOME、PATH |
| 4 | 检查/生成本地配置 |
| 5 | 可选启动开发 Redis |
| 6 | 启动后端 |
| 7 | 启动前端 |
| 8 | 打印访问地址和日志路径 |
| 9 | 打印 AI 工作台入口、AI 使用指南和交接包说明 |

约束：

| 约束 | 说明 |
| --- | --- |
| 不静默失败 | 每个关键步骤必须有输出 |
| 不强制管理员权限 | 普通开发启动不需要管理员 |
| 不覆盖本地配置 | 已存在 local 配置时不覆盖 |
| 后台进程可停止 | 必须记录 PID 或提供停止方式 |

### 7.3 `dev-stop.ps1`

职责：

| 项目 | 说明 |
| --- | --- |
| 停止后端 | 按 PID 或端口识别 |
| 停止前端 | 按 PID 或端口识别 |
| 停止开发 Redis | 仅停止开发包启动的 Redis |
| 保留数据 | 默认不删除数据 |

### 7.4 `setup-model.ps1`

大模型配置向导：

| 字段 | 说明 |
| --- | --- |
| provider | 供应商 |
| apiBase | API Base |
| apiKey | API Key，输入时不回显 |
| modelName | 模型名 |
| timeout | 超时时间 |

约束：

| 约束 | 说明 |
| --- | --- |
| API Key 不写入 Git 文件 | 写入 ignored local 配置 |
| 尽量加密 | P1 加密保存，P0 至少文件忽略和权限提示 |
| 支持测试连接 | 调用模型做最小测试 |

## 8. 本地配置设计

```text
config/
├── application-local.yml.example
├── application-local.yml       # Git 忽略
├── model.local.yml.example
└── model.local.yml             # Git 忽略
```

配置约束：

| 约束 | 说明 |
| --- | --- |
| example 必须可读 | 中文注释说明每个字段 |
| local 必须忽略 | 防止密钥提交 |
| 脚本自动生成 | 首次运行可从 example 复制 |
| 不写死绝对路径 | 优先相对路径 |

## 9. 端口规划

默认命名：

| 项目 | 默认值 |
| --- | --- |
| 产品名 | `Vibe Boot` |
| 工程标识 | `vibe-boot` |
| 后端应用名 | `vibe-boot` |
| Windows 服务名 | `VibeBoot` |
| 生产安装目录 | `C:\VibeBoot` |
| 数据库名 | `vibe_boot` |
| 建议数据库用户 | `vibe_boot`，密码不得写入 example |

| 服务 | 默认端口 | 说明 |
| --- | --- | --- |
| 后端 API | 8080 | 可通过配置修改 |
| Actuator 管理 | 8081 | 仅绑定 127.0.0.1，开发脚本和诊断使用 |
| 前端 dev server | 5173 | Vite 默认风格 |
| MySQL | 3306 | 外部服务 |
| Redis | 6379 | 外部或开发包可选 |

端口占用处理：

| 场景 | 处理 |
| --- | --- |
| 后端端口占用 | 提示进程，允许换端口 |
| 管理端口占用 | 提示进程，允许通过非敏感配置调整，但仍只绑定回环 |
| 前端端口占用 | Vite 可换端口，但必须打印实际地址 |
| MySQL/Redis 占用 | 不自动杀进程，只提示 |

## 10. 日志设计

| 日志 | 路径 |
| --- | --- |
| 脚本日志 | `logs/scripts/` |
| 后端日志 | `logs/backend/` |
| 前端日志 | `logs/frontend/` |
| doctor 报告 | `logs/scripts/doctor-YYYYMMDD-HHmmss.log` |

约束：

| 约束 | 说明 |
| --- | --- |
| 日志不提交 Git | `.gitignore` 覆盖 |
| 错误可定位 | 输出关键命令和错误摘要 |
| 不输出密钥 | API Key、密码必须脱敏 |

## 11. 开发包验收标准

| 验收项 | 标准 |
| --- | --- |
| 解压目录可识别 | 目录结构完整 |
| doctor 可运行 | 输出环境检查报告 |
| Maven 使用国内镜像 | 能在日志中看到项目 settings |
| npm 使用国内镜像 | 能读取 `.npmrc` |
| 本地配置不入 Git | `git status` 不显示密钥配置 |
| 后端可启动 | 打印 API 地址 |
| 前端可启动 | 打印访问地址 |
| 模型可配置 | setup-model 可生成配置 |
| AI 使用路径可完成 | 用户能从脚本或 README 找到 `docs/ai-tool-usage-guide.md`、配置模型、进入 AI 工作台并导出外部 AI 交接包 |
| 网络模式可解释 | doctor 能说明当前 online/mirror/intranet 模式、镜像地址和依赖缺失风险 |
| runtime manifest 可校验 | doctor 能读取 runtime manifest 并输出版本和异常 |

## 11.1 首次使用 AI 路径

Windows 开发包必须把 AI 工具使用方法产品化，不能假设用户已经会组织上下文或写提示词。

| 步骤 | 用户动作 | 平台输出 |
| --- | --- | --- |
| 1 | 运行 `scripts/doctor.ps1` | 环境检查、国内镜像状态、模型配置状态 |
| 2 | 运行 `scripts/setup-model.ps1` | 生成 ignored 的模型本地配置，并提示 API Key 不入 Git |
| 3 | 运行 `scripts/dev-start.ps1` | 后端、前端地址、AI 工作台入口、日志路径 |
| 4 | 打开 AI 工作台 | 需求输入、上下文、风险、计划、交接包区域 |
| 5 | 生成外部 AI 交接包 | 阶段、目标、允许范围、禁止事项、风险等级、验证命令和输出格式 |

首次使用输出要求：

| 要求 | 说明 |
| --- | --- |
| 必须指向使用指南 | 输出 `docs/ai-tool-usage-guide.md` |
| 必须说明交接包用途 | 交接包用于开发/实施链路，不是生产补丁执行脚本 |
| 必须说明生产边界 | 生产模式只允许业务 AI，不允许源码修改、shell、在线改表 |
| 必须给下一步 | 成功后提示打开工作台，失败时提示修复配置或网络 |

## 12. 已收敛决策项

| 决策 | 当前口径 | 证据 |
| --- | --- | --- |
| Node 版本 | Node.js 20.19+ LTS | 已由 ADR-0001 确认 |
| 包管理器 | npm | 已由 ADR-0001 确认 |
| Redis 开发包 | 内置 / 外部 | 开发包可选内置，生产建议外部 |
| runtime 获取方式 | 发行包内置 / 首次下载 | 发行包内置，源码仓库不提交 |
| API Key 加密 | DPAPI / 明文 ignored 文件 | P0 ignored，P1 Windows DPAPI |
| runtime 合规记录 | 手工说明 / manifest + NOTICE | P0 必须提供 manifest 和 THIRD-PARTY-NOTICES |

## 13. 编码准入

进入 Windows 开发包脚本实现前必须确认：

| 条件 | 状态 |
| --- | --- |
| Node 版本确认 | 已由 ADR-0001 确认为 Node.js 20.19+ LTS |
| 包管理器选择确认 | 已由 ADR-0001 确认为 npm |
| runtime 打包策略确认 | 已由 ADR-0002 确认为源码仓库不提交、开发发行包包含 |
| MySQL/Redis 开发策略确认 | 已由 ADR-0001 确认为 MySQL 外部连接、Redis 开发可选内置 |
| local 配置文件名确认 | 已由 ADR-0002 确认为 `config/application-local.yml` 与 `config/model.local.yml` |
| 默认端口确认 | 已由 ADR-0002 确认 |
| AI 首次使用路径确认 | 已由 `docs/ai-tool-usage-guide.md` 和本文第 11.1 节确认 |
| runtime 来源和许可证记录确认 | 已由本文第 5.1 节和 `docs/product-constraints.md` 确认 |

## 14. 一句话总结

Vibe Boot Windows 开发包必须让用户不再被环境配置挡住：项目内 runtime、国内镜像、中文诊断、模型配置向导和清晰脚本，是 AI coding 能真正落地到中小企业的第一道门槛。
