# ADR-0002：MVP 实现契约决策

## 状态

Accepted

## 日期

2026-06-28

## 背景

ADR-0001 已确认 MVP 首版技术栈。进入编码前，还需要收敛各设计文档中的实现契约，例如 AI 任务状态机、模型配置字段、Patch 应用方式、验证命令、生产配置、健康检查、Skill 格式和端口规划。

这些决策不一定是最终形态，但作为 MVP 首版默认契约，后续编码必须遵守。

## 决策总表

| 领域 | 决策 |
| --- | --- |
| AI 任务状态机 | `draft -> planned -> confirmed -> applying -> verifying -> completed/failed/reverted` |
| 模型配置字段 | 使用 `providerCode/apiBase/apiKeyEncrypted/modelName/modelType/enabled/timeoutSeconds/maxTokens` |
| Patch 应用方式 | P0 开发工作区内的本地受控文件系统补丁，所有变更先生成 diff；生产与平台服务端不提供任意文件写入 |
| 验证命令 | 后端 `mvn -pl vibe-starter -am test`，前端 `npm run build`，打包 `build-prod.ps1` |
| 生产禁用策略 | 生产 profile 默认禁用代码修改、脚本执行、数据库结构修改 |
| 生成元模型 | P0 使用数据库表 + JSON 快照 |
| 权限标识 | `模块:资源:动作`，例如 `biz:customerVisit:create` |
| API 并发控制 | P0 可编辑主记录使用 version 乐观锁；状态机使用预期状态条件更新；唯一索引作为最终并发防线 |
| API 重复提交 | P0 不开放通用 Idempotency-Key；创建依赖前端防重和数据库唯一约束，更新/删除/状态动作按资源语义保证最终状态 |
| 请求追踪 | 后端生成 32 位小写十六进制 traceId，同时写入 Result、`X-Trace-Id` 和 MDC |
| 文件覆盖 | P0 使用 diff + 人工确认，禁止自动删除文件 |
| P0 CRUD 范围 | 单表 CRUD：列表、搜索、新增、编辑、删除、菜单、权限、SQL、模块说明 |
| 生产配置字段 | 服务名、访问模式、绑定地址、业务/管理端口、TLS、数据库、Redis、文件目录、日志目录、模型开关 |
| 备份范围 | MySQL dump、`data/files`、`config`、`app/VERSION` |
| 健康检查 | Actuator liveness/readiness + 受权限保护的 `/api/system/health` + 固定脚本退出码 |
| 升级回滚 | P0 程序/配置/文件回滚，数据库通过备份恢复 |
| Token 策略 | Sa-Token + Redis，开发可退回本地内存 |
| 浏览器会话 | Redis 服务端不透明随机 Token + HttpOnly SameSite=Strict Cookie；P0 不使用 JWT、不保存前端 Web Storage |
| 密码存储 | JDK 17 PBKDF2WithHmacSHA256，600000 次、16-byte salt、32-byte derived key |
| 登录防护 | 账号连续失败与来源 IP 双维度 Redis 限流，超限返回 `AUTH_0429` |
| CSRF/CORS | 生产同源、默认关闭 CORS；写请求校验 Origin 和会话绑定 `X-CSRF-Token` |
| 生产访问 | 默认 local 回环模式；非回环 LAN 模式必须配置 HTTPS |
| 密钥存储 | P0 ignored local 配置 + 日志脱敏，P1 Windows DPAPI/Jasypt |
| AI 脱敏 | P0 正则规则脱敏，P1 字段标记脱敏 |
| 审计字段 | AI 任务、操作日志、登录日志使用统一审计字段 |
| Skill 存储 | P0 Markdown 文件，P1 数据库存储 |
| Skill 格式 | YAML Front Matter + Markdown |
| 规则等级 | Must / Should / Must Not / Ask First / Verify / Document |
| 默认端口 | 业务 8080、Actuator 管理 8081、前端开发 5173、MySQL 3306、Redis 6379 |
| 本地配置文件 | `config/application-local.yml`、`config/model.local.yml` |
| runtime 打包 | 源码仓库不提交 runtime，开发发行包包含 runtime |

## AI 工作台契约

### 任务状态机

| 状态 | 说明 |
| --- | --- |
| draft | 用户刚提交需求 |
| planned | 已生成变更计划 |
| confirmed | 用户已确认计划或风险 |
| applying | 正在开发工作区应用补丁；不得表示生产服务器在线执行 |
| verifying | 正在执行开发验证；不得表示平台服务端任意 shell |
| completed | 已完成 |
| failed | 失败 |
| reverted | 已回滚 |

### 模型配置字段

| 字段 | 说明 |
| --- | --- |
| providerCode | 供应商编码 |
| providerName | 供应商名称 |
| apiBase | API Base |
| apiKeyEncrypted | 加密或受保护后的 API Key |
| modelName | 模型名 |
| modelType | chat/code/embedding |
| enabled | 是否启用 |
| timeoutSeconds | 超时时间 |
| maxTokens | 最大输出 token |

### Patch 策略

| 项目 | 决策 |
| --- | --- |
| 应用位置 | 开发工作区内的本地受控文件系统 |
| 应用方式 | diff/patch |
| 覆盖策略 | 覆盖前展示 diff，L2 以上需确认 |
| 删除文件 | P0 禁止自动删除 |
| 回滚 | 依赖 Git 检查点或任务补丁记录 |

补丁策略边界：

| 边界 | 决策 |
| --- | --- |
| 执行主体 | P0 由外部 AI Coding 工具或本地受控执行器承接 |
| 服务端能力 | 不提供服务端任意文件写入、任意 shell 或无边界终端 |
| 生产环境 | 不允许在线写源码、执行补丁或直接修改数据库结构 |
| 前置条件 | 必须完成签收、阶段启动、预览、风险确认和验证命令确认 |

## 代码生成契约

| 项目 | 决策 |
| --- | --- |
| 元模型存储 | 数据库表 + JSON 快照 |
| 权限标识 | `模块:资源:动作` |
| P0 CRUD | 单表 CRUD |
| 默认动作 | list/query/create/update/delete/export |
| 更新并发 | 生成的可编辑主表包含 version；UpdateDTO/VO 暴露 version，更新 SQL 匹配旧版本并原子加一 |
| 覆盖策略 | diff + 人工确认 |
| 模板引擎 | Velocity，见 ADR-0001 |

P0 CRUD 必须生成：

| 产物 | 说明 |
| --- | --- |
| Entity/DTO/VO/Query | 后端模型 |
| Controller/Service/Mapper | 后端接口 |
| migration SQL | Flyway 迁移 |
| menu SQL | 菜单权限 |
| api.ts | 前端 API |
| index.vue/form.vue | 前端页面 |
| README.md | 模块说明 |

## 验证命令契约

| 场景 | 命令 |
| --- | --- |
| 后端验证 | `mvn -pl vibe-starter -am test` |
| 后端快速构建 | `mvn -pl vibe-starter -am -DskipTests package` |
| 前端验证 | `npm run build` |
| Windows 诊断 | `scripts/doctor.ps1` |
| 生产打包 | `scripts/build-prod.ps1` |

如果工程骨架初期模块名尚未创建，命令中的 `vibe-starter` 作为目标模块名保留。

## 健康检查与状态脚本契约

P0 不引入独立监控组件，使用 Spring Boot Actuator 回环管理端口、一个受权限保护的系统接口和 PowerShell 状态脚本形成三层健康模型。Actuator 与业务端口分离，避免 LAN HTTPS、证书主机名和本机脚本探测相互耦合。

| 入口 | 调用方 | 判断范围 | 访问边界 |
| --- | --- | --- | --- |
| `/actuator/health/liveness` | WinSW、本机脚本 | JVM 和应用进程是否存活，不检查 MySQL、Redis、文件目录或外部模型 | 仅允许本机回环地址调用，返回状态摘要 |
| `/actuator/health/readiness` | install/start/status/upgrade/restore 脚本 | 应用是否可接收业务流量，检查 MySQL、生产 Redis、文件目录和数据库迁移状态 | 仅允许本机回环地址调用，返回状态摘要 |
| `/actuator/health` | 本机人工诊断 | 与 readiness 使用同一聚合口径，不作为详细诊断接口 | 仅允许本机回环地址调用，返回状态摘要 |
| `/api/system/health` | 登录后的企业管理员或实施人员 | 返回可读、脱敏的系统检查明细 | Sa-Token 登录 + `system:health:info` 权限 |

Actuator 契约：

| 项目 | 决策 |
| --- | --- |
| 响应格式 | 保持 Actuator 标准摘要，例如 `{"status":"UP"}`，不套统一业务响应 |
| HTTP 状态 | `UP` 返回 200；`DOWN`、`OUT_OF_SERVICE`、`UNKNOWN` 返回 503 |
| liveness | 不能因为 MySQL、Redis、文件目录或模型供应商故障而返回 `DOWN`，避免 WinSW 重启循环 |
| readiness | 生产模式下 MySQL、Redis、文件目录可写和 Flyway schema 兼容均为必需项，任一失败即非 `UP` |
| 开发降级 | 开发模式使用 Redis 内存降级时 readiness 可为 `UP`，但 `/api/system/health` 必须显示 `DEGRADED` 和降级原因 |
| 暴露范围 | P0 只开放 health 相关 Actuator 端点；禁止开放 `env`、`configprops`、`beans`、`mappings`、`heapdump`、`threaddump` 等管理端点 |
| 网络边界 | 脚本固定请求 `127.0.0.1`；应用必须拒绝非回环地址访问 `/actuator/**`，P0 不支持通过反向代理公开 Actuator |

端口约束：Actuator 使用 `management.server.address=127.0.0.1` 和默认 `management.server.port=8081`，只允许 health 相关端点；业务端口 8080 不暴露 `/actuator/**`。生产脚本固定请求 `http://127.0.0.1:8081`，即使业务端口启用 HTTPS 也不得绕过管理端口边界。

`/api/system/health` 使用统一业务响应，`data` 固定为：

```json
{
  "status": "HEALTHY",
  "version": "0.1.0",
  "timestamp": "2026-07-14T10:00:00+08:00",
  "checks": [
    {
      "name": "database",
      "status": "UP",
      "required": true,
      "durationMs": 12,
      "message": "连接正常"
    }
  ]
}
```

| 字段 | 约束 |
| --- | --- |
| `status` | 只能是 `HEALTHY`、`DEGRADED`、`UNAVAILABLE` |
| `version` | 来自 Maven `project.version` 生成的 Spring Boot build info；生产包 `app/VERSION` 必须与其完全一致，不得在 Controller 硬编码 |
| `checks[].name` | 只能使用 `application`、`database`、`redis`、`fileStorage`、`migration` 等稳定标识 |
| `checks[].status` | 只能是 `UP`、`DOWN`、`DEGRADED`、`UNKNOWN` |
| 检查顺序 | 固定为 application、database、redis、fileStorage、migration；开发降级仍保留对应 name 并标记 `DEGRADED` |
| 聚合规则 | 必需项失败为 `UNAVAILABLE`；只有可选项或开发降级异常为 `DEGRADED`；其余为 `HEALTHY` |
| HTTP 状态 | 只要接口完成检查即返回 200，调用方以 `data.status` 判断；接口自身异常仍按统一异常返回 500 |
| 超时 | 单项检查最多 2 秒，总检查最多 5 秒；不得执行写操作、全表查询或模型供应商网络调用 |
| 脱敏 | 不返回数据库名、用户名、主机名、连接串、Redis Key、服务器绝对路径、配置值、异常堆栈或供应商原始错误 |

阶段边界：S1 只实现 Actuator liveness/readiness 骨架；S2 在认证权限完成后实现 `/api/system/health`；S6 再接入生产脚本、必需依赖检查和发布门禁。

`status.ps1` 退出码固定如下，后续不得临场改义：

| 退出码 | 含义 |
| --- | --- |
| `0` | Windows 服务运行且 readiness 为 `UP` |
| `10` | Windows 服务尚未安装 |
| `11` | Windows 服务已停止 |
| `12` | 服务处于启动、停止挂起或未知状态 |
| `20` | 服务进程运行，但 liveness 不是 `UP` |
| `21` | liveness 为 `UP`，但 readiness 不是 `UP` |
| `30` | 脚本参数、安装配置或执行环境错误 |
| `31` | 健康响应超时、无法连接或格式不可解析 |

`start.ps1`、`install.ps1`、`upgrade.ps1` 和 `restore.ps1` 只有在 readiness 于默认 60 秒超时内达到 `UP` 时才能返回成功；超时时必须返回非零退出码并输出脱敏的中文原因和日志路径。

## 生产配置契约

生产配置最小字段：

| 字段 | 说明 |
| --- | --- |
| server.port | 后端端口，默认 8080 |
| server.address | local 模式固定 `127.0.0.1`；lan 模式由安装配置显式指定 |
| management.server.address | 固定 `127.0.0.1` |
| management.server.port | Actuator 管理端口，默认 8081 |
| server.ssl.enabled | local 模式可为 false；lan 模式必须 true |
| server.ssl.key-store | lan 模式外置 PKCS12 路径 |
| server.ssl.key-store-password | lan 模式外置私钥密码，不得进入源码、日志或 manifest |
| spring.datasource.url | MySQL 地址 |
| spring.datasource.username | MySQL 用户 |
| spring.datasource.password | MySQL 密码 |
| spring.data.redis.host | Redis 地址 |
| spring.data.redis.port | Redis 端口 |
| vibe.file.storage-path | 文件目录 |
| vibe.file.max-file-size | 单文件上限，P0 默认 20 MB |
| vibe.file.max-request-size | multipart 请求上限，P0 默认 25 MB |
| vibe.file.storage-quota | 文件逻辑配额，P0 默认 10 GB |
| vibe.file.min-free-space | 必须保留的磁盘空间，P0 默认 2 GB |
| vibe.logs.path | 日志目录 |
| vibe.security.session.absolute-timeout | 会话绝对有效期，P0 默认 8 小时 |
| vibe.security.session.idle-timeout | 会话空闲有效期，P0 默认 30 分钟 |
| vibe.security.access-mode | `local` 或 `lan`；生产默认 `local` |
| vibe.security.allowed-origin | 生产访问 Origin；local 模式为本机地址，lan 模式必须与 HTTPS 地址一致 |
| vibe.ai.dev-tools-enabled | 生产默认 false |

配置文件提交边界：

| 文件 | 是否提交源码仓库 | 允许内容 |
| --- | --- | --- |
| `backend/*/src/main/resources/application.yml` | 是 | 应用名、profile、非敏感默认值 |
| `backend/*/src/main/resources/application-dev.yml` | 是 | 开发端口、日志、占位连接配置，不含真实密码 |
| `backend/*/src/main/resources/application-prod.yml` | 是 | 生产模板和占位符，不含真实数据库密码、Redis 密码、TLS 私钥密码、API Key |
| `config/application-local.yml.example` | 是 | 本地配置示例和中文注释，示例值必须是占位符 |
| `config/model.local.yml.example` | 是 | 模型配置示例和中文注释，示例 API Key 必须是占位符 |
| `config/application-local.yml` | 否 | 本地数据库、Redis、路径和会话策略覆盖配置 |
| `config/model.local.yml` | 否 | 本地模型 API Base、API Key、模型名 |
| `config/application-prod.yml` | 否 | 安装或部署时生成的真实生产配置 |
| `config/model-prod.yml` | 否 | 生产业务 AI 配置，默认可为空 |
| `config/install.yml` | 否 | 安装路径、端口、服务名、数据库连接等真实部署参数 |

约束：`application-prod.yml` 在源码中只能是模板语义。真实生产配置必须由安装脚本、部署人员或外置配置生成，不能随源码提交。任何包含密码、API Key、TLS 私钥、私钥密码或连接串的文件都不得进入 Git、日志、AI 上下文或默认生产包。P0 会话 Token 是服务端 Redis 中的随机不透明值，不使用 JWT，因此安装时不生成 Token Secret。

## 本地文件服务契约

P0 `vibe-file` 在 S2 提供本地文件基础服务，不引入 MinIO、OSS、Nginx 文件代理、杀毒引擎或额外解析框架。

| 项目 | P0 决策 |
| --- | --- |
| 存储根目录 | 默认 `<应用数据目录>/files`，生产对应安装目录下 `data/files`；必须位于 Web 静态资源目录之外 |
| 目录结构 | `yyyy/MM/<storageKey 前两位>/<storageKey>.<ext>`，`storageKey` 使用服务端生成的 UUID，不使用用户文件名构造路径 |
| 上传形式 | 单请求单文件，multipart 字段固定为 `file`；P0 不做批量、分片、断点续传或秒传 |
| 单文件限制 | 大于 0 且不超过 20 MB；multipart 请求不超过 25 MB；不能只依赖客户端 `Content-Length` |
| 存储限制 | 默认逻辑配额 10 GB，统计所有非 `deleted` 元数据、临时文件和上传预留；并始终保留至少 2 GB 磁盘可用空间，写入过程中也要复查；任一条件不满足返回 507 |
| 允许扩展名 | `jpg`、`jpeg`、`png`、`webp`、`pdf`、`txt`、`md`、`csv`、`json` |
| 禁止类型 | 可执行文件、脚本、HTML、SVG、JAR/class、DLL、安装包、压缩包、宏文档和任何未在白名单中的类型 |
| 内容校验 | 同时校验小写扩展名、声明 MIME 和实际签名；图片/PDF 检查 magic bytes，文本要求 UTF-8、无 NUL，JSON 还必须可解析 |
| 文件名 | 原始名称仅作元数据和下载展示，最长 200 个字符；移除控制字符、路径分隔符和首尾点空格，不作为磁盘文件名 |
| 防路径穿越 | 所有目标路径必须以存储根目录为基准做 `resolve().normalize()`，并再次确认仍位于根目录内；API 不接受用户目录或相对路径参数 |
| Windows 路径安全 | storage root 使用真实规范路径，目录树不得包含符号链接、junction 或其他 reparse point；安装时将 ACL 限制为服务账号和管理员 |
| 访问方式 | 禁止静态目录映射和公开直链；只允许通过文件 ID 访问鉴权 API，不向前端返回 `relativePath` 或存储根目录 |
| P0 数据范围 | 文件管理权限是 RBAC 全局权限，拥有 list/download/preview/delete 的角色可访问对应文件管理资源；P0 不宣称已实现业务附件级所有权或部门隔离 |
| 下载与预览 | 下载统一 `attachment`；预览只允许 jpg/jpeg/png/webp，其他类型返回 `FILE_0409`，并设置 `nosniff`、私有禁缓存等安全响应头 |
| 病毒能力 | P0 不宣称已完成病毒扫描；白名单和签名校验只能降低风险。需要防病毒、内容净化或 Office 解析时必须先进入 P1 决策 |

扩展名、允许声明 MIME、实际内容和服务端规范化 MIME 固定如下：

| 扩展名 | 允许声明 MIME | 实际校验 | 规范化 MIME |
| --- | --- | --- | --- |
| jpg/jpeg | `image/jpeg` | JPEG magic bytes | `image/jpeg` |
| png | `image/png` | PNG signature | `image/png` |
| webp | `image/webp` | RIFF + WEBP signature | `image/webp` |
| pdf | `application/pdf` | `%PDF-` signature | `application/pdf` |
| txt | `text/plain`、`application/octet-stream` | UTF-8 且无 NUL | `text/plain` |
| md | `text/markdown`、`text/plain`、`application/octet-stream` | UTF-8 且无 NUL | `text/markdown` |
| csv | `text/csv`、`text/plain`、`application/vnd.ms-excel` | UTF-8 且无 NUL | `text/csv` |
| json | `application/json`、`text/json`、`text/plain` | UTF-8、无 NUL且 JSON 可解析 | `application/json` |

客户端声明为 `application/octet-stream` 只对 txt/md 放行，不能作为图片、PDF、CSV 或 JSON 绕过类型校验。不得使用操作系统文件关联或原始文件名作为唯一 MIME 判断依据。

API 与权限：

| API | 权限 | 说明 |
| --- | --- | --- |
| `POST /api/files` | `file:object:upload` | 上传一个文件 |
| `GET /api/files/page` | `file:object:list` | 查询脱敏元数据，不返回内部路径 |
| `GET /api/files/{id}/download` | `file:object:download` | 鉴权下载并审计 |
| `GET /api/files/{id}/preview` | `file:object:preview` | 仅图片预览 |
| `DELETE /api/files/{id}` | `file:object:delete` | 两阶段删除，重复删除幂等 |
| `POST /api/files/{id}/retry-delete` | `file:object:delete` | 仅重试 `delete_failed` 文件 |

上传开始时先以短事务创建 `uploading` 元数据，再流式写入存储根目录下 `.tmp/<storageKey>.uploading`，同时计算大小和 SHA256；完成类型、配额和路径校验后再原子移动到最终路径，并以短事务把状态置为 `active`。配额检查与本进程内的容量预留必须原子化，适配 P0 单实例单体部署。失败时状态置为 `failed` 且不得下载；临时或最终文件清理失败必须写脱敏告警。P0 不做跨文件去重，避免通过 hash 推断其他用户文件。

应用启动时只做一次中断恢复检查：超过 1 小时仍为 `uploading` 的记录转为 `failed`，对应 `.tmp` 文件做尽力清理并记录脱敏结果；未知文件不得自动发布为 active。P0 不运行定时清理任务，后续清理由有权限的管理员通过删除接口完成。

删除状态固定为 `active|failed -> deleting -> deleted`。进入 `deleting` 后立即禁止下载；物理删除失败则进入 `delete_failed`，保留元数据和脱敏错误摘要，只能由有权限的管理员重试。磁盘 I/O 不得长期占用数据库事务，状态切换使用短事务。P0 不提供定时后台清理或业务附件绑定。

范围边界：P0 只实现文件管理基础服务；业务记录附件、临时上传绑定、公开链接、Office 文档、音视频、压缩包、在线文档预览、对象存储和 CDN 均不进入 S2。

## 备份恢复契约

| 备份类型 | P0 范围 | 用途 |
| --- | --- | --- |
| 日常备份 | `mysqldump`、`data/files`、`config`、`app/VERSION`、`manifest.json` | 同一完整版本的数据灾难恢复 |
| 升级回滚点 | 日常备份全部内容 + 升级前 `app/` 程序产物 | 升级失败后恢复程序、数据库、文件和配置的一致状态 |

备份和恢复必须遵守以下契约：

| 项目 | P0 决策 |
| --- | --- |
| 一致性 | 日常备份和升级回滚点都必须在停止 Vibe Boot 服务后创建；独立日常备份校验结束后恢复调用前的服务状态，升级或恢复流程调用备份时保持停服 |
| manifest | 只记录备份类型、产品完整版本、数据库迁移版本、时间、相对路径、大小和 SHA256，不记录配置值、密码、Token、API Key 或业务数据摘要 |
| 敏感级别 | 只要包含 `config` 或数据库导出，整个备份目录即视为敏感运维资产；不得进入 Git、AI 上下文、日志附件、默认生产包或公开共享目录 |
| Windows 权限 | 默认写入安装目录下的 `backup/`，继承安装目录受限 ACL；P0 不承诺备份加密，复制到其他介质前由管理员负责加密和访问控制 |
| 配置恢复 | 日常恢复默认不覆盖当前 `config/`，显式选择并二次确认后才允许覆盖；升级回滚必须恢复同一回滚点中的旧配置，日志只记录文件名和结果 |
| 兼容性 | P0 日常恢复只支持备份的完整产品版本与待恢复程序版本一致；跨版本恢复默认阻断 |
| 升级失败 | Flyway 迁移开始后禁止只回滚 jar 或前端资源；必须停止服务，并使用同一次升级回滚点恢复旧程序、数据库、文件和配置 |
| 数据库回滚 | P0 不提供逆向 Flyway 或自动数据库回滚；MySQL DDL 可能无法事务回退，升级前回滚点是数据库恢复依据 |
| 保留策略 | P0 不自动删除历史备份；空间不足时备份、恢复或升级必须在修改现状前停止 |

恢复前还必须为当前状态创建保护性备份。若保护性备份失败，不得继续覆盖数据库、文件或配置。

## 安全契约

| 项目 | 决策 |
| --- | --- |
| Token | Sa-Token + Redis |
| 开发降级 | Redis 不可用时允许本地内存，仅开发模式 |
| 密钥 | P0 ignored local 配置，日志脱敏 |
| AI 脱敏 | 正则替换 API Key、密码、Token |
| 生产禁用 | 代码修改、脚本执行、数据库结构修改默认 false |

## Skill 与规则契约

| 项目 | 决策 |
| --- | --- |
| P0 Skill 类型 | product、engineering、security、testing、business |
| Skill 格式 | YAML Front Matter + Markdown |
| 规则等级 | Must、Should、Must Not、Ask First、Verify、Document |
| L2/L3 风险 | 必须用户确认 |
| 检查方式 | P0 简单静态检查 + 人工确认 |
| 审计字段 | taskId、skillIds、ruleIds、blockedRules、warnings、confirmations、verification |

## Windows 开发包契约

| 项目 | 决策 |
| --- | --- |
| 产品名 | `Vibe Boot` |
| 工程标识 | `vibe-boot` |
| 后端应用名 | `vibe-boot` |
| Windows 服务名 | `VibeBoot` |
| 默认生产安装目录 | `C:\VibeBoot` |
| 默认数据库名 | `vibe_boot` |
| 建议数据库用户 | `vibe_boot`，生产密码必须安装时输入或外置生成 |
| 默认后端端口 | 8080 |
| 默认 Actuator 管理端口 | 8081，仅回环 |
| 默认前端端口 | 5173 |
| 默认 MySQL 端口 | 3306 |
| 默认 Redis 端口 | 6379 |
| 本地后端配置 | `config/application-local.yml` |
| 本地模型配置 | `config/model.local.yml` |
| runtime 策略 | 源码仓库不提交，开发发行包包含 |

约束：上述默认值只用于降低首次安装和脚本诊断成本。端口、安装目录、数据库连接和服务名可以通过本地或生产配置覆盖；生产密码、TLS 私钥密码、模型 API Key 不得使用公开默认值。

## 影响范围

| 文档 | 需要同步 |
| --- | --- |
| `docs/ai-workbench-design.md` | 编码准入项 |
| `docs/code-generation-design.md` | 编码准入项 |
| `docs/release-package-design.md` | 生产配置、备份、健康检查、回滚 |
| `docs/security-governance.md` | Token、密钥、脱敏、审计 |
| `docs/skill-rule-design.md` | Skill 类型、格式、规则等级、检查方式 |
| `docs/windows-devkit-design.md` | runtime、local 配置、端口 |

## 后续规则

如果实现阶段发现这些契约不适合，必须先更新本文或新增 ADR，再修改代码。

## 结论

ADR-0002 将各模块设计中此前分散的实现细节收敛为 MVP 默认实现契约。后续可以进入更细的任务拆分，但仍必须优先维护文档，再进入编码。
