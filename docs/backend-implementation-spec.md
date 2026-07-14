# Vibe Boot 后端实现规范

## 1. 文档目的

本文定义 Vibe Boot 后端 Java/Spring Boot 实现规范，覆盖分层结构、Controller、Service、Mapper、DTO/VO、异常、事务、权限、数据权限、配置、日志、Actuator 和代码生成约束。

它补充 `docs/module-design.md`、`docs/api-conventions.md`、`docs/database-baseline.md` 和 `docs/security-governance.md`，用于约束人工编码和 AI 生成的后端代码风格。

## 2. 基本原则

| 原则 | 说明 |
| --- | --- |
| 分层清晰 | Controller、Service、Mapper、Entity、DTO/VO 各司其职 |
| 业务可读 | 代码优先清楚，不追求复杂抽象 |
| 权限强校验 | 除公开接口外，后端接口必须校验权限 |
| 数据可审计 | 创建、修改、删除、导出、AI 任务必须记录 |
| 事务明确 | 写操作在 Service 层控制事务 |
| 异常统一 | 不向前端暴露堆栈、SQL、密钥和服务器路径 |
| AI 友好 | 命名、包结构、模板输出必须稳定一致 |

## 3. 后端分层

标准调用链：

```text
Controller -> Service -> Mapper -> Database
     |           |          |
    DTO         Entity     SQL/MyBatis-Plus
     |
     -> VO
```

| 层 | 职责 | 禁止 |
| --- | --- | --- |
| Controller | 接收参数、鉴权、调用 Service、返回 Result | 写业务逻辑、直接调用 Mapper |
| Service | 业务规则、事务、数据权限、审计触发 | 返回未脱敏敏感数据 |
| Mapper | MyBatis-Plus 数据访问 | 写复杂业务判断 |
| Entity | 数据库字段映射 | 直接暴露给前端 |
| DTO | 创建/更新入参 | 混入数据库内部字段 |
| Query | 查询条件 | 拼接原始 SQL |
| VO | 前端响应 | 包含密码、密钥、Token 等敏感字段 |

## 4. 包结构

每个业务模块遵守 `docs/module-design.md`。

```text
com.vibeboot.<module>/
├── controller/
├── service/
├── service/impl/
├── mapper/
├── entity/
├── dto/
├── vo/
├── query/
├── convert/
├── enums/
├── config/
└── support/
```

约束：

| 约束 | 说明 |
| --- | --- |
| `support` 不跨模块复用 | 需要跨模块复用时上移到 common 或定义接口 |
| `convert` 统一对象转换 | P0 可手写，P1 再评估 MapStruct |
| Mapper 不跨模块注入 | 跨模块访问通过 Service 或应用服务接口 |
| Starter 只负责装配 | 业务代码不依赖 starter |

## 5. Controller 规范

| 项目 | 规范 |
| --- | --- |
| 注解 | `@RestController`、`@RequestMapping`、参数校验注解 |
| 响应 | 统一返回 `Result<T>` 或 `Result<PageResult<T>>` |
| 入参 | 创建/更新用 DTO，查询用 Query |
| 出参 | 使用 VO，不返回 Entity |
| 权限 | 除公开接口外必须声明权限 |
| OpenAPI | Controller、DTO、VO 使用中文说明 |

Controller 只能处理：

| 允许 | 说明 |
| --- | --- |
| 参数接收和校验 | 基础校验、路径参数 |
| 当前用户上下文传递 | 通过 security 封装获取 |
| 调用 Service | 不绕过 Service |
| 返回统一响应 | 不自行拼 JSON |

Controller 禁止：

| 禁止 | 原因 |
| --- | --- |
| 直接调用 Mapper | 绕过业务规则和权限 |
| 捕获所有异常后返回字符串 | 破坏统一异常 |
| 返回 Entity | 容易泄漏字段 |
| 暴露异常堆栈 | 安全风险 |
| 散落 Sa-Token 原始调用 | 应通过 `vibe-security` 封装 |

## 5.1 Java 类与 Lombok 约束

P0 不引入 Lombok。后端实体、DTO、VO、配置属性类、异常类和测试辅助类都应保持普通 Java 代码，避免依赖 IDE 插件或注解处理器才能理解字段、构造方法和访问器。

| 约束 | 说明 |
| --- | --- |
| 不使用 Lombok 注解 | 禁止 `@Data`、`@Getter`、`@Setter`、`@Builder`、`@AllArgsConstructor`、`@NoArgsConstructor` 等 |
| DTO/VO 访问器显式可见 | 使用普通 getter/setter，便于 AI、代码生成器和新手开发者直接阅读 |
| 构造方法保持克制 | 简单对象优先无参构造加 setter；复杂不可变对象再按阶段设计 |
| 未来引入需 ADR | P1 以后若要引入 Lombok，必须先更新 ADR-0001、产品约束、生成模板和质量门禁 |

## 6. Service 规范

Service 是业务规则和事务边界。

| 项目 | 规范 |
| --- | --- |
| 接口 | `XxxService` |
| 实现 | `XxxServiceImpl` |
| 事务 | 写操作在 Service 实现层声明 |
| 数据权限 | 查询前应用统一数据范围 |
| 审计 | 关键操作触发操作日志 |
| 并发 | 更新使用 version，状态流转使用预期状态条件更新 |
| 返回 | 返回 VO 或业务对象，不返回敏感 Entity |

事务规则：

| 场景 | 规则 |
| --- | --- |
| 新增/修改/删除 | 必须有事务 |
| 批量导入/批量删除 | 必须有事务和失败策略 |
| 只读查询 | 可标记只读事务或不加事务 |
| 跨模块写操作 | 必须谨慎，必要时拆分应用服务 |
| 外部模型/API 调用 | 不应长时间占用数据库事务 |

事务与并发细则：

| 场景 | 规则 |
| --- | --- |
| 回滚 | 事务方法抛出运行时异常时回滚；不得捕获异常后伪装成功或吞掉异常导致提交 |
| 事务入口 | `@Transactional` 放在可被 Spring 代理调用的 Service 公共方法上，禁止依赖同类自调用触发事务 |
| 唯一性 | 先做友好校验，数据库唯一索引仍是最终并发防线；唯一键异常映射为 `DATA_0409` |
| 普通更新 | UpdateDTO 携带 version，SQL 条件包含 id、version 和 deleted=0，version 原子加一 |
| 状态流转 | 使用 `where id=? and status in (...)` 条件更新，不采用“先查再无条件写” |
| 外部 I/O | 模型、HTTP、文件系统和脚本调用不得包在长事务中；使用短事务记录开始/完成/失败状态 |
| 分布式锁 | P0 普通 CRUD 禁止为并发保护引入 Redis 锁；数据库约束和条件更新足够 |

## 7. Mapper 与 MyBatis-Plus

| 项目 | 规范 |
| --- | --- |
| Mapper | 继承 MyBatis-Plus BaseMapper 或项目封装基类 |
| XML | 简单 CRUD 可不用 XML，复杂查询使用 XML |
| 分页 | 使用统一分页模型转换 |
| 排序 | 排序字段必须白名单 |
| 逻辑删除 | 使用统一 `deleted` 字段 |
| 乐观锁 | P0 用于可编辑主记录；是否使用 MyBatis-Plus 插件由工程统一配置，不允许模块各自实现不同语义 |

禁止：

| 禁止 | 原因 |
| --- | --- |
| 字符串拼接 SQL | SQL 注入风险 |
| 前端传入任意排序字段 | SQL 注入和性能风险 |
| Mapper 写业务分支 | 难测试、难审计 |
| 物理删除业务数据 | P0 默认逻辑删除 |

## 8. DTO、Query、VO

| 类型 | 规则 |
| --- | --- |
| CreateDTO | 只包含创建可填写字段 |
| UpdateDTO | 包含更新字段，可包含 id 或由 path 传入 |
| Query | 分页、搜索、排序、时间范围 |
| VO | 前端展示字段，Long ID 使用字符串兼容前端 |
| Entity | 只做数据库映射，不返回前端 |

校验规则：

| 场景 | 规则 |
| --- | --- |
| 必填 | `@NotNull`、`@NotBlank` |
| 长度 | `@Size` |
| 数字范围 | `@Min`、`@Max`、`@DecimalMin` |
| 枚举 | 使用明确枚举值或字典 |
| 时间范围 | begin/end 成对校验 |
| 更新版本 | 可编辑记录的 UpdateDTO 必须包含 `@NotNull version`，VO 必须返回当前 version |

## 9. 统一异常

异常处理应由全局异常处理器统一转换为 `Result<T>`。

| 异常 | 错误码 |
| --- | --- |
| 参数校验失败 | `VALID_0400` |
| 未登录 | `AUTH_0401` |
| 无权限 | `AUTH_0403` |
| 数据不存在 | `DATA_0404` |
| 数据冲突 | `DATA_0409` |
| 模型调用失败 | `AI_0501` 或 `model-gateway-spec.md` 细分错误码 |
| 生成文件冲突 | `GEN_0409` |
| 系统异常 | `SYS_0500` |

异常响应必须包含 traceId，且错误信息中文可读。

全局异常处理器必须区分参数错误、认证授权、数据不存在、唯一键/乐观锁/状态冲突和未知系统异常。失败响应使用对应 HTTP 状态，不得把所有异常包装成 HTTP 200；数据库异常、SQL、约束名和堆栈不得返回前端。

## 10. 权限与认证

权限框架已由 ADR-0001 确认为 Sa-Token 1.45.0，但业务模块不得直接散落框架调用。

| 能力 | 落点 |
| --- | --- |
| 登录认证 | `vibe-security` |
| 当前用户 | `vibe-security` 封装 |
| 权限校验 | 注解或统一校验封装 |
| 数据权限 | `vibe-security` 扩展点 |
| 会话策略 | Sa-Token + Redis 不透明随机 Token；浏览器只使用 HttpOnly Cookie，开发可退回本地内存存储 |

认证实现必须集中在 `vibe-security`：密码哈希、账号/IP 限流、Cookie 属性、Origin/CSRF 校验、会话绝对/空闲超时和全部会话失效不得散落到业务 Controller。P0 不使用 JWT、不引入 Token Secret，也不得使用 Sa-Token 的 MD5/SHA 快速摘要作为密码存储算法；具体参数以 `docs/security-governance.md` 第 4 节为准。

权限标识遵守：

```text
{domain}:{resource}:{action}
```

公开接口必须显式说明原因，不能因为忘记加权限而默认公开。

## 11. 数据权限

P0 提供统一表达和扩展点，业务查询必须能接入。

| 数据范围 | 规则 |
| --- | --- |
| 全部数据 | 管理员角色 |
| 本部门 | 当前用户 deptId |
| 本部门及下级 | 部门树 |
| 仅本人 | createdBy 或业务 ownerUserId |
| 自定义部门 | P1 |

AI 生成查询时必须说明使用的数据范围；如果基础能力未完成，生成摘要必须提示限制。

## 12. 审计日志

| 操作 | 日志 |
| --- | --- |
| 登录成功/失败 | 登录日志 |
| 登出 | 登录日志或操作日志 |
| 新增/修改/删除 | 操作日志 |
| 导出 | 操作日志 |
| 权限变更 | 操作日志，高价值审计事件 |
| 模型配置变更 | 操作日志 |
| AI 任务 | AI 审计 |

日志禁止记录明文密码、API Key、Token、数据库密码。

## 13. 配置与 Profile

| 文件 | 说明 |
| --- | --- |
| `application.yml` | 通用配置 |
| `application-dev.yml` | 开发配置 |
| `application-prod.yml` | 生产模板 |
| `config/application-local.yml` | 本地密钥和覆盖配置，不提交 |
| `config/model.local.yml` | 本地模型配置，不提交 |

约束：

| 约束 | 说明 |
| --- | --- |
| 配置缺失中文提示 | 面向中国用户 |
| 生产配置外置 | 不打入 jar |
| 密钥不打印 | 日志和接口都脱敏 |
| 开发/生产能力分离 | 生产禁用开发型 AI 能力 |

## 14. 本地文件实现约束

`vibe-file` 必须遵守 ADR-0002，不得把 Controller 直接写盘或把 storage path 暴露给其他模块。

| 层 | 约束 |
| --- | --- |
| Controller | 只接收 multipart `file` 和文件 ID；不接受目录、相对路径、磁盘文件名或 contentType 覆盖参数 |
| Service | 负责权限外的业务状态、配额预留、流式计数、SHA256、类型校验、短事务状态切换和失败清理 |
| Storage | 只接收服务端 storageKey；使用 JDK NIO，真实根路径 + normalize + startsWith，并拒绝 symlink/junction/reparse point |
| Metadata | relativePath 只在 `vibe-file` 内部使用，不进入 VO、日志、审计详情或 AI 上下文 |
| Multipart | Spring `max-file-size=20MB`、`max-request-size=25MB` 与应用层限制保持一致；应用仍需流式复查，禁止 `MultipartFile.getBytes()` 整体载入 |
| 响应 | 下载强制 attachment；图片预览设置 inline、nosniff、private/no-store；原始文件名必须安全编码 |
| 删除 | 文件 I/O 不占用长事务，使用 uploading/active/failed/deleting/delete_failed/deleted 状态机 |

文件类型校验使用 JDK/Jackson 已有能力完成，不为 P0 引入 Tika、ClamAV、MinIO SDK 或 Office 解析依赖。若实现需要新增依赖，必须先按 C2/C3 修订 ADR 和签收材料。

## 15. Actuator 与健康检查

P0 健康检查遵守 ADR-0002。

| 端点 | 用途 |
| --- | --- |
| `/actuator/health/liveness` | 只判断 JVM 和应用进程，不检查外部依赖 |
| `/actuator/health/readiness` | 判断 MySQL、生产 Redis、文件目录和 Flyway schema 是否可支撑业务流量 |
| `/actuator/health` | readiness 聚合摘要，仅供本机诊断 |
| `/api/system/health` | 登录后的脱敏检查明细，要求 `system:health:info` 权限 |

实现约束：

| 约束 | 说明 |
| --- | --- |
| Actuator 不套业务响应 | 保留 `{"status":"UP"}` 等标准格式，便于脚本解析 |
| 网络限制 | `/actuator/**` 仅接受回环地址请求，P0 不经反向代理公开 |
| 最小暴露 | 只开放 health 相关端点，禁止 env、configprops、beans、mappings、heapdump、threaddump |
| liveness 不查依赖 | 数据库或 Redis 故障不能触发服务重启循环 |
| readiness 必需项 | 生产 MySQL、Redis、文件目录可写和迁移状态任一失败即返回 503 |
| 系统接口聚合 | `HEALTHY`、`DEGRADED`、`UNAVAILABLE` 三态，检查完成时 HTTP 200 |
| 超时和只读 | 单项 2 秒、总计 5 秒；不得写库、扫全表或调用模型供应商 |
| 信息脱敏 | 不暴露连接串、数据库名、用户名、主机名、Redis Key、服务器绝对路径、配置值、堆栈或原始供应商错误 |

S1 只建立 Actuator liveness/readiness；`/api/system/health` 必须等 S2 的登录和权限能力完成后再实现。不得为了让 S1 骨架通过而创建临时匿名详细诊断接口。

## 16. 代码生成后端模板约束

AI 或生成器输出后端代码时必须遵守本文。

| 生成项 | 规范 |
| --- | --- |
| Entity | 包含基础字段、逻辑删除、表注释对应 |
| DTO | 创建/更新分离，带校验 |
| Query | 分页、搜索、排序白名单 |
| VO | 不暴露敏感字段 |
| Controller | 统一路径、统一响应、权限标识 |
| Service | 写操作事务、业务校验 |
| Mapper | 不拼接危险 SQL |
| Migration SQL | Flyway 版本化 |
| Tests | P1 生成 Controller/Service 测试 |

生成后端代码还必须满足可接管要求：

| 要求 | 说明 |
| --- | --- |
| 不留 TODO 占位 | 生成的 Controller、Service、Mapper 不得包含未实现分支 |
| 不返回 Entity | 生成接口必须使用 VO |
| 不绕过 Service | Controller 不直接调用 Mapper |
| 不静默物理删除 | 删除默认走 Service 逻辑删除和引用校验 |
| 不硬编码当前用户 | 必须通过 `vibe-security` 当前用户封装 |
| 不散落权限字符串 | 权限来自元模型和菜单权限记录 |
| 人工修改可保留 | 二次生成不能静默覆盖用户已修改的 Java 文件 |

## 17. S1 与 S2 边界

| 阶段 | 后端实现范围 |
| --- | --- |
| S1 | Maven 多模块、启动类、配置、健康检查、脚本可启动 |
| S2 | 登录、用户、角色、菜单、部门、字典、日志、权限、本地文件基础服务、系统健康明细 |
| S3 | 模型配置、模型调用、用量记录 |
| S4 | 代码生成、元模型、客户拜访记录 |

S1 不实现本文中的完整业务规范，只搭后续能承接这些规范的结构。

## 18. 质量门禁

后端代码修改后必须遵守 `docs/quality-gates.md`。

| 场景 | 验证 |
| --- | --- |
| 后端 Java 修改 | `mvn -pl vibe-starter -am test` 或快速构建 |
| 数据库迁移 | Flyway 执行或启动验证 |
| 权限修改 | 接口权限和菜单权限检查 |
| 安全核心修改 | L3 风险，二次确认 |

## 19. 编码准入

进入后端编码前必须确认：

| 条件 | 状态 |
| --- | --- |
| 后端模块边界 | 已由 `docs/module-design.md` 确认 |
| API 规范 | 已由 `docs/api-conventions.md` 确认 |
| 数据库基线 | 已由 `docs/database-baseline.md` 确认 |
| 权限框架 | 已由 ADR-0001 确认为 Sa-Token 1.45.0 |
| 质量门禁 | 已由 `docs/quality-gates.md` 确认 |
| 后端实现规范 | 已由本文确认 |

## 20. 一句话总结

Vibe Boot 后端实现要保持克制和一致：Controller 薄、Service 稳、Mapper 简、DTO/VO 清楚、权限和异常统一、事务和审计前置，让人工代码和 AI 生成代码看起来像同一个工程。
