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
| AI 任务状态机 | `draft -> clarifying -> planned -> waiting_confirm -> handoff_ready -> executing_external -> verifying -> completed`，并保留 `failed/blocked/cancelled/reverted` 分支 |
| 模型配置字段 | API 请求使用 `providerCode/apiBase/apiKey/modelName/modelType/enabled/timeoutSeconds/maxTokens`；数据库内部使用 `credentialCiphertext`，响应只返回 `credentialConfigured` |
| Patch 应用方式 | P0 由外部 AI Coding 工具在开发工作区应用通用 diff；确定性代码生成器只写入其声明拥有的生成路径；P1 才可另行设计本地受控补丁执行器 |
| 验证命令 | 后端 `scripts/mvn.ps1 -pl vibe-starter -am test`，前端 `npm run build`，打包 `build-prod.ps1` |
| 生产禁用策略 | 生产包不包含代码修改、脚本执行、数据库结构修改及其他开发型 AI 入口；profile 固定 false，配置为 true 启动失败 |
| 生成元模型 | P0 使用数据库表 + JSON 快照 |
| 权限标识 | `模块:资源:动作`，例如 `biz:customerVisit:create` |
| API 并发控制 | P0 可编辑主记录使用 version 乐观锁；状态机使用预期状态条件更新；唯一索引作为最终并发防线 |
| API 重复提交 | P0 不开放通用 Idempotency-Key；创建依赖前端防重和数据库唯一约束，更新/删除/状态动作按资源语义保证最终状态 |
| 请求追踪 | 后端生成 32 位小写十六进制 traceId，同时写入 Result、`X-Trace-Id` 和 MDC |
| 文件覆盖 | P0 使用 diff + 人工确认，禁止自动删除文件 |
| P0 CRUD 范围 | 单表 CRUD：列表、搜索、新增、编辑、删除、菜单、权限、SQL、模块说明 |
| 生产配置字段 | PowerShell 使用 `install.json`；Spring Boot 使用外置 YAML 与受限 ACL secret 文件；覆盖服务、网络、TLS、数据库、Redis、文件、日志和模型开关 |
| 备份范围 | MySQL dump、`data/files`、非敏感配置快照、`app/VERSION`、manifest；任何密码和模型主密钥均排除 |
| 健康检查 | Actuator liveness/readiness + 受权限保护的 `/api/system/health` + 固定脚本退出码 |
| 升级回滚 | P0 程序/配置/文件回滚，数据库通过备份恢复 |
| 发布包信任 | 生产 PowerShell 与 `PACKAGE-MANIFEST.psd1` 必须使用同一受信 Authenticode 证书签名；包内文件由签名 manifest 的 SHA256 覆盖 |
| 服务身份 | Procrun 1.6.1 固定使用 `NT AUTHORITY\LOCAL SERVICE`，并启用 `NT SERVICE\VibeBoot` service SID 作为目录 ACL 主体 |
| 生产迁移账号 | 运行账号只持有 DML 权限；独立迁移账号仅注入同一 Jar 的一次性 `migrate` 维护进程，常驻服务禁用 Flyway |
| Token 策略 | Sa-Token + Redis，开发可退回本地内存 |
| 浏览器会话 | Redis 服务端不透明随机 Token + HttpOnly SameSite=Strict Cookie；P0 不使用 JWT、不保存前端 Web Storage |
| 密码存储 | JDK 17 PBKDF2WithHmacSHA256，600000 次、16-byte salt、32-byte derived key |
| 登录防护 | 账号连续失败与来源 IP 双维度 Redis 限流，超限返回 `AUTH_0429` |
| CSRF/CORS | 生产同源、默认关闭 CORS；写请求校验 Origin 和会话绑定 `X-CSRF-Token` |
| 生产访问 | 默认 local 回环模式；非回环 LAN 模式必须配置 HTTPS |
| 密钥存储 | P0 使用 JDK AES-256-GCM 加密模型 API Key，32-byte 外置主密钥与数据库密文分离；P1 再评估 Windows DPAPI 或外部密钥服务 |
| AI 脱敏 | P0 正则规则脱敏，P1 字段标记脱敏 |
| 审计字段 | AI 任务、操作日志、登录日志使用统一审计字段 |
| Skill 存储 | P0 Markdown 文件，P1 数据库存储 |
| Skill 格式 | YAML Front Matter + Markdown |
| 规则等级 | Must / Should / Must Not / Ask First / Verify / Document |
| 默认端口 | 业务 8080、Actuator 管理 8081、前端开发 5173、MySQL 3306、Redis 6379 |
| 本地配置文件 | `config/application-local.yml`、`config/model-local.yml` |
| runtime 打包 | 源码仓库不提交 runtime，开发发行包包含 runtime |

## AI 工作台契约

### 任务状态机

| 状态 | 说明 |
| --- | --- |
| draft | 用户刚提交需求 |
| clarifying | 正在澄清需求和默认假设 |
| planned | 已生成变更计划 |
| waiting_confirm | 等待用户确认计划、范围或风险 |
| handoff_ready | 已确认且外部 AI 交接包、准入卡、允许范围和验证命令齐全 |
| executing_external | P0 外部 AI Coding 工具正在处理；不得表示平台服务端、未来本地执行器或生产服务器在线执行 |
| verifying | 正在执行开发验证；不得表示平台服务端任意 shell |
| completed | 已完成且具备变更摘要、验证结论、风险和下一步 |
| failed | 调用或执行失败，保留可定位原因 |
| blocked | 缺少模型、环境、签收、需求或验证条件，可在条件补齐后恢复 |
| cancelled | 用户取消 |
| reverted | 外部执行产生的变更已回滚 |

`confirmed` 是用户确认事件和审计字段，不是持久化任务状态；`applying` 由语义更明确的 `executing_external` 取代。AI 任务状态、代码生成作业状态和阶段交付物状态是三套独立枚举，不得混用。

### 模型配置字段

| 字段 | 说明 |
| --- | --- |
| providerCode | 供应商编码 |
| providerName | 供应商名称 |
| apiBase | API Base |
| apiKey | 只允许出现在创建/更新请求中，进入 Service 后立即加密，不记录、不回显 |
| credentialCiphertext | 数据库内部字段，保存版本化 AES-GCM 密文，禁止出现在 API 响应 |
| credentialConfigured | API 响应派生布尔值，只表示凭据是否存在 |
| modelName | 模型名 |
| modelType | chat/code/embedding |
| enabled | 是否启用 |
| timeoutSeconds | 超时时间 |
| maxTokens | 最大输出 token |
| rateLimitPerMinute | 同一模型配置每分钟总调用上限，默认 30 |
| userRateLimitPerMinute | 同一用户 + 模型配置每分钟上限，默认 10 |
| dailyCallLimit | 同一模型配置按 `Asia/Shanghai` 自然日的调用上限，默认 1000 |
| dailyTokenLimit | 同一模型配置按 `Asia/Shanghai` 自然日的 token 上限，默认 1000000 |

### 模型凭据加密契约

| 项目 | P0 固定契约 |
| --- | --- |
| 算法 | JDK 17 `AES/GCM/NoPadding`，256-bit key、12-byte 随机 IV、128-bit authentication tag |
| 随机源 | 每次加密使用 `SecureRandom` 生成新 IV；同一 key/IV 组合绝不复用 |
| AAD | UTF-8 `vibe-boot:model-credential:<configId>:<providerCode>:v1`，防止密文被复制到其他配置 |
| 密文格式 | `$a256gcm$v1$<base64url-iv>$<base64url-ciphertext-and-tag>` |
| 主密钥 | 32-byte `SecureRandom`，Base64URL 无填充；开发 profile 可来自环境变量 `VIBEBOOT_MODEL_MASTER_KEY` 或 ignored `model-local.yml`，生产 profile 只允许 `config/secrets/model-master.key`，`model-prod.yml` 只保存文件路径 |
| 来源规则 | 开发环境变量优先；若开发环境变量与 local 配置同时存在但解码后不一致则失败。生产出现 `VIBEBOOT_MODEL_MASTER_KEY` 或 YAML 内嵌主密钥均视为配置违规并启动失败，不得静默覆盖 secret 文件 |
| 格式校验 | Base64URL 无填充解码后必须恰好 32 bytes；空值、非法字符、错误长度一律视为主密钥不可用 |
| 密钥分离 | 主密钥不得进入数据库、Git、日志、AI 上下文、默认生产包或 API；数据库只保存密文 |
| API 输出 | 只返回 `credentialConfigured=true/false`，不返回明文、密文、末四位或主密钥 |
| 缺失/错误主密钥 | 禁止保存、解密和调用模型，返回 `AI_0503` 与 traceId；不得把原始加密异常返回前端 |
| 轮换/泄漏 | P0 先禁用模型配置并撤销供应商 API Key，生成新主密钥后重新录入全部模型凭据；不保留旧主密钥自动回退 |

开发模式由 `scripts/setup-model.ps1` 生成或校验主密钥，生产模式由 `install.ps1` 生成或接收主密钥并限制配置文件 ACL。模型 API Key 仍由管理页面录入并加密到数据库，脚本和配置文件不保存供应商 API Key。

创建模型配置时必须先分配雪花 `configId`，再按规范化后的 lowercase ASCII `providerCode` 构造 AAD 并加密。`configId` 和 `providerCode` 创建后不可修改；切换供应商应新建配置并重新录入凭据，避免既有密文失去可验证的 AAD 绑定。

依据：

| 资料 | 用途 |
| --- | --- |
| [Java 17 JCA Reference Guide](https://docs.oracle.com/en/java/javase/17/security/java-cryptography-architecture-jca-reference-guide.html) | 确认 `AES/GCM/NoPadding`、AAD 和每次加密必须使用不同 IV |
| [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html) | 确认优先使用认证加密模式、密码学安全随机数以及密钥与数据分离 |

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
| 执行主体 | P0 通用补丁只由外部 AI Coding 工具承接；确定性代码生成器只可写入已声明拥有的生成路径；P1 本地受控执行器必须另立 ADR 后才能启用 |
| 服务端能力 | 不提供服务端任意文件写入、任意 shell 或无边界终端 |
| 生产环境 | 不允许在线写源码、执行补丁或直接修改数据库结构 |
| 前置条件 | 必须完成签收、阶段启动、预览、风险确认和验证命令确认 |

`executing_external` 在 P0 只表示外部 AI Coding 工具已接手交接包。不得用该状态暗示平台服务端正在写源码，也不得把确定性模板生成任务或未来 P1 本地执行器混入该状态。

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
| 后端验证 | `scripts/mvn.ps1 -pl vibe-starter -am test` |
| 后端快速构建 | `scripts/mvn.ps1 -pl vibe-starter -am -DskipTests package` |
| 前端验证 | `npm run build` |
| Windows 诊断 | `scripts/doctor.ps1` |
| 生产打包 | `scripts/build-prod.ps1` |

如果工程骨架初期模块名尚未创建，命令中的 `vibe-starter` 作为目标模块名保留。

## 健康检查与状态脚本契约

P0 不引入独立监控组件，使用 Spring Boot Actuator 回环管理端口、一个受权限保护的系统接口和 PowerShell 状态脚本形成三层健康模型。Actuator 与业务端口分离，避免 LAN HTTPS、证书主机名和本机脚本探测相互耦合。

| 入口 | 调用方 | 判断范围 | 访问边界 |
| --- | --- | --- | --- |
| `/actuator/health/liveness` | SCM/Procrun、本机脚本 | JVM 和应用进程是否存活，不检查 MySQL、Redis、文件目录或外部模型 | 仅允许本机回环地址调用，返回状态摘要 |
| `/actuator/health/readiness` | install/start/status/upgrade/restore 脚本 | 应用是否可接收业务流量，检查 MySQL、生产 Redis、文件目录和数据库迁移状态 | 仅允许本机回环地址调用，返回状态摘要 |
| `/actuator/health` | 本机人工诊断 | 与 readiness 使用同一聚合口径，不作为详细诊断接口 | 仅允许本机回环地址调用，返回状态摘要 |
| `/api/system/health` | 登录后的企业管理员或实施人员 | 返回可读、脱敏的系统检查明细 | Sa-Token 登录 + `system:health:info` 权限 |

Actuator 契约：

| 项目 | 决策 |
| --- | --- |
| 响应格式 | 保持 Actuator 标准摘要，例如 `{"status":"UP"}`，不套统一业务响应 |
| HTTP 状态 | `UP` 返回 200；`DOWN`、`OUT_OF_SERVICE`、`UNKNOWN` 返回 503 |
| liveness | 不能因为 MySQL、Redis、文件目录或模型供应商故障而返回 `DOWN`，避免 SCM 重启循环 |
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

## Windows 生产包信任与服务身份契约

生产安装脚本以管理员权限运行，因此“包内自带一个哈希文件”不足以建立信任。P0 固定使用 Windows 原生 Authenticode，不再引入额外签名运行时。

| 项目 | P0 契约 |
| --- | --- |
| 签名对象 | `scripts/*.ps1`、`operations/trusted-launcher.ps1` 和 `PACKAGE-MANIFEST.psd1` 使用同一代码签名证书签名 |
| 文件覆盖 | `PACKAGE-MANIFEST.psd1` 除自身外覆盖包内每个普通文件，包括 thin jar、`app/lib`、静态资源、JDK、Procrun、迁移审计副本和 notices；记录规范化相对路径、大小与 SHA256，并拒绝清单外文件 |
| 信任锚 | 管理员通过带外渠道取得预期 signer thumbprint，先用 Windows `Get-AuthenticodeSignature` 验证目标脚本，再在每次 install/upgrade 调用时以必填 `-TrustedSignerThumbprint` 传入；不得从包内、环境变量或安装目录配置读取 |
| 构建门禁 | `build-prod.ps1` 遇到脏工作区、缺少有效签名证书、签名失败或 manifest 校验失败时停止；仅显式 `-UnsignedDevelopmentPackage` 可生成带醒目标记的测试包，生产安装必须拒绝该包 |
| 包级校验 | 构建同时生成包外 `VibeBoot-<version>-windows-x64.zip.sha256`，通过发布渠道单独公布；它用于下载完整性复核，不替代 Authenticode |
| 唯一安装入口 | 首装只运行已验证目标包中的 `scripts/install.ps1`；P0 不提供在线自动更新 |
| 唯一升级入口 | 只运行已验证目标包中的 `scripts/upgrade.ps1`，由它检查当前安装并编排升级；已安装旧版本脚本和应用进程不得执行升级 |

Procrun 服务身份和 NTFS ACL 固定如下：

| 对象 | Administrators / SYSTEM | `NT SERVICE\VibeBoot` | 普通用户 |
| --- | --- | --- | --- |
| 安装根目录 | FullControl | ReadAndExecute，仅遍历 | 无权限 |
| `app/`、`runtime/`、`service/`、`db/`、`notices/` | FullControl | ReadAndExecute | 不得写入 |
| `config/` | FullControl | Read | 不得写入 |
| `config/secrets/` | FullControl | Read | 无读取权限 |
| `data/`、`logs/` | FullControl | Modify | 无写入权限 |
| `scripts/`、`staging/`、`backup/`、`operations/` | FullControl | 无权限 | 无权限 |

`install.ps1` 必须先注册但不启动 Procrun 服务，将账号固定为 `NT AUTHORITY\LOCAL SERVICE`，设置 service SID 为 unrestricted，再对根目录和表中每个目录关闭继承并重建显式 ACL。`operations/` 必须是 `data/` 的兄弟目录；安装验收必须证明服务 SID 不能在 operations 创建、删除、替换或重命名文件。服务二进制、Jar、runtime、脚本或 operations 对普通用户/服务进程可写、目录含 reparse point、hardlink 异常或 ACL 复核失败时均阻断安装。卸载只移除服务和产品创建的 ACL，不主动删除 `data/`、`backup/` 或 secret 文件。

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
| spring.datasource.username | MySQL 运行用户，仅具备业务 DML 权限 |
| spring.datasource.password | 从 `config/secrets/application-prod.secrets.properties` 读取，不写入 `install.json` |
| spring.data.redis.host | Redis 地址 |
| spring.data.redis.port | Redis 端口 |
| spring.data.redis.username | Redis ACL 用户，生产必填 |
| spring.data.redis.password | 从受限 ACL secret 文件读取，生产必填 |
| spring.data.redis.ssl.enabled | 非回环连接必须为 true；回环禁用 TLS 需显式确认 |
| vibe.instance-id | 安装时生成并持久化的小写 UUID，用于 Redis Key 前缀 `vibe-boot:<instanceId>:` |
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
| vibe.ai.dev-tools-enabled | 生产固定 false；检测到 true 必须启动失败，不允许通过配置恢复开发型 AI |

PowerShell 脚本自己的配置只允许 JSON，不能要求 Windows PowerShell 5.1 解析 YAML。`install.json` 的权威 Draft 2020-12 结构 schema、示例和全部跨字段规则固定在 `docs/release-package-design.md` 第 8.1 节；ADR 只保留不可变边界，禁止复制出第二套兼容格式：

| 文件/字段组 | P0 契约 |
| --- | --- |
| `config/install.json` | UTF-8 JSON，固定 `schemaVersion=1`；拒绝 BOM、重复/未知/近似大小写字段、注释、尾逗号和非标准数值 |
| 基础字段 | `installRoot/serviceName/accessMode/bindAddress/businessPort/managementPort/allowedOrigin/openFirewall/instanceId`；P0 `serviceName` 必须严格等于 `VibeBoot` |
| 安全确认 | `allowInsecureLoopback`；只允许 MySQL 与 Redis 都是 literal loopback 时为 true |
| `mysql` | `host/port/database/applicationUsername/migrationUsername/tlsMode/caFile/mysqlClientBin`；不含密码值，database 固定 `vibe_boot` |
| `redis` | `host/port/username/tlsEnabled/caFile/database/keyPrefix`；不含密码值，P0 `database` 固定 0，`keyPrefix` 必须由 instanceId 派生 |
| `tls` | 只允许 `keyStorePath`；lan 模式必填，密码不属于 JSON |
| 路径 | storage/backup/operations/staging/certs/secrets 全部由 installRoot 固定派生，P0 不允许外置覆盖 |
| 解析方式 | PowerShell 5.1 `ConvertFrom-Json` 只做初筛；同一已认证 Java classpath 的 `--vibe.operation=validate-install-config` 必须重新读取原始 JSON bytes，使用 Jackson 严格重复检测并按发布设计 schema 做权威校验，失败时任何写盘/SCM/数据库动作都不得发生 |

密码和私钥口令统一写入 `config/secrets/application-prod.secrets.properties`，模型主密钥单独写入 `config/secrets/model-master.key`；两者关闭继承，仅 Administrators、SYSTEM 和 `NT SERVICE\VibeBoot` 按上节权限读取。供应商 API Key 仍只能由管理页面只写录入并加密入库。

生产外部连接的最低安全线：MySQL 与 Redis 位于非回环地址时必须启用 TLS 并校验证书主机名；MySQL 使用 `VERIFY_IDENTITY`，Redis 使用 TLS 连接和显式 CA。只有服务与数据服务都在同一主机回环地址时，才允许在 `install.json` 中显式确认 insecure loopback；安装器不得把“内网”自动视为可信明文网络。

配置文件提交边界：

| 文件 | 是否提交源码仓库 | 允许内容 |
| --- | --- | --- |
| `backend/*/src/main/resources/application.yml` | 是 | 应用名、profile、非敏感默认值 |
| `backend/*/src/main/resources/application-dev.yml` | 是 | 开发端口、日志、占位连接配置，不含真实密码 |
| `backend/*/src/main/resources/application-prod.yml` | 是 | 生产模板和占位符，不含真实数据库密码、Redis 密码、TLS 私钥密码、API Key |
| `config/application-local.yml.example` | 是 | 本地配置示例和中文注释，示例值必须是占位符 |
| `config/model-local.yml.example` | 是 | 模型主密钥和非敏感默认配置示例，值必须是占位符 |
| `config/application-local.yml` | 否 | 本地数据库、Redis、路径和会话策略覆盖配置 |
| `config/model-local.yml` | 否 | 本地模型凭据主密钥和非敏感默认值；不得保存供应商 API Key |
| `config/application-prod.yml` | 否 | 安装或部署时生成的真实生产配置 |
| `config/model-prod.yml` | 否 | 生产业务 AI 白名单、非敏感默认值和 `model-master.key` 路径；不得内嵌主密钥 |
| `config/install.json` | 否 | PowerShell 5.1 原生解析的安装参数；只存非敏感值和 secret 文件路径，不直接存密码 |

约束：`application-prod.yml` 在源码中只能是模板语义。真实生产配置必须由安装脚本、部署人员或外置配置生成，不能随源码提交。任何包含密码、模型凭据主密钥、API Key、TLS 私钥、私钥密码或连接串的文件都不得进入 Git、日志、AI 上下文或默认生产包。P0 会话 Token 是服务端 Redis 中的随机不透明值，不使用 JWT，因此安装时不生成 Token Secret。

## 数据库迁移执行契约

P0 的迁移源和执行器都必须唯一，不能让 jar、外置 SQL 和 PowerShell 各自成为一套事实来源。

| 项目 | 决策 |
| --- | --- |
| 唯一权威源 | `backend/vibe-starter/src/main/resources/db/migration/` |
| 运行时副本 | Maven 构建把权威源原样打入 `app/vibe-boot.jar` classpath；应用只从该 classpath 位置读取迁移 |
| 包内审计副本 | `db/migration/` 由 `build-prod.ps1` 从同一权威源生成，仅供人工审计和恢复判断，不是执行输入 |
| 迁移清单 | `db/MIGRATION-MANIFEST.json` 记录每个迁移的版本、文件名、SHA256 和风险标记；构建时校验审计副本、清单和 jar 内资源一致 |
| 唯一执行器 | 同一 `app/vibe-boot.jar` 内的 Spring Boot + Flyway 组件；生产只允许一次性 `--vibe.operation=migrate` 维护进程执行，PowerShell 不执行 SQL、不调用 Flyway CLI、不从 `db/migration/` 运行脚本 |
| 运行账号 | 常驻服务账号只具备 `SELECT/INSERT/UPDATE/DELETE`；服务固定 `spring.flyway.enabled=false`，不得长期持有 DDL 凭据 |
| 迁移账号 | 独立账号只对 `vibe_boot.*` 具备 `SELECT/INSERT/UPDATE/DELETE/CREATE/ALTER/DROP/INDEX/REFERENCES`，不得具备 `GRANT OPTION/CREATE USER/FILE/PROCESS/SUPER` 或全局权限 |
| 凭据注入 | P0 每次 install/upgrade 用 `Read-Host -AsSecureString` 交互读取迁移密码；脚本只向 preflight/migrate 维护子进程环境注入 `VIBEBOOT_FLYWAY_USERNAME/PASSWORD`，不得写入参数、日志、manifest、常驻服务配置或落盘文件，子进程退出后立即清理父进程变量；P0 不承诺无人值守迁移 secret 注入 |
| 只读预检 | 脚本调用同一 Jar 的 `--vibe.operation=preflight --spring.flyway.enabled=false`，只读取连接、当前/目标版本和待执行迁移，不得写库 |
| 迁移调用 | 只读预检通过并完成备份/确认后，脚本调用同一 Jar 的 `--vibe.operation=migrate`；该进程只运行 Flyway、输出结果后退出，不启动 Web 服务 |
| 成功判定 | migrate 进程退出 0 且 schema 达到目标版本后才可启动常驻服务；readiness 再次校验 schema 与程序兼容 |
| 失败处理 | migrate 非零时保持服务停止并保留脱敏日志；升级必须使用同一次回滚点整套恢复，不能反复启动服务重试 |

`preflight` 标准输出为单个 JSON 对象，至少包含 `schemaVersion/operation/operationId/currentVersion/targetVersion/pendingMigrations/supportedUpgrade/highRisk/highRiskListSha256/result/errors`；`pendingMigrations` 每项包含 `version/file/description/risk/categories/sha256`。固定退出码为：0 通过，40 配置或 secret 错误，41 数据库连接/TLS/权限错误，42 不支持的升级路径，43 包或迁移完整性错误，44 高风险迁移未确认，50 Flyway 迁移失败。控制台中文摘要写 stderr，stdout 只写机器可解析 JSON。

风险元数据唯一来源为 `backend/vibe-starter/src/main/resources/db/migration-risk.json` schemaVersion=1，每个 SQL 必须恰好一项并匹配 version/file/SHA256；构建期保守扫描与人工 risk 取更高等级。完整 schema、扫描分类和确认协议以 `docs/release-package-design.md` 第 9 节为唯一契约。高风险场景必须同时满足 PowerShell `-ConfirmHighRiskMigration`、管理员交互键入精确短语 `确认执行高风险迁移 <currentVersion或EMPTY> -> <targetVersion>`、同一 operationId 和 Jar 重新计算后未变化的 highRiskListSha256；preflight 与 migrate 均重新校验，P0 不提供无人值守高风险确认。

空数据库的表、角色、菜单、字典和供应商模板由版本化 Flyway 迁移完成，但 Flyway 不创建带密码的管理员。迁移成功后，`install.ps1` 必须调用同一 Jar 的 `--vibe.operation=bootstrap-admin`：用户名固定为 `admin`，密码默认由交互式 `Read-Host -AsSecureString` 输入并二次确认；只有显式 `-GenerateInitialAdminPassword` 才生成 24 位随机值并在成功后只显示一次。两种方式都仅通过子进程 stdin 传入，不得进入参数、环境、文件或日志。维护模式使用运行账号在单个事务中创建首个管理员、写入 PBKDF2 hash，并设置 `password_reset_required=true`、`initial_password_flag=true`；若已存在用户或初始化标记则拒绝重复执行。Procrun 可为建立 service SID 而提前注册但必须保持停止，bootstrap 完成后才允许启动业务服务。

不存在第二套 `db/init`、安装器直跑初始化 SQL 或 Flyway CLI。任何对包内审计副本的手工修改都会导致哈希校验失败，必须阻断安装或升级。

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
| 日常备份 | `mysqldump`、`data/files`、非敏感配置快照、`app/VERSION`、`manifest.json` | 同一完整版本的数据灾难恢复 |
| 升级回滚点 | 日常备份全部内容 + 升级前九类资源 `app/runtime/service/scripts/notices/db/config-public/trusted-launcher/service-registration`、SCM 参数和非敏感配置 | 升级失败后恢复程序、服务注册、数据库、文件和配置的一致状态 |

备份和恢复必须遵守以下契约：

| 项目 | P0 决策 |
| --- | --- |
| 一致性 | 日常备份和升级回滚点都必须在停止 Vibe Boot 服务后创建；独立日常备份校验结束后恢复调用前的服务状态，升级或恢复流程调用备份时保持停服 |
| manifest | 只记录备份类型、产品完整版本、数据库迁移版本、模型主密钥 SHA256 指纹、时间、相对路径、大小和 SHA256；不记录配置值、密码、Token、API Key、主密钥或业务数据摘要 |
| secret 排除 | `config/secrets/**`、`model-master.key`、数据库/Redis/TLS 密码、私钥和任何环境注入 secret 永不进入日常备份或升级回滚点；密钥恢复材料必须由客户通过独立受控渠道保管 |
| 敏感级别 | 数据库导出和业务文件使整个备份目录成为敏感运维资产；不得进入 Git、AI 上下文、日志附件、默认生产包或公开共享目录 |
| Windows 权限 | 默认写入安装目录下的 `backup/`，继承安装目录受限 ACL；P0 不承诺备份加密，复制到其他介质前由管理员负责加密和访问控制 |
| 配置恢复 | 只恢复 allowlist 中的非敏感配置；当前 `config/secrets/` 原地保留且不得由备份覆盖，日志只记录文件名和结果 |
| 模型密钥匹配 | 恢复前比较 manifest 指纹与当前 32-byte 主密钥；不一致时默认阻断。管理员只能先从独立密钥托管恢复匹配密钥，或显式选择 `-DiscardModelCredentials`，调用同一 Jar `--vibe.operation=discard-model-credentials`，在跳过供应商初始化的维护模式中原子设置全部模型配置 `enabled=false, credential_ciphertext=null` 后再启动 |
| Redis 失效 | 数据库或权限数据恢复/回滚后，服务启动前调用同一应用 classpath 的 `--vibe.operation=clear-redis-namespace`；它只可 `SCAN MATCH <prefix>* COUNT 500`、逐 key 复核前缀并每批最多 100 个 UNLINK。禁止 PowerShell 自拼协议、redis-cli、KEYS、FLUSHDB/FLUSHALL，清理失败保持停服 |
| 兼容性 | P0 日常恢复只支持备份的完整产品版本与待恢复程序版本一致；跨版本恢复默认阻断 |
| 升级失败 | Flyway 迁移开始后禁止只回滚 jar 或前端资源；必须停止服务，并使用同一次升级回滚点恢复旧程序、数据库、文件和配置 |
| 数据库回滚 | P0 不提供逆向 Flyway 或自动数据库回滚；MySQL DDL 可能无法事务回退，升级前回滚点是数据库恢复依据 |
| 保留策略 | P0 不自动删除历史备份；空间不足时备份、恢复或升级必须在修改现状前停止 |

恢复前还必须为当前状态创建保护性备份。若保护性备份失败，不得继续覆盖数据库、文件或配置。

升级原子性与崩溃恢复固定如下，完整字段和逐阶段动作以 `docs/release-package-design.md` 第 12 节为唯一执行契约：

| 项目 | P0 冻结决策 |
| --- | --- |
| 维护闸门 | 管理员脚本原子创建 `config/maintenance.flag` 后才停服；闸门存在时全部 `/api/**` 返回 HTTP 503 + `SYS_0503`，Actuator 回环端点保留 |
| 状态 | `operations/upgrade-<operationId>.json` schemaVersion=2，临时文件 flush 后同卷 rename；损坏或现场不一致进入 failed_manual，不猜测 |
| 资源 | `app/runtime/service/scripts/notices/db/config-public/trusted-launcher/service-registration`，每项独立记录 before/target hash 与状态 |
| 资源状态 | `pending -> staged -> live_moved -> next_promoted -> verified`；无变化资源也写 verified |
| 全局 phase | `created -> verified -> preflight_passed -> staged -> maintenance_enabled -> stopped -> backup_complete -> migration_started -> migration_succeeded -> promoting -> promoted -> service_starting -> readiness_passed -> completed` |
| 失败 phase | 只允许 `rollback_required -> rolling_back -> rolled_back` 或 `failed_manual` |
| 数据边界 | migrate 子进程一旦启动即持久化 migrationStarted=true，后续任何失败都必须使用同一次回滚点整套恢复并清 Redis，禁止仅换回 jar |
| 流量开放 | 先写 completed/rolled_back 并复核目标或旧版 readiness，再删除 maintenance.flag；删除失败继续 503，不宣称升级成功 |

## 安全契约

| 项目 | 决策 |
| --- | --- |
| Token | Sa-Token + Redis |
| 开发降级 | Redis 不可用时允许本地内存，仅开发模式 |
| 模型密钥 | 供应商 API Key 以 AES-GCM 密文入库，32-byte 主密钥外置，日志和响应最小化 |
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
| 本地模型配置 | `config/model-local.yml`，只保存模型凭据主密钥和非敏感默认值 |
| runtime 策略 | 源码仓库不提交，开发发行包包含 |

约束：上述默认值只用于降低首次安装和脚本诊断成本。端口、安装目录、数据库连接和服务名可以通过本地或生产配置覆盖；生产密码、TLS 私钥密码、模型凭据主密钥和模型 API Key 不得使用公开默认值。

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
