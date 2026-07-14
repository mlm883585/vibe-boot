# Vibe Boot S1 工程骨架规格

## 1. 文档目的

本文定义 Vibe Boot S1 阶段工程骨架的实现规格。它是进入编码前的施工图，用于约束后续创建 Maven 多模块、Vue 前端、Windows 脚本、配置模板和基础目录时的范围。

本文只定义规格，不创建代码。

## 2. S1 目标

S1 只解决一件事：建立一个最小可启动、可构建、可扩展的工程骨架。

| 目标 | 说明 |
| --- | --- |
| 后端骨架 | Spring Boot 3.5.16 + Maven 多模块，模块边界符合 `module-design.md` |
| 前端骨架 | Vue 3.5.39 + Vite 8.1.3 + TypeScript 6.0.3 + Element Plus 2.14.2 + Pinia 3.0.4 + Vue Router 4.6.4 + Axios 1.18.1 + npm |
| 配置骨架 | dev/prod/local example 配置分离 |
| 脚本骨架 | Windows PowerShell 脚本入口存在，并能做基础诊断 |
| 文档保持 | README 指向 docs，不把设计埋在代码里 |
| 规范就绪 | API 与数据库规范作为后续编码基线 |
| AI 使用入口就绪 | README 和脚本提示能指向模型配置、AI 工作台和外部 AI 交接包说明 |
| 不做业务 | S1 不实现完整用户/角色/AI/代码生成业务 |

## 3. S1 不做范围

| 不做项 | 原因 |
| --- | --- |
| 不实现登录权限完整业务 | S2 基础后台阶段实现 |
| 不实现 AI 工作台 | S4 阶段实现；S3 只实现模型网关 |
| 不实现代码生成 | S4 阶段实现 |
| 不生成生产安装包 | S6 阶段实现 |
| 不引入 Docker | 首版 Windows 优先 |
| 不连接真实大模型 | S3 阶段实现 |
| 不创建 P2/P2+ 预留模块 | `vibe-workflow`、`vibe-report`、`vibe-message`、`vibe-integration` 进入实现前必须先更新文档 |

## 4. 目标目录结构

```text
vibe-boot/
├── backend/
│   ├── pom.xml
│   ├── .mvn/
│   │   └── settings.xml
│   ├── vibe-common/
│   ├── vibe-security/
│   ├── vibe-system/
│   ├── vibe-ai/
│   ├── vibe-skill/
│   ├── vibe-gen/
│   ├── vibe-file/
│   └── vibe-starter/
├── frontend/
├── scripts/
│   ├── common.ps1
│   ├── mvn.ps1
│   ├── doctor.ps1
│   ├── dev-start.ps1
│   └── dev-stop.ps1
├── config/
│   ├── application-local.yml.example
│   └── model-local.yml.example
├── docs/
├── data/
├── logs/
├── package/
├── .gitignore
└── README.md
```

## 5. 后端 Maven 规格

### 5.1 父 POM

| 项目 | 规格 |
| --- | --- |
| groupId | `com.vibeboot` |
| artifactId | `vibe-boot-backend` |
| packaging | `pom` |
| Java | 17 |
| Spring Boot | 3.5.16 |
| Maven | 3.8.x |
| 编码 | UTF-8 |

`backend/.mvn/settings.xml` 是项目 Maven 公共镜像的唯一源码权威配置，固定 mirror id `vibe-boot-aliyun`、`mirrorOf=central`、URL `https://maven.aliyun.com/repository/public`，不含账号密码。所有项目 Maven 命令必须通过仓库根目录 `scripts/mvn.ps1` 执行；脚本从任意当前目录定位项目根，优先使用项目 runtime Maven 3.8.x、否则使用 PATH Maven 3.8.x，并始终显式传入受控 settings。S1 禁止直接调用裸 `mvn` 绕过镜像和版本诊断。

### 5.2 后端模块

| 模块 | packaging | S1 内容 |
| --- | --- | --- |
| `vibe-common` | jar | 只创建模块 POM，不创建无意义 Java 占位类 |
| `vibe-security` | jar | 依赖 common，只创建模块 POM |
| `vibe-system` | jar | 依赖 common/security，只创建模块 POM |
| `vibe-ai` | jar | 依赖 common/skill，只创建模块 POM |
| `vibe-skill` | jar | 依赖 common，只创建模块 POM |
| `vibe-gen` | jar | 依赖 common/system/skill，只创建模块 POM |
| `vibe-file` | jar | 依赖 common，只创建模块 POM |
| `vibe-starter` | jar | Spring Boot 启动类、配置文件、Actuator liveness/readiness 骨架 |

S1 的 7 个非启动模块只含可构建 POM；不创建 `.gitkeep`、占位常量、空配置类或业务表。`vibe-starter` 只创建最小启动类和健康配置。

### 5.3 依赖版本

| 依赖 | S1 策略 |
| --- | --- |
| Spring Boot Starter Web | `vibe-starter` 引入 |
| Spring Boot Starter Actuator | `vibe-starter` 引入，仅开放 health 相关端点 |
| Spring Boot Starter Validation | 公共校验 |
| MyBatis-Plus | 父 POM 锁定 `3.5.16`，S2/S4 使用 |
| Sa-Token | 父 POM 锁定 `cn.dev33:sa-token-spring-boot3-starter` 与 `cn.dev33:sa-token-redis-jackson` 为 `1.45.0`，S2 使用；不引入 Fastjson/Redisson |
| Flyway | 由 Spring Boot `3.5.16` BOM 管理，S2/S4 使用 |
| Redis Starter | 由 Spring Boot `3.5.16` BOM 管理，S2/S3 使用 |
| Springdoc OpenAPI | 父 POM 锁定 `2.8.17`，S2 使用 |
| Velocity | 父 POM 锁定 `2.4.1`，S4 使用 |
| Lombok | P0 不引入，父 POM 不声明 Lombok 依赖 |

约束：

| 约束 | 说明 |
| --- | --- |
| 依赖版本集中管理 | 父 POM 统一管理 |
| BOM 优先 | Spring Boot BOM 已管理的依赖不重复硬编码版本 |
| 不引入 Spring Cloud | 遵守产品约束 |
| 不引入 MQ/ES/K8s | 遵守技术栈最小化 |
| 不使用动态版本 | 版本必须明确 |
| 不使用 Lombok | S1 创建的 Java 类不得包含 `@Data`、`@Getter`、`@Setter`、`@Builder` 等 Lombok 注解 |
| 不升级 Spring Boot 4.x | P0 只允许 Spring Boot 3.5.x patch 线，主版本升级必须先修订 ADR |

## 6. 后端包名规格

基础包名：

```text
com.vibeboot
```

模块包名：

| 模块 | 包名 |
| --- | --- |
| common | `com.vibeboot.common` |
| security | `com.vibeboot.security` |
| system | `com.vibeboot.system` |
| ai | `com.vibeboot.ai` |
| skill | `com.vibeboot.skill` |
| gen | `com.vibeboot.gen` |
| file | `com.vibeboot.file` |
| starter | `com.vibeboot.starter` |

启动类固定为：

```text
com.vibeboot.starter.VibeBootApplication
```

## 7. 后端配置规格

`vibe-starter` 资源目录：

```text
src/main/resources/
├── application.yml
├── application-dev.yml
├── application-prod.yml
└── banner.txt
```

配置策略：

| 文件 | S1 内容 |
| --- | --- |
| `application.yml` | 应用名 `vibe-boot`、profile、基础配置 |
| `application-dev.yml` | 业务端口 8080、回环 Actuator 管理端口 8081、日志、占位数据源配置 |
| `application-prod.yml` | 生产配置模板和占位符，不含真实密钥 |
| `application-local.yml` | 不提交，由 config 模板生成 |

S1 Actuator 最小配置必须等价满足：`management.server.address=127.0.0.1`、默认 `management.server.port=8081`、启用 liveness/readiness probes、Web exposure 只包含 `health`、`show-details=never`。业务端口不得映射 `/actuator/**`，不得通过开放 `env`、`configprops`、`beans`、`mappings` 等端点代替诊断日志。

父 POM/Spring Boot Maven Plugin 必须生成 build info，健康接口版本从 Maven `project.version` 读取。后续 `build-prod.ps1` 生成的 `app/VERSION` 必须与 build info 完全一致，禁止在 Java 常量中重复维护版本号。

S1 不要求连接数据库成功，但配置结构必须为 S2 预留。

默认命名与连接占位：

| 项目 | S1 默认值 |
| --- | --- |
| 产品名 | `Vibe Boot` |
| 工程标识 | `vibe-boot` |
| 后端应用名 | `vibe-boot` |
| Windows 服务名 | `VibeBoot` |
| 默认生产安装目录 | `C:\VibeBoot` |
| 默认数据库名 | `vibe_boot` |
| 开发数据库用户默认名 | `vibe_boot`，密码必须留空、占位或由 ignored 本地配置提供；生产账号名来自 `install.json` |
| 后端端口 | 8080 |
| Actuator 管理端口 | 8081，仅绑定 127.0.0.1 |
| 前端端口 | 5173 |
| MySQL 端口 | 3306 |
| Redis 端口 | 6379 |

配置提交约束：

| 文件 | S1 处理 |
| --- | --- |
| `config/application-local.yml.example` | 可提交，必须只含占位符和中文注释 |
| `config/model-local.yml.example` | 可提交，必须只含占位符和中文注释 |
| `config/application-local.yml` | 不提交，必须被 `.gitignore` 覆盖 |
| `config/model-local.yml` | 不提交，必须被 `.gitignore` 覆盖 |
| `config/application-prod.yml`、`config/model-prod.yml`、`config/install.json` | S1 不生成真实文件；生产安装阶段外置生成，含密钥时不得提交 |

## 8. 前端工程规格

| 项目 | 规格 |
| --- | --- |
| 框架 | Vue 3.5.39 |
| 构建 | Vite 8.1.3 |
| Vue 插件 | `@vitejs/plugin-vue` 6.0.7 |
| 语言 | TypeScript 6.0.3 |
| UI | Element Plus 2.14.2 |
| 包管理 | npm |
| Node | Node.js 24.x LTS（基线 24.18.0）；`package.json#engines.node` 固定为 `>=24.18.0 <25` |
| 状态管理 | Pinia 3.0.4 |
| 路由 | Vue Router 4.6.4 |
| HTTP | Axios 1.18.1 |

目录结构：

```text
frontend/
├── package.json
├── package-lock.json
├── vite.config.ts
├── tsconfig.json
├── index.html
├── .npmrc
└── src/
    ├── router/
    ├── styles/
    ├── views/
    ├── App.vue
    └── main.ts
```

S1 的 `router/`、`styles/`、`views/` 均包含实际入口文件，不保留空目录。`api/`、`assets/`、`components/`、`layout/`、`stores/`、`utils/` 到 S2 有真实用途时再创建。S1 前端验收只要求默认页面可启动和构建，不要求完整后台布局。

## 9. Windows 脚本规格

S1 只创建开发相关脚本。

| 脚本 | S1 要求 |
| --- | --- |
| `common.ps1` | 公共路径、日志、输出函数 |
| `mvn.ps1` | 透传 Maven 参数，固定 Maven 3.8.x 和 `backend/.mvn/settings.xml`；S5 后按网络模式选择受控企业/内网 settings |
| `doctor.ps1` | 检查 Java、Maven、Node、npm、端口、目录权限 |
| `dev-start.ps1` | 启动后端和前端，打印地址 |
| `dev-stop.ps1` | 停止由 dev-start 启动的进程 |

S1 不实现：

| 脚本 | 阶段 |
| --- | --- |
| `build-prod.ps1` | S6 |
| `install.ps1` | S6 |
| `backup.ps1` | S6 |
| `restore.ps1` | S6 |

## 10. Git 忽略规格

`.gitignore` 必须覆盖：

| 路径/模式 | 说明 |
| --- | --- |
| `reference/` | 参考项目不提交 |
| `runtime/` | 大型 runtime 不提交 |
| `data/` | 用户数据不提交 |
| `logs/` | 日志不提交 |
| `package/` | 安装包产物不提交 |
| `config/*local*` | 本地密钥配置不提交 |
| `node_modules/` | 前端依赖不提交 |
| `target/` | Maven 构建产物不提交 |
| `.idea/`、`.vscode/` | IDE 文件不提交 |

## 11. README 规格

根目录 `README.md` 在 S1 至少包含：

| 内容 | 说明 |
| --- | --- |
| 项目定位 | 简述 Vibe Boot |
| 当前阶段 | 标明文档优先/S1 工程骨架 |
| 开发启动 | 指向 `scripts/doctor.ps1` 与 `scripts/dev-start.ps1` |
| 文档入口 | 指向 `docs/README.md` |
| AI 使用入口 | 指向 `docs/ai-tool-usage-guide.md`，说明模型配置、AI 工作台和外部 AI 交接包的阅读入口 |
| 技术栈 | JDK17、Maven3.8、MySQL8、Redis、Node24 LTS、Vue3 |
| API 规范 | 指向 `docs/api-conventions.md` |
| 数据库规范 | 指向 `docs/database-baseline.md` |

## 12. S1 验收标准

| 验收项 | 标准 |
| --- | --- |
| 后端 Maven 多模块存在 | `backend/pom.xml` 能识别所有 P0 模块 |
| 后端可构建 | `scripts/mvn.ps1 -pl vibe-starter -am -DskipTests package` 通过 |
| 后端可启动 | `vibe-starter` 启动，`127.0.0.1:8081` 的 liveness/readiness 返回 Actuator 标准摘要，业务端口无 Actuator 路由 |
| 前端可安装 | `npm install` 使用国内镜像 |
| 前端可构建 | `npm run build` 通过 |
| doctor 可运行 | 输出环境检查 |
| dev-start 可运行 | 能启动后端/前端或给出明确错误 |
| dev-stop 可运行 | 能停止开发进程或说明未运行 |
| 文档仍同步 | docs 索引包含 S1 规格 |
| AI 使用路径可发现 | README 或 doctor 输出能引导用户读取 AI 使用指南、配置模型，并理解交接包不是生产执行入口 |
| API 规范可引用 | `docs/api-conventions.md` 存在 |
| 数据库基线可引用 | `docs/database-baseline.md` 存在 |

## 13. S1 风险

| 风险 | 应对 |
| --- | --- |
| 一开始实现过多业务 | S1 只做骨架，不做完整系统模块 |
| 脚本过早复杂 | doctor 先做核心检查 |
| 前端布局耗时 | S1 只做可启动可构建，完整后台在 S2 |
| 数据库依赖阻塞启动 | S1 固定不激活 DataSource/Redis/Sa-Token/Flyway 自动配置，只验证 Web + Actuator 骨架；S2 才接入外部 MySQL 和开发内存会话/外部 Redis |
| 多模块依赖混乱 | 严格遵守 `module-design.md` |

## 14. 编码准入

进入 S1 编码前必须确认：

| 条件 | 状态 |
| --- | --- |
| ADR-0001 技术选型 | 已满足 |
| ADR-0002 实现契约 | 已满足 |
| S1 不做范围 | 本文已明确 |
| S1 目录结构 | 本文已明确 |
| S1 验收标准 | 本文已明确 |
| AI 使用入口 | 本文已要求 README/doctor 指向 `docs/ai-tool-usage-guide.md` |

## 15. 一句话总结

S1 工程骨架不是做产品功能，而是建立一个后续所有 AI coding、代码生成、Windows 开发包和生产安装包都能站得住的最小工程地基。
