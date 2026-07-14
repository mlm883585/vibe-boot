# Vibe Boot S1 工程骨架任务分解

## 1. 文档目的

本文把 `docs/engineering-skeleton-spec.md` 中的 S1 工程骨架规格拆成可执行任务，用于进入编码后的第一轮施工。

本文仍属于编码前文档，不创建代码。它的作用是防止 S1 实现时顺手做进登录、权限、AI 工作台、代码生成或生产安装包等后续阶段能力。

## 2. S1 交付边界

| 项目 | S1 做 | S1 不做 |
| --- | --- | --- |
| 后端 | Maven 多模块、最小 Spring Boot 启动、基础配置 | 用户、角色、菜单、权限业务 |
| 前端 | Vue 3.5.39/Vite 8.1.3/TypeScript 6.0.3/Element Plus 2.14.2/Pinia 3.0.4/Vue Router 4.6.4/Axios 1.18.1 工程、默认页面、构建通过 | 完整后台布局和业务页面 |
| 脚本 | doctor/dev-start/dev-stop 骨架和基础检查 | build-prod/install/backup/restore |
| 配置 | dev/prod/local example 结构 | 真实密钥和生产安装配置 |
| 文档 | 根 README、启动与验证说明 | 业务用户手册 |
| 数据库 | Flyway 目录预留、连接配置占位 | 系统表和业务表实现 |

## 3. 实施顺序

| 顺序 | 任务组 | 目标 | 完成标志 |
| --- | --- | --- | --- |
| 1 | Git 与目录基线 | 确保忽略规则和目录结构正确 | `.gitignore` 覆盖 runtime/data/logs/package/config local/reference |
| 2 | 后端父工程 | 创建 Maven 父 POM 和版本管理 | `backend/pom.xml` 可识别所有模块 |
| 3 | 后端子模块 | 创建 P0 后端模块空壳 | 各模块有 pom 和基础包 |
| 4 | 启动模块 | 创建最小 Spring Boot 应用 | `vibe-starter` 可启动 |
| 5 | 后端配置 | 创建 dev/prod 配置和本地模板 | local 配置不提交 |
| 6 | 前端工程 | 创建 Vue 3.5.39/Vite 8.1.3/TS 6.0.3/Element Plus 2.14.2/Pinia 3.0.4/Vue Router 4.6.4/Axios 1.18.1 项目 | `npm install`、`npm run build` 可执行 |
| 7 | 前端目录 | 建立 api/views/layout/stores 等目录 | 符合 `frontend-admin-spec.md` |
| 8 | 脚本骨架 | 创建 PowerShell 脚本入口 | doctor/dev-start/dev-stop 有中文输出 |
| 9 | 根 README | 写明启动、验证、文档入口 | 新人能按 README 找到 docs |
| 10 | S1 验证 | 执行质量门禁 | 符合 `quality-gates.md` S1 门禁 |

开始第 1 项之前，外部 AI Coding 工具必须先输出 `signoffStatus`、`s1Allowed`、`launchPhraseExact`、`stageAdmissionPath`、`sourceDirsBefore`、`allowedScope`、`forbiddenScope` 和 `admissionCard.result`。其中 `stageAdmissionPath` 必须精确指向待准入时创建的 **docs/stage-records/S1-admission.md** 且该记录的 `decision=pass`；`admissionCard.result` 不是新的授权来源，只能证明已检查签收记录、启动口令、S1 阶段、执行入口、上下文、风险、验证和生产边界。任一字段不满足即停止，且不得创建源码目录。

## 4. 任务明细

### 4.1 Git 与目录基线

| 任务 | 验收 |
| --- | --- |
| 检查 `.gitignore` 是否包含 `reference/` | 参考项目不会进入提交 |
| 增加 runtime/data/logs/package 忽略规则 | 运行时、数据、日志、安装包不提交 |
| 增加 local 配置忽略规则 | 密钥配置不提交 |
| 不创建空目录占位 | 不提交 `.gitkeep`；runtime/data/logs/package 及尚无文件的源码目录都由后续脚本或阶段按需创建 |

### 4.2 后端父工程

| 任务 | 验收 |
| --- | --- |
| 创建 `backend/pom.xml` | packaging 为 `pom` |
| 创建 `backend/.mvn/settings.xml` | 固定阿里云公共镜像 `https://maven.aliyun.com/repository/public`、`mirrorOf=central`，不含凭据 |
| 固定 Java 17 | Maven 编译配置明确 |
| 引入 Spring Boot 3.5.16 版本管理 | P0 锁定 Spring Boot 3.5.x patch 线，不自动升级 4.x |
| 集中管理 MyBatis-Plus 3.5.16、Sa-Token 1.45.0、Springdoc OpenAPI 2.8.17、Velocity 2.4.1，并让 Flyway/Redis Starter 跟随 Spring Boot BOM | 不在子模块散落版本；不提前实现 S2/S4 能力 |
| 禁止动态版本 | 不使用 `LATEST`、`RELEASE` |

### 4.3 后端子模块

| 模块 | S1 内容 |
| --- | --- |
| `vibe-common` | 只创建可构建模块 POM，不创建 Java 占位类 |
| `vibe-security` | 依赖 common，只创建模块 POM |
| `vibe-system` | 依赖 common/security，只创建模块 POM |
| `vibe-ai` | 依赖 common/skill，只创建模块 POM |
| `vibe-skill` | 依赖 common，只创建模块 POM |
| `vibe-gen` | 依赖 common/system/skill，只创建模块 POM |
| `vibe-file` | 依赖 common，只创建模块 POM |
| `vibe-starter` | 启动类、配置文件、健康检查依赖 |

S1 不要求实现 Controller、Service、Mapper 的完整业务。

### 4.4 启动模块

| 任务 | 验收 |
| --- | --- |
| 创建 `VibeBootApplication` | 包名 `com.vibeboot.starter` |
| 配置组件扫描 | 能扫描 `com.vibeboot` |
| 引入 Spring Boot Actuator | `/actuator/health/liveness` 与 `/actuator/health/readiness` 可证明后端启动；不得另造平行健康协议 |
| 配置业务端口 8080、Actuator 管理端口 8081 | 管理端口仅绑定 127.0.0.1，与 ADR-0002 一致 |
| 启动失败中文提示预留 | 后续脚本能包装错误 |

### 4.5 后端配置

| 文件 | S1 内容 |
| --- | --- |
| `application.yml` | 应用名、profile、基础日志 |
| `application-dev.yml` | 业务 8080、回环管理 8081、占位数据源、Redis 占位 |
| `application-prod.yml` | 生产配置占位，不含密钥 |
| `config/application-local.yml.example` | 本地覆盖模板 |
| `config/model-local.yml.example` | 模型配置模板 |

密钥和本地真实配置不得提交。

### 4.6 前端工程

| 任务 | 验收 |
| --- | --- |
| 创建 `frontend/package.json` | scripts 至少包含 dev/build |
| 使用 Vue 3.5.39 + Vite 8.1.3 + TypeScript 6.0.3 | 与 ADR-0001 一致 |
| 引入 Element Plus 2.14.2 | 不引入第二套 UI |
| 引入 Pinia 3.0.4 + Vue Router 4.6.4 + Axios 1.18.1 | 不允许实施时临场选版本 |
| 声明 `engines.node >=24.18.0 <25` | 只接受受支持的 Node 24 LTS 线 |
| 使用 npm 和 package-lock | 不混用 pnpm/yarn |
| 前端依赖版本明确 | 不使用 `latest`、`*` 或未锁定主版本 |
| 配置 `.npmrc` 国内镜像 | 面向中国用户 |
| 默认页面可打开 | S1 不要求完整管理端 |
| `npm run build` 通过 | 符合质量门禁 |

### 4.7 前端目录

| 目录 | S1 要求 |
| --- | --- |
| `src/views/HomeView.vue` | 唯一默认页面，只显示产品名和“开发骨架已启动”，不跨端口请求 Actuator，也不实现后台业务 |
| `src/router/index.ts` | 只注册根路由到 HomeView |
| `src/styles/index.css` | 全局样式入口，保持简洁管理端基线 |
| `src/App.vue`、`src/main.ts` | 装配 Vue、Router、Pinia 和 Element Plus |
| `src/api`、`src/layout`、`src/stores`、`src/utils`、`src/components` | S1 不创建空目录或占位文件，S2 使用时再创建 |

目录必须与 `docs/frontend-admin-spec.md` 兼容。

### 4.8 PowerShell 脚本

| 脚本 | S1 任务 | 验收 |
| --- | --- | --- |
| `common.ps1` | 路径、日志、中文输出函数 | 其他脚本可复用 |
| `mvn.ps1` | 定位 Maven 3.8.x，始终显式传入项目 settings 并透传 Maven 参数 | 从仓库根目录执行 `scripts/mvn.ps1 -version` 可看到受控 Maven；禁止裸 `mvn` |
| `doctor.ps1` | 检查 JDK、Maven、Node、npm、端口、目录权限 | 输出中文诊断 |
| `dev-start.ps1` | 启动后端和前端，写 PID 或日志 | 打印访问地址或失败原因 |
| `dev-stop.ps1` | 停止 dev-start 启动的进程 | 不误杀无关进程 |

S1 脚本必须幂等友好，重复执行时能给出当前状态。

### 4.9 根 README

| 内容 | 验收 |
| --- | --- |
| 项目定位 | 一句话说明 Vibe Boot |
| 当前阶段 | 明确 S1 工程骨架 |
| 文档入口 | 指向 `docs/README.md` |
| 开发前检查 | 指向 `scripts/doctor.ps1` |
| 启动方式 | 指向 `scripts/dev-start.ps1` |
| 验证方式 | 列出后端快速构建和前端构建 |
| 本地配置 | 指向 config example，不写真实密钥 |

## 5. S1 禁止越界

| 禁止 | 说明 |
| --- | --- |
| 不实现完整登录 | S2 基础后台做 |
| 不创建系统业务表 | S2 数据库迁移做 |
| 不实现模型调用 | S3 模型网关做 |
| 不实现 AI 任务 | S4 做；S3 只做模型网关 |
| 不实现代码生成模板 | S4 做 |
| 不实现客户拜访记录 | S4/S7 做 |
| 不写生产安装脚本 | S6 做 |
| 不引入 Docker/K8s/MQ/ES | 违反首版技术栈约束 |
| 不创建 P2/P2+ 预留模块 | `vibe-workflow`、`vibe-report`、`vibe-message`、`vibe-integration` 不进入 S1 |

## 6. S1 验证顺序

| 顺序 | 验证 | 通过标准 |
| --- | --- | --- |
| 1 | `scripts/doctor.ps1` | 输出环境检查报告，不因缺少可选服务直接崩溃 |
| 2 | 后端快速构建 | `scripts/mvn.ps1 -pl vibe-starter -am -DskipTests package` 通过 |
| 3 | 后端启动 | liveness/readiness 标准摘要可用，非回环请求被拒绝 |
| 4 | 前端依赖安装 | `npm install` 使用国内镜像完成 |
| 5 | 前端构建 | `npm run build` 通过 |
| 6 | `scripts/dev-start.ps1` | 能启动或输出明确失败原因 |
| 7 | `scripts/dev-stop.ps1` | 能停止开发进程或说明未运行 |

如果某项未执行，必须按 `docs/quality-gates.md` 输出未执行原因和补验建议。

S1 健康检查验收只覆盖：

| 项目 | S1 标准 |
| --- | --- |
| liveness | `http://127.0.0.1:8081/actuator/health/liveness` 返回 Actuator 标准摘要，应用存活时 HTTP 200 |
| readiness | `http://127.0.0.1:8081/actuator/health/readiness` 返回标准摘要；S1 尚未接入的业务依赖不得用伪造明细冒充已检查 |
| 网络边界 | 管理端口只绑定回环，业务端口 8080 不存在 `/actuator/**` |
| 暴露面 | 除 health 相关端点外，不开放其他 Actuator 管理端点 |
| 业务健康接口 | S1 不创建匿名 `/api/system/health`；该接口进入 S2 |

## 7. 交付物清单

| 交付物 | 类型 | 是否必须 |
| --- | --- | --- |
| `backend/pom.xml` | 后端 | 是 |
| `backend/vibe-*/pom.xml` | 后端 | 是 |
| `backend/vibe-starter/src/main/.../VibeBootApplication.java` | 后端 | 是 |
| `frontend/package.json` | 前端 | 是 |
| `frontend/package-lock.json` | 前端 | 是 |
| `frontend/src/` 基础目录 | 前端 | 是 |
| `scripts/common.ps1` | 脚本 | 是 |
| `scripts/doctor.ps1` | 脚本 | 是 |
| `scripts/dev-start.ps1` | 脚本 | 是 |
| `scripts/dev-stop.ps1` | 脚本 | 是 |
| `config/*.example` | 配置 | 是 |
| 根 `README.md` | 文档 | 是 |

S1 结束时必须把上表转化为阶段关闭证据包的一部分。每个交付物都要标记为 `completed`、`failed`、`skipped` 或 `not-applicable`，并说明对应文件路径或未完成原因。只有交付物清单、验证结果、越界检查、文档同步和残余风险都清楚时，才可以申请关闭 S1；这不自动授权 S2。

## 8. 风险与处理

| 风险 | 处理 |
| --- | --- |
| Maven 多模块依赖循环 | 按 `module-design.md` 依赖方向修正 |
| 前端依赖下载慢 | 使用 `.npmrc` 国内镜像 |
| 本地缺 MySQL/Redis | S1 不强制连接，只提示 |
| PowerShell 执行策略限制 | doctor 输出中文说明和修复建议 |
| 过早实现业务 | 对照本文第 5 节回退到骨架范围 |
| 验证命令耗时 | 先跑快速构建，再补完整测试 |

## 9. 与后续阶段的交接

| 后续阶段 | S1 应提供 |
| --- | --- |
| S2 基础后台 | 后端模块、前端目录、配置结构、脚本入口，并遵守 `docs/backend-implementation-spec.md` |
| S3 模型网关 | `vibe-ai` 模块、配置模板、前端路由基础 |
| S4 AI 工作台与代码生成 | `vibe-ai`/`vibe-gen` 模块、前端工作台与生成目录、质量门禁入口 |
| S5 开发包 | doctor/dev-start/dev-stop 的初版 |
| S6 生产包 | 后端 jar、前端 build、配置结构基础 |

## 10. 一句话总结

S1 的成功标准不是功能多，而是工程干净：后端能构建启动，前端能构建，脚本能诊断，配置不泄密，目录和依赖边界足够稳定，能承接后续 S2-S7。
