# ADR-0001：MVP 首版技术决策

## 状态

Accepted

## 日期

2026-06-28

## 背景

Vibe Boot 已明确首版定位：面向中国中小企业的 Windows 优先 AI coding Java Admin 单体应用底座。当前文档体系已经覆盖产品约束、模块设计、AI 工作台、skills 规则、代码生成、Windows 开发包、生产安装包、安全治理和 MVP 路线。

在进入编码前，必须收敛一批反复出现的技术选型问题，避免实现阶段在多个候选方案之间摇摆。

## 决策总表

| 决策项 | 首版选择 | 说明 |
| --- | --- | --- |
| Spring Boot 基线 | 3.5.16 | 维持 Spring Boot 3 方向，锁定 P0 可执行 patch 版本 |
| 后端外部依赖基线 | MyBatis-Plus 3.5.16、Sa-Token 1.45.0、Springdoc OpenAPI 2.8.17、Velocity 2.4.1 | 不由 Spring Boot BOM 完全兜底的依赖显式锁定 |
| 前端版本基线 | Vue 3.5.39 + Vite 8.1.3 + TypeScript 6.0.3 + Element Plus 2.14.2 | 锁定 P0 可执行前端依赖线 |
| 运行时版本策略 | JDK 17 LTS、Maven 3.8.x、MySQL 8.x、Redis 7.x 或兼容 | 主版本/兼容线固定，发行包记录实际 patch 和 SHA256 |
| 前端 UI 组件库 | Element Plus | 国内 Vue Admin 生态更常见，企业后台组件丰富 |
| 权限框架 | Sa-Token 1.45.0 | 国内 Admin 生态友好，上手简单，适合单体应用 |
| 数据库迁移 | Flyway | 简洁、版本化、Spring Boot 集成成熟 |
| Node.js 版本 | Node.js 20.19+ LTS | 满足 Vite 8 对 Node 20 的最低要求 |
| 前端包管理器 | npm | 用户认知成本低，Node 自带 |
| Windows 服务工具 | WinSW | 面向 Windows 服务场景成熟，配置清晰 |
| Redis 策略 | 开发可选内置，生产外部连接 | 降低开发门槛，避免生产包过重 |
| MySQL 策略 | 开发/生产默认外部连接 | 不在首版生产包内置 MySQL |
| ID 策略 | 雪花 ID | 便于未来导入、迁移和分布式预留 |
| 模板引擎 | Velocity 2.4.1 | Java Admin 代码生成生态常见，模板简单 |
| 测试数据库 | 本地 MySQL 优先，Testcontainers P1 | Windows 首版减少 Docker 依赖 |
| 前端静态资源承载 | Spring Boot 承载 | 首版不强制 Nginx |
| API 文档 | Springdoc OpenAPI 2.8.17 | Spring Boot 3.5.x 生态适配 |
| AI 模型协议 | OpenAI 兼容接口优先 | 国内外模型接入成本低 |
| Lombok | P0 不引入 | 减少编译插件、IDE 插件和生成代码风格差异 |

## 具体决策

### 1. Spring Boot 基线：3.5.16

| 项目 | 说明 |
| --- | --- |
| P0 | Spring Boot `3.5.16` |
| 版本线 | 只允许 Spring Boot `3.5.x` patch 升级 |
| 放弃 | 编码前直接切 Spring Boot 4.x |
| 官方依据 | Spring Boot 官方依赖版本页列出稳定版本 `3.5.16`；Spring Boot 当前系统要求 Maven `3.6.3+`，与项目 Maven `3.8.x` 兼容 |

理由：项目已明确 JDK 17、Maven 3.8.x、Spring Boot 3 和最小技术栈。直接使用 4.x 会扩大升级风险和生态适配范围；继续写 `3.x` 又会在 S1 创建 POM 时留下临场选择。P0 因此锁定 `3.5.16`，后续只允许在 `3.5.x` 内做 patch 更新。

约束：父 POM 必须显式声明 Spring Boot `3.5.16`；禁止使用 `LATEST`、`RELEASE`、版本区间或未锁定属性。若要升级到 Spring Boot 4.x，必须先更新本文、产品约束、工程骨架、质量门禁、签收包和读者测试。

参考：

| 资料 | 用途 |
| --- | --- |
| [Spring Boot Dependency Versions](https://docs.spring.io/spring-boot/appendix/dependency-versions/index.html) | 确认稳定版本线 |
| [Spring Boot System Requirements](https://docs.spring.io/spring-boot/system-requirements.html) | 确认 Maven 兼容要求 |

### 2. 前端版本基线

| 包 | P0 基线 | 版本线 |
| --- | --- | --- |
| Node.js | `20.19+` LTS | 只允许 Node 20 LTS 线内升级 |
| npm | 随 Node 20 LTS | 不切 pnpm/yarn |
| Vue | `3.5.39` | 只允许 Vue 3.5.x patch 升级 |
| Vite | `8.1.3` | 只允许 Vite 8.x 兼容升级 |
| `@vitejs/plugin-vue` | `6.0.7` | 必须与 Vite 8 兼容 |
| TypeScript | `6.0.3` | 只允许 TypeScript 6.0.x patch 升级 |
| Element Plus | `2.14.2` | 只允许 Element Plus 2.14.x patch 升级 |

理由：前端工程若只写 Vue 3、Vite、TypeScript 和 Element Plus，会在创建 `package.json` 时临场选择版本，容易造成 Vite 插件、Node 版本和 UI 组件库不兼容。P0 固定一组可执行版本线，具体安装结果由 `package-lock.json` 锁定。

约束：`frontend/package.json` 必须写入明确版本范围，不使用 `latest`、`*` 或未锁定主版本；`frontend/package-lock.json` 必须提交。若要升级到 Vue 4、Vite 9、TypeScript 7 或 Element Plus 3，必须先更新本文、前端规格、工程骨架、质量门禁、签收包和读者测试。

参考：

| 资料 | 用途 |
| --- | --- |
| [vue npm package](https://www.npmjs.com/package/vue) | 确认 Vue 最新稳定版本 |
| [vite npm package](https://www.npmjs.com/package/vite) | 确认 Vite 最新稳定版本 |
| [@vitejs/plugin-vue npm package](https://www.npmjs.com/package/%40vitejs/plugin-vue) | 确认 Vue SFC 插件版本 |
| [typescript npm package](https://www.npmjs.com/package/typescript) | 确认 TypeScript 稳定版本 |
| [element-plus npm package](https://www.npmjs.com/package/element-plus) | 确认 Element Plus 稳定版本 |

### 3. 后端外部依赖基线

Spring Boot 自身、Web、Validation、Actuator、Redis Starter、Flyway、MySQL Connector 等优先由 Spring Boot `3.5.16` BOM 管理。以下不由 Spring Boot BOM 完全兜底或需要与项目技术选择绑定的依赖，在父 POM 属性中显式锁定。

| 依赖 | P0 基线 | Maven 坐标 | 使用阶段 |
| --- | --- | --- | --- |
| MyBatis-Plus | `3.5.16` | `com.baomidou:mybatis-plus-spring-boot3-starter` | S2/S4 |
| Sa-Token | `1.45.0` | `cn.dev33:sa-token-spring-boot3-starter` | S2 |
| Springdoc OpenAPI | `2.8.17` | `org.springdoc:springdoc-openapi-starter-webmvc-ui` | S2 |
| Velocity | `2.4.1` | `org.apache.velocity:velocity-engine-core` | S4 |

理由：S1 虽然只创建工程骨架，但父 POM 会成为后续阶段的版本源。如果不提前写清楚，S2/S4 很容易在子模块里临时选择版本，造成依赖漂移。Springdoc 选择 `2.8.x` 线是为了贴合 Spring Boot 3.x，避免在 P0 临场切入 Springdoc 3.x 和潜在 Spring Boot 4.x 适配风险。

约束：S1 父 POM可以先声明版本属性和 dependencyManagement，但不得因此提前实现 S2/S4 业务能力；子模块不得散落这些依赖版本。若要升级 MyBatis-Plus 4、Sa-Token 2、Springdoc 3 或 Velocity 3，必须先更新本文、工程骨架、质量门禁、签收包和读者测试。

参考：

| 资料 | 用途 |
| --- | --- |
| [MyBatis-Plus Spring Boot3 Starter - Maven Central](https://central.sonatype.com/artifact/com.baomidou/mybatis-plus-spring-boot3-starter) | 确认 Spring Boot 3 starter 和版本 |
| [Sa-Token Spring Boot3 Starter - Maven Central](https://central.sonatype.com/artifact/cn.dev33/sa-token-spring-boot3-starter) | 确认 Spring Boot 3 starter 和版本 |
| [Springdoc OpenAPI Starter WebMVC UI](https://mvnrepository.com/artifact/org.springdoc/springdoc-openapi-starter-webmvc-ui) | 确认 Spring Boot 3 兼容版本线 |
| [Velocity Engine Core - Maven Central](https://central.sonatype.com/artifact/org.apache.velocity/velocity-engine-core) | 确认 Velocity 稳定版本 |

### 4. 运行时版本策略

运行时和数据库不按前端/npm 依赖那样固定到每个 patch。原因是 JDK、MySQL、Redis 常有安全补丁，发行包需要允许在同一主版本或兼容线内替换。Vibe Boot 的约束是：**源码文档固定版本线，发行包 manifest 固定实际版本和校验值**。

| 运行时 | 文档基线 | 发行包要求 |
| --- | --- | --- |
| JDK | 17 LTS | 记录发行版、完整版本、来源 URL、许可证、SHA256 |
| Maven | 3.8.x | 记录完整版本、来源 URL、许可证、SHA256；不切 Gradle |
| Node.js | 20.19+ LTS | 记录完整版本、npm 版本、来源 URL、许可证、SHA256 |
| MySQL | 8.x | 默认外部连接；记录测试通过的服务端版本和字符集配置 |
| Redis | 7.x 或兼容版本 | 开发包可选内置；生产默认外部连接；记录完整版本和来源 |

约束：源码仓库不提交 JDK/Maven/Node/Redis 二进制。开发发行包和生产包必须提供 `runtime/RUNTIME-MANIFEST.json` 与 `runtime/THIRD-PARTY-NOTICES.txt`，缺少来源、许可证或校验摘要时，不得宣称发行包完整。

### 5. 前端 UI 组件库：Element Plus

| 项目 | 说明 |
| --- | --- |
| 选择 | Element Plus |
| 放弃 | Naive UI |
| 理由 | 国内后台管理项目中 Element Plus 认知更强，表格、表单、弹窗、权限按钮等企业后台组件使用更普遍 |
| 影响 | 前端模板、代码生成、页面规范全部围绕 Element Plus |

约束：首版不允许 Element Plus 和 Naive UI 混用。

### 6. 权限框架：Sa-Token

| 项目 | 说明 |
| --- | --- |
| 选择 | Sa-Token 1.45.0 |
| 放弃 | Spring Security |
| 理由 | Sa-Token 对单体 Admin 项目更轻，国内资料较多，权限注解和会话治理上手成本低 |
| 影响 | `vibe-security` 以 Sa-Token 为基础封装认证、权限、当前用户、数据权限扩展 |

约束：业务代码不能直接散落 Sa-Token 调用，核心能力应通过 `vibe-security` 封装。

### 7. 数据库迁移：Flyway

| 项目 | 说明 |
| --- | --- |
| 选择 | Flyway |
| 放弃 | Liquibase、自研迁移表 |
| 理由 | SQL 文件直观，和 MySQL/Flyway/Spring Boot 集成简单，适合中小企业部署 |
| 影响 | 生成器输出版本化 SQL，生产安装包执行迁移 |

约束：数据库结构变更必须进入 Flyway 迁移文件，不允许散落 SQL。

### 8. Node.js 与包管理器：Node.js 20.19+ LTS + npm

| 项目 | 说明 |
| --- | --- |
| 选择 | Node.js 20.19+ LTS、npm |
| 放弃 | Node.js 22 LTS、pnpm |
| 理由 | Node 20 LTS 更稳；Vite 8 要求 Node 20.19+；npm 随 Node 自带，减少用户理解和环境成本 |
| 影响 | 开发包预置 Node 20.19+，前端提交 `package-lock.json` |

约束：首版不引入多包管理器支持。

### 9. Windows 服务：WinSW

| 项目 | 说明 |
| --- | --- |
| 选择 | WinSW |
| 放弃 | NSSM、纯 PowerShell 后台进程 |
| 理由 | WinSW 专注 Windows 服务封装，配置文件清晰，适合生产安装包 |
| 影响 | 生产包包含 WinSW 可执行文件和服务配置模板 |

约束：开发模式不依赖 WinSW，生产安装时才使用。

### 10. 数据服务策略：外部 MySQL + Redis

| 项目 | 决策 |
| --- | --- |
| MySQL | 开发和生产默认连接外部 MySQL 8 |
| Redis | 开发包可选内置 Redis，生产默认连接外部 Redis |

理由：MySQL 安装和数据目录治理复杂，不适合首版生产包内置。Redis 可作为开发便利选项，但生产应显式连接外部服务。

### 11. ID 策略：雪花 ID

| 项目 | 说明 |
| --- | --- |
| 选择 | 雪花 ID |
| 放弃 | MySQL 自增 ID |
| 理由 | 便于未来数据导入、环境迁移、分库预留，也符合 MyBatis-Plus 常见用法 |
| 影响 | `BaseEntity.id` 使用 Long，生成器默认生成 Long ID |

约束：雪花 ID 生成器封装在公共模块，业务模块不直接依赖具体实现。

### 12. 模板引擎：Velocity

| 项目 | 说明 |
| --- | --- |
| 选择 | Velocity 2.4.1 |
| 放弃 | FreeMarker、Mustache |
| 理由 | Java Admin 代码生成生态中常见，模板语法简单，参考项目已有 Velocity 模板经验 |
| 影响 | `vibe-gen` 模板文件使用 `.vm` |

约束：模板必须保持简单，不在模板中写复杂业务逻辑。

### 13. 测试数据库：本地 MySQL 优先

| 项目 | 说明 |
| --- | --- |
| P0 | 本地 MySQL 8 开发库 |
| P1 | Testcontainers MySQL |
| 放弃 | H2 作为主要测试数据库 |

理由：首版只支持 MySQL 8，使用 H2 容易掩盖方言差异；Testcontainers 对 Windows 用户可能引入 Docker 依赖，因此放到 P1。

### 14. Lombok：P0 不引入

| 项目 | 说明 |
| --- | --- |
| P0 | 不引入 Lombok 依赖，不要求 IDE 安装 Lombok 插件 |
| P1 以后 | 只有在样板代码成本明显高于环境和生成器复杂度时，才重新评估 |
| 放弃 | 默认使用 `@Data`、`@Getter`、`@Setter`、`@Builder` 等 Lombok 注解 |

理由：Vibe Boot 首版强调 Windows 低门槛、可读真实代码和 AI 生成代码可维护。Lombok 能减少样板代码，但会增加 IDE 插件、编译注解处理、生成器模板和新手排错成本。首版实体、DTO、VO 和配置类应使用显式字段、构造方法、getter/setter 或 Java 语言原生能力。

约束：P0 后端模板、手写代码和生成代码不得输出 Lombok 注解；如未来引入，必须先更新本文、产品约束、后端规范、代码生成模板和质量门禁。

## 影响范围

| 文档 | 需要同步 |
| --- | --- |
| `docs/product-constraints.md` | 已收敛决策与延后项更新 |
| `docs/module-design.md` | UI、权限、迁移、ID、模板、测试数据库更新 |
| `docs/windows-devkit-design.md` | Node/npm/runtime 策略更新 |
| `docs/release-package-design.md` | WinSW、外部 MySQL/Redis 更新 |
| `docs/security-governance.md` | Sa-Token、Token 策略更新 |
| `docs/code-generation-design.md` | Velocity、Flyway、雪花 ID 更新 |
| `docs/backend-implementation-spec.md` | Lombok 禁用和 Java Bean 风格更新 |
| `docs/mvp-roadmap.md` | 编码前必须决策更新为已确认 |

## 后续规则

| 规则 | 说明 |
| --- | --- |
| 新增技术依赖 | 必须先修订产品约束或新增 ADR |
| 推翻本 ADR | 必须新增 ADR 或修改本 ADR 状态 |
| 实现不一致 | 以 ADR 为准，除非用户明确要求重新决策 |

## 结论

MVP 首版采用：Spring Boot 3.5.16 + Sa-Token 1.45.0 + MyBatis-Plus 3.5.16 + Flyway + MySQL 8 + Redis + Springdoc OpenAPI 2.8.17 + Velocity 2.4.1 + Vue 3.5.39 + Vite 8.1.3 + TypeScript 6.0.3 + Element Plus 2.14.2 + Node.js 20.19+ LTS + npm + WinSW；P0 不引入 Lombok。

这组选择服务于一个目标：减少技术栈数量，优先保证 Windows 用户可开发、可生成、可验证、可打包、可安装。
