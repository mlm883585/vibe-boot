# Vibe Boot

Vibe Boot 是一个面向中国中小企业、Windows 优先的 AI 原生模块化单体应用底座。用户在真实的 Java/Vue 工程上持续迭代业务系统，平台提供模型网关、AI 工作台、Skills/规则、质量门禁和生产安装包能力，而不是把业务锁在低代码运行时中。

## 当前状态

| 项目 | 状态 |
| --- | --- |
| 当前阶段 | 技术文档与机器契约已达到签收基线，等待维护者人工签收 |
| 源码状态 | 尚未创建 `backend/`、`frontend/`、`scripts/`、`config/` |
| 编码许可 | **未授权**；文档完整不等于允许编码 |
| 机器契约 | 代码生成元模型与 Windows 安装配置均有 Draft 2020-12 JSON Schema 和标准样例 |
| 文档入口 | [`docs/README.md`](docs/README.md) |
| 当前签收记录 | [`docs/coding-start-signoff.md`](docs/coding-start-signoff.md) |

## 冻结基线

| 领域 | P0 选择 |
| --- | --- |
| 后端 | JDK 17、Spring Boot 3.5.16、Maven 3.8.x、MyBatis-Plus、Sa-Token、Flyway |
| 数据 | 外部 MySQL 8；开发默认内存会话并可连接外部 Redis，生产强制外部 Redis 7 或兼容服务 |
| 前端 | Vue 3.5.39、Vite 8.1.3、TypeScript 6.0.3、Element Plus、npm、Node.js 24.x LTS |
| 交付 | Windows 开发包 + Spring Boot 静态资源 + Apache Commons Daemon Procrun 1.6.1 生产安装包 |
| AI | 外部 AI Coding 工具负责工程施工；平台 AI 工作台负责需求、计划、风险与交接；生产只开放白名单业务 AI |

## 编码闸门

开始 S1 前必须同时完成签收基线、最终审查、维护者签名和 S1 开工检查，并收到逐字一致的口令 `开始 S1 工程骨架编码`。任何近义表达、AI 推断或任务状态都不能替代授权；后续 S2-S7 也必须按 [`docs/post-coding-change-control.md`](docs/post-coding-change-control.md) 单独准入。

`reference/` 只用于本地竞品与参考项目研究，已加入 Git 忽略列表，不属于产品源码或交付物。
