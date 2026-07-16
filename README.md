# Vibe Boot

Vibe Boot 是面向中国中小企业、Windows 优先的 AI 原生 Java/Vue 模块化单体应用底座。用户在真实工程上持续迭代业务系统，平台后续提供模型网关、AI 工作台、Skills/规则、质量门禁和生产安装能力，而不是把业务锁在低代码运行时中。

## 当前阶段

| 项目 | 状态 |
| --- | --- |
| 当前阶段 | S1 工程骨架已完成；S2 未授权 |
| S1 准入 | 已签收、已收到精确启动口令，`docs/stage-records/S1-admission.md` 为 `decision=pass` |
| S1 关闭 | `docs/stage-records/S1-close.md` 为 `decision=pass`，不自动授权 S2 |
| 已实现范围 | Maven 多模块、Vue 单页骨架、Windows 开发脚本、无密钥配置示例 |
| 未授权范围 | S2-S7、登录权限、模型调用、AI 工作台、代码生成、生产安装包 |
| 文档入口 | [`docs/README.md`](docs/README.md) |

S1 关闭不自动授权 S2。后续实现仍按 [`docs/post-coding-change-control.md`](docs/post-coding-change-control.md) 执行文档优先和阶段准入。

## 技术基线

| 领域 | S1 基线 |
| --- | --- |
| 后端 | JDK 17、Spring Boot 3.5.16、Maven 3.8.x |
| 数据 | MySQL 8、Redis；S1 只保留配置占位，不建立连接 |
| 前端 | Node.js `>=24.18.0 <25`、npm、Vue 3.5.39、Vite 8.1.3、TypeScript 6.0.3、Element Plus 2.14.2 |
| 架构 | Java/Vue 模块化单体，Windows 优先 |

Maven 固定使用 `backend/.mvn/settings.xml` 中的阿里云公共镜像；npm 固定使用 `frontend/.npmrc` 中的 npmmirror 镜像。

## 环境准备

脚本依次查找项目 `runtime/`、`VIBE_*_HOME` 环境变量和 PATH。全局环境不符合版本时，可在当前 PowerShell 会话指定：

```powershell
$env:VIBE_JAVA_HOME = 'D:\path\to\jdk-17'
$env:VIBE_MAVEN_HOME = 'D:\path\to\apache-maven-3.8.8'
$env:VIBE_NODE_HOME = 'D:\path\to\node-v24.18.0-win-x64'
# 用户级 npm 本地代理失效时，可仅在当前会话直连项目国内镜像
$env:VIBE_NPM_DIRECT = '1'
```

执行开发环境诊断：

```powershell
.\scripts\doctor.ps1
```

MySQL/Redis 在 S1 是可选检查项；JDK、Maven、Node.js、npm 和国内镜像是必需项。

## 构建验证

```powershell
# 后端快速构建
.\scripts\mvn.ps1 -pl vibe-starter -am -DskipTests package

# 后端完整测试
.\scripts\mvn.ps1 -pl vibe-starter -am test

# 前端安装与构建
Set-Location frontend
npm install
npm run build
```

所有 Maven 命令都必须通过 `scripts/mvn.ps1`，不得用裸 `mvn` 绕过版本和镜像检查。

## 开发启停

```powershell
.\scripts\dev-start.ps1
.\scripts\dev-stop.ps1
```

| 入口 | 地址 |
| --- | --- |
| 前端 | `http://127.0.0.1:5173/` |
| 后端业务端口 | `http://127.0.0.1:8080/`；S1 不提供业务 API |
| liveness | `http://127.0.0.1:8081/actuator/health/liveness` |
| readiness | `http://127.0.0.1:8081/actuator/health/readiness` |

Actuator 仅绑定 `127.0.0.1:8081` 且只暴露 health；业务端口不暴露 `/actuator/**`。

## 本地配置

| 模板 | 本地文件 |
| --- | --- |
| `config/application-local.yml.example` | `config/application-local.yml` |
| `config/model-local.yml.example` | `config/model-local.yml` |

真实 local/prod/install/密钥配置均被 Git 忽略。S1 不读取模型配置；模型 API Key 后续也不得以明文写入 YAML。

## 规范入口

| 主题 | 文档 |
| --- | --- |
| S1 工作令 | [`docs/s1-implementation-work-order.md`](docs/s1-implementation-work-order.md) |
| AI 使用方式 | [`docs/ai-tool-usage-guide.md`](docs/ai-tool-usage-guide.md) |
| API 规范 | [`docs/api-conventions.md`](docs/api-conventions.md) |
| 数据库基线 | [`docs/database-baseline.md`](docs/database-baseline.md) |
| 质量门禁 | [`docs/quality-gates.md`](docs/quality-gates.md) |

外部 AI 交接包只用于开发/实施链路，不是生产补丁、SQL 或 shell 执行入口。
