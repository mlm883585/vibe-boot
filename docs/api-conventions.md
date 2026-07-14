# Vibe Boot API 与错误码规范

## 1. 文档目的

本文定义 Vibe Boot 后端 REST API、统一响应、分页、错误码、权限标识、审计字段和前端 API 文件的规范。后续人工编码和 AI 代码生成都必须遵守本文。

## 2. API 基本原则

| 原则 | 说明 |
| --- | --- |
| REST 风格 | 资源使用名词，动作通过 HTTP Method 表达 |
| 统一前缀 | 管理端 API 统一以 `/api` 开头 |
| 统一响应 | 所有业务接口返回 `Result<T>` |
| 统一分页 | 分页接口返回 `PageResult<T>` |
| 权限强校验 | 除公开接口外必须有权限注解 |
| 错误可读 | 错误码稳定，错误信息中文友好 |
| 前后端同源 | 前端 API 文件按后端资源组织 |
| 并发可控 | 更新携带版本号，状态变更校验预期状态，冲突不得静默覆盖 |

## 3. 路径规范

| 类型 | 规范 | 示例 |
| --- | --- | --- |
| 管理端 API | `/api/{domain}/{resources}` | `/api/system/users` |
| 分页查询 | `/api/{domain}/{resources}/page` | `/api/biz/customer-visits/page` |
| 详情 | `/api/{domain}/{resources}/{id}` | `/api/biz/customer-visits/1001` |
| 创建 | POST `/api/{domain}/{resources}` | POST `/api/biz/customer-visits` |
| 更新 | PUT `/api/{domain}/{resources}/{id}` | PUT `/api/biz/customer-visits/1001` |
| 删除 | DELETE `/api/{domain}/{resources}/{id}` | DELETE `/api/biz/customer-visits/1001` |
| 导出 | POST `/api/{domain}/{resources}/export` | POST `/api/biz/customer-visits/export` |

命名约束：

| 对象 | 规范 |
| --- | --- |
| URL path | kebab-case，复数资源 |
| Java 类 | PascalCase |
| Java 字段 | camelCase |
| 数据库字段 | snake_case |
| 前端文件 | camelCase 或 kebab-case，按目录统一 |

## 4. HTTP Method 规范

| Method | 用途 | 是否幂等 |
| --- | --- | --- |
| GET | 查询、详情 | 是 |
| POST | 创建、复杂查询、导出 | 默认否；明确的动作接口按业务状态判定 |
| PUT | 全量/主要字段更新 | 是 |
| PATCH | 局部更新，P1 再使用 | 默认否，只有明确设计为幂等时才可标记为是 |
| DELETE | 逻辑删除 | 是 |

首版 P0 不强制使用 PATCH，降低复杂度。

这里的“幂等”表示相同请求重复执行后资源最终状态一致，不表示每次响应必须完全相同。PUT、DELETE 和状态动作仍必须做权限、版本、当前状态和数据范围校验；不得因为 HTTP Method 被标记为幂等就跳过业务校验。

## 5. 统一响应

`Result<T>` 结构：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| code | String | 业务状态码 |
| message | String | 中文提示 |
| data | T | 响应数据 |
| success | Boolean | 是否成功 |
| traceId | String | 请求追踪 ID |
| timestamp | Long | 响应时间戳 |

成功示例：

```json
{
  "code": "0",
  "message": "成功",
  "success": true,
  "data": {},
  "traceId": "20260628153000001",
  "timestamp": 1782631800000
}
```

失败示例：

```json
{
  "code": "AUTH_0403",
  "message": "没有操作权限",
  "success": false,
  "data": null,
  "traceId": "20260628153000002",
  "timestamp": 1782631800000
}
```

### 5.1 traceId 契约

| 项目 | P0 约束 |
| --- | --- |
| 生成方 | 后端入口过滤器为每个 HTTP 请求生成，不由 Controller 或业务代码自行生成 |
| 格式 | 32 位小写十六进制字符串；使用 JDK UUID 去除连字符即可，不增加依赖 |
| 返回位置 | 统一响应体 `traceId` 和响应头 `X-Trace-Id` 必须一致 |
| 日志上下文 | 请求处理期间写入 MDC，异步任务显式复制或生成自己的 traceId，结束后清理 |
| 客户端输入 | P0 不接受客户端覆盖服务端 traceId，避免日志注入和伪造；客户端只能把上次响应值用于报障 |
| 外部供应商 ID | 模型供应商 requestId 单独保存和脱敏展示，不替代平台 traceId |

Actuator 标准健康响应不包装 `Result<T>`，但仍应返回 `X-Trace-Id`。静态前端资源不要求生成 traceId。

二进制下载、图片预览和未来的导出流不包装 `Result<T>`：成功时返回对应 Content-Type、Content-Disposition 和 `X-Trace-Id`；在响应尚未提交前发现权限、状态或不存在错误时返回统一 JSON 错误和真实 4xx/5xx。流已经开始后发生 I/O 错误时只能中止连接并记录 traceId，不得继续拼接 JSON 到二进制响应。

## 6. 分页规范

请求参数：

| 参数 | 类型 | 默认 | 说明 |
| --- | --- | --- | --- |
| pageNo | Integer | 1 | 页码 |
| pageSize | Integer | 10 | 每页数量 |
| sortField | String | 空 | 排序字段 |
| sortOrder | String | 空 | asc/desc |

`PageResult<T>` 结构：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| records | List<T> | 当前页数据 |
| total | Long | 总条数 |
| pageNo | Integer | 当前页 |
| pageSize | Integer | 每页大小 |
| pages | Long | 总页数 |

约束：

| 约束 | 说明 |
| --- | --- |
| pageSize 上限 | 默认最大 200，防止大查询 |
| 排序字段白名单 | 禁止前端传任意 SQL 字段 |
| 时间范围 | 使用 start/end 或 begin/end 成对字段 |

## 7. 错误码规范

错误码格式：

```text
{DOMAIN}_{CODE}
```

| DOMAIN | 说明 |
| --- | --- |
| SYS | 系统通用 |
| AUTH | 认证授权 |
| VALID | 参数校验 |
| DATA | 数据访问 |
| AI | AI 模型与任务 |
| GEN | 代码生成 |
| FILE | 文件 |
| INSTALL | 安装/脚本 |
| BIZ | 业务模块 |

常用错误码：

| 错误码 | HTTP | 说明 |
| --- | --- | --- |
| `0` | 200 | 成功 |
| `SYS_0500` | 500 | 系统异常 |
| `VALID_0400` | 400 | 参数校验失败 |
| `AUTH_0401` | 401 | 未登录或登录失效 |
| `AUTH_0403` | 403 | 没有权限 |
| `AUTH_0409` | 409 | 必须先修改初始或重置密码 |
| `AUTH_0429` | 429 | 登录尝试过于频繁 |
| `DATA_0404` | 404 | 数据不存在 |
| `DATA_0409` | 409 | 数据已变化、唯一键冲突或当前状态不允许操作 |
| `AI_0501` | 500 | 模型调用失败 |
| `AI_0409` | 409 | AI 使用准入卡未通过 |
| `AI_0413` | 413 | 模型上下文或所选文件内容超过限制 |
| `GEN_0409` | 409 | 生成文件冲突 |
| `INSTALL_0500` | 500 | 安装或脚本执行失败 |
| `FILE_0400` | 400 | 文件为空、文件名非法或内容与类型不一致 |
| `FILE_0403` | 403 | 没有文件访问权限 |
| `FILE_0404` | 404 | 文件记录或物理文件不存在 |
| `FILE_0409` | 409 | 文件状态不允许操作或该类型不支持预览 |
| `FILE_0413` | 413 | 文件或 multipart 请求超过限制 |
| `FILE_0500` | 500 | 文件写入、移动或删除失败 |
| `FILE_0507` | 507 | 文件配额或磁盘保留空间不足 |

约束：

| 约束 | 说明 |
| --- | --- |
| 错误码稳定 | 前端可依赖 |
| 错误信息中文 | 面向中国用户 |
| 不泄漏敏感信息 | 不返回 SQL、密钥、服务器绝对路径 |
| traceId 必须有 | 便于日志定位 |
| 四位数字段 | 除成功码 `0` 外，业务码数字部分固定为四位，并与主要 HTTP 状态对应，例如 `0409`、`0500` |
| HTTP 状态一致 | 失败响应使用真实 4xx/5xx，不得全部返回 HTTP 200；响应体 code 提供稳定业务分类 |
| 未知异常收敛 | 未预期异常只返回 `SYS_0500` 和通用中文提示，详细堆栈只进入受控日志 |

健康接口例外：`/actuator/health`、`/actuator/health/liveness`、`/actuator/health/readiness` 保持 Spring Boot Actuator 标准响应，不使用统一业务包装；`/api/system/health` 仍使用统一业务响应。后者完成检查时固定返回 HTTP 200，并通过 `data.status=HEALTHY|DEGRADED|UNAVAILABLE` 表达系统状态；接口自身执行异常才返回 `SYS_0500`。

文件接口约束：上传响应和文件列表只能返回文件 ID、原始名称、扩展名、声明后的安全 contentType、大小、SHA256、状态、创建人和创建时间；不得返回 `relativePath`、storage root、临时路径或服务器绝对路径。下载文件名使用安全的 `Content-Disposition` 编码，禁止直接拼接原始文件名到响应头。

## 8. 参数校验规范

| 场景 | 规范 |
| --- | --- |
| 创建 | `CreateDTO` + 创建校验组 |
| 更新 | `UpdateDTO` + 更新校验组 |
| 查询 | `Query` 对象 |
| ID | Long，雪花 ID |
| 枚举 | 使用明确枚举值，不使用魔法数字 |
| 字符串 | 明确长度 |
| 时间 | ISO 格式或统一后端解析 |

校验失败返回 `VALID_0400`。

### 8.1 并发、重复提交与幂等

P0 不引入分布式锁、消息队列或通用幂等中间件。单体单实例下使用数据库唯一约束、乐观锁和状态条件更新完成最小并发保护。

| 场景 | P0 契约 |
| --- | --- |
| 普通创建 POST | 不承诺通用幂等；前端提交期间禁用按钮，后端用业务唯一索引兜底，重复创建返回 `DATA_0409` |
| 普通更新 PUT | `UpdateDTO` 必须携带当前 `version`；更新条件包含 `id + version + deleted=0`，成功后 version 原子加一 |
| 更新零行 | 先按 id 和数据范围判断：不存在返回 `DATA_0404`，存在但版本变化返回 `DATA_0409` |
| 删除 DELETE | 重复删除保持最终“已删除”状态；首次删除必须校验权限和数据范围，已删除再次请求可返回成功且不得重复产生业务副作用 |
| 状态动作 POST | 请求必须表达或由服务端固定预期状态，使用条件更新；状态已达到目标可按接口约定返回成功，其他状态冲突返回 `DATA_0409` |
| 关联关系保存 | 在一个事务内按目标集合重建或差量更新，唯一索引防止重复关系；重复提交结果一致 |
| 文件上传 | 默认不幂等，不按 SHA256 跨用户去重；每次成功上传产生新的文件记录 |
| 模型调用/AI 任务 | 不自动重放供应商调用；超时结果不明时记录失败或待确认，用户重试创建新的调用记录 |

P0 不开放通用 `Idempotency-Key`。后续若支付、外部回调或跨进程任务需要请求级去重，必须先补充 ADR，明确 key 的作用域、持久化、过期、响应重放和并发语义。

## 9. 权限规范

权限标识：

```text
{domain}:{resource}:{action}
```

示例：

| 动作 | 权限 |
| --- | --- |
| 列表 | `biz:customerVisit:list` |
| 详情 | `biz:customerVisit:query` |
| 新增 | `biz:customerVisit:create` |
| 编辑 | `biz:customerVisit:update` |
| 删除 | `biz:customerVisit:delete` |
| 导出 | `biz:customerVisit:export` |

约束：

| 约束 | 说明 |
| --- | --- |
| 新接口默认需要权限 | 公开接口必须显式说明 |
| 前端按钮权限同源 | 使用相同权限标识 |
| 代码生成必须生成权限 | 菜单、按钮、Controller 一起生成 |
| 动作命名 | 简单动作使用小写动词；复合动作使用 lowerCamelCase，例如 `resetPassword`、`assignRoles` |

### 9.1 AI 使用准入卡 API 字段

AI 任务、代码生成任务和外部 AI 交接包接口如返回可执行计划，必须包含 `admissionCard` 字段。字段使用 lowerCamelCase，值可存为对象或 JSON 快照。

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `codingAllowed` | Boolean | 当前签收和阶段启动是否允许编码 |
| `taskStage` | String | S1-S7 或后续已签收阶段 |
| `executionEntry` | String | `external-ai`、`workbench`、`production-business-ai` 等 |
| `contextReady` | Boolean | 上下文是否完整 |
| `riskConfirmed` | Boolean | 风险是否已确认或无需确认 |
| `verificationReady` | Boolean | 验证命令是否明确或有免测原因 |
| `productionBoundarySafe` | Boolean | 是否不包含生产开发型 AI 或生产执行入口 |
| `result` | String | `pass` 或 `fail` |
| `reason` | String | 中文原因，失败时必填 |

约束：

| 约束 | 说明 |
| --- | --- |
| `result=fail` 不得进入实现 | API 应返回 `AI_0409` 或让任务保持待补充状态 |
| 不替代签收记录 | 即使 `admissionCard.result=pass`，也仍要满足签收记录和启动口令 |
| 不记录密钥 | `reason` 和上下文摘要不得包含 API Key、数据库密码或生产密钥 |

## 10. OpenAPI 规范

| 项目 | 规范 |
| --- | --- |
| 工具 | Springdoc OpenAPI 2.8.17 |
| 标题 | Vibe Boot API |
| 分组 | system、ai、gen、file、biz |
| 环境 | 开发默认开启，生产可关闭 |
| 注释 | Controller、DTO、VO 必须有中文说明 |

## 11. 前端 API 文件规范

路径：

```text
frontend/src/api/{domain}/{resource}.ts
```

示例：

```text
frontend/src/api/biz/customerVisit.ts
```

函数命名：

| 后端动作 | 前端函数 |
| --- | --- |
| page | `pageCustomerVisit` |
| detail | `getCustomerVisit` |
| create | `createCustomerVisit` |
| update | `updateCustomerVisit` |
| delete | `deleteCustomerVisit` |
| export | `exportCustomerVisit` |

## 12. 审计与日志

关键操作必须记录操作日志：

| 操作 | 是否记录 |
| --- | --- |
| create | 是 |
| update | 是 |
| delete | 是 |
| export | 是 |
| login | 登录日志 |
| AI task | AI 审计 |

日志不得记录明文密码、API Key、Token。

## 13. AI 生成 API 的额外约束

AI 生成接口时必须输出：

| 内容 | 说明 |
| --- | --- |
| 接口清单 | Method + Path |
| 权限清单 | 每个接口对应权限 |
| DTO/VO 清单 | 入参与出参 |
| 错误码 | 可能错误 |
| 验证方式 | 如何测试 |

不允许：

| 禁止 | 原因 |
| --- | --- |
| 生成无权限接口 | 安全风险 |
| 直接返回 Entity | 容易泄漏字段 |
| 返回不统一结构 | 前端处理复杂 |
| 暴露异常堆栈 | 安全风险 |

## 14. 编码准入

进入 Controller/API 编码前必须确认：

| 条件 | 状态 |
| --- | --- |
| API 路径规范 | 已由本文确认 |
| Result/PageResult 结构 | 已由本文确认 |
| 错误码格式 | 已由本文确认 |
| 权限标识格式 | 已由 ADR-0002 和本文确认 |
| 并发与幂等 | 已由本文确认，P0 使用唯一约束、乐观锁和状态条件更新 |
| traceId | 已由本文确认，服务端生成并同时写入响应体、响应头和日志上下文 |
| 前端 API 文件命名 | 已由本文确认 |

## 15. 一句话总结

Vibe Boot 的 API 规范目标是让人工代码和 AI 生成代码长得像同一个系统：路径统一、响应统一、错误统一、权限统一、前后端调用统一。
