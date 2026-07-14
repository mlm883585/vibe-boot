# Vibe Boot 数据库基线设计

## 1. 文档目的

本文定义 Vibe Boot MVP 阶段数据库命名、基础字段、表域、迁移、索引、逻辑删除和初始表清单。后续人工编码和 AI 代码生成必须遵守本文。

## 2. 基本决策

| 项目 | 决策 |
| --- | --- |
| 数据库 | MySQL 8 |
| 字符集 | `utf8mb4` |
| 排序规则 | `utf8mb4_0900_ai_ci`，如兼容性需要可退回 `utf8mb4_general_ci` |
| 迁移工具 | Flyway |
| 主键 | Long 雪花 ID |
| 删除策略 | 逻辑删除 |
| 字段命名 | snake_case |
| 时间字段 | datetime |

## 3. 表命名前缀

| 前缀 | 领域 | 示例 |
| --- | --- | --- |
| `sys_` | 系统管理 | `sys_user` |
| `ai_` | AI 工作台 | `ai_task` |
| `skill_` | Skills 与规则 | `skill_definition` |
| `gen_` | 代码生成 | `gen_entity` |
| `file_` | 文件管理 | `file_object` |
| `job_` | 任务调度 | `job_task` |
| `biz_` | 业务模块 | `biz_customer_visit` |

约束：首版不做多 schema，不做多数据源。

## 4. 基础字段

所有业务表默认包含：

| 字段 | 类型 | 必填 | 默认 | 说明 |
| --- | --- | --- | --- | --- |
| id | bigint | 是 | 无 | 雪花 ID |
| created_at | datetime | 是 | 当前时间 | 创建时间 |
| updated_at | datetime | 是 | 当前时间 | 更新时间 |
| created_by | bigint | 否 | null | 创建人 |
| updated_by | bigint | 否 | null | 更新人 |
| deleted | tinyint(1) | 是 | 0 | 逻辑删除 |
| version | int | 是 | 0 | P0 可编辑主记录的乐观锁版本，更新时原子加一 |

可选字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| remark | varchar(500) | 备注 |
| tenant_id | bigint | 多租户预留，P0 不启用 |

`version` 适用于用户、角色、菜单、部门、字典、模型配置、AI/生成任务元数据和生成的业务主表等可编辑主记录。纯追加日志表、只保存关系的中间表和不可变快照表可以省略，但必须在迁移或表设计说明中写明原因。更新接口不得把客户端版本直接写回数据库，只能在匹配旧版本后由数据库表达式原子加一。

## 5. 系统表清单

### 5.1 用户与权限

| 表 | 说明 | P0 |
| --- | --- | --- |
| `sys_user` | 用户 | 是 |
| `sys_role` | 角色 | 是 |
| `sys_menu` | 菜单/按钮权限 | 是 |
| `sys_user_role` | 用户角色关系 | 是 |
| `sys_role_menu` | 角色菜单关系 | 是 |
| `sys_dept` | 部门 | 是 |
| `sys_post` | 岗位 | P1 |

### 5.2 字典与配置

| 表 | 说明 | P0 |
| --- | --- | --- |
| `sys_dict_type` | 字典类型 | 是 |
| `sys_dict_item` | 字典项 | 是 |
| `sys_config` | 系统配置 | 是 |

### 5.3 日志

| 表 | 说明 | P0 |
| --- | --- | --- |
| `sys_login_log` | 登录日志 | 是 |
| `sys_oper_log` | 操作日志 | 是 |

## 6. AI 表清单

| 表 | 说明 | P0 |
| --- | --- | --- |
| `ai_provider` | 模型供应商 | 是 |
| `ai_model_config` | 模型配置 | 是 |
| `ai_task` | AI 任务 | 是 |
| `ai_conversation` | 对话 | 是 |
| `ai_message` | 消息明细 | 是 |
| `ai_context_ref` | 上下文引用 | 是 |
| `ai_patch` | 变更补丁 | P1 |
| `ai_verification` | 验证结果 | P1 |
| `ai_usage_log` | 模型用量 | 是 |

`ai_task` P0 至少保留以下 AI 准入相关字段或等价 JSON：

| 字段 | 说明 |
| --- | --- |
| `stage_code` | S1-S7 或后续阶段 |
| `risk_level` | L0-L3 |
| `admission_card_json` | AI 使用准入卡快照，对应 API 字段 `admissionCard` |
| `handoff_package_json` | 外部 AI 交接包快照 |
| `verification_summary_json` | 验证摘要或待验证原因 |

这些字段只用于开发模式和实施交接追踪，不得作为生产在线执行补丁、SQL 或 shell 的入口。

## 7. Skill 与规则表清单

P0 首选 Markdown 文件，数据库表 P1。若 S3/S4 需要管理端维护，可提前创建。

| 表 | 说明 | P0 |
| --- | --- | --- |
| `skill_definition` | Skill 定义 | 可选 |
| `skill_rule` | 规则 | 可选 |
| `skill_context` | 上下文引用 | 可选 |
| `skill_execution_log` | 使用记录 | 可选 |

## 8. 代码生成表清单

| 表 | 说明 | P0 |
| --- | --- | --- |
| `gen_entity` | 实体元模型 | 是 |
| `gen_field` | 字段元模型 | 是 |
| `gen_page` | 页面元模型 | 是 |
| `gen_permission` | 权限元模型 | 是 |
| `gen_task` | 生成任务 | 是 |
| `gen_artifact` | 生成产物 | 是 |
| `gen_template` | 模板定义 | P1 |
| `gen_template_version` | 模板版本 | P1 |

## 9. 文件表清单

| 表 | 说明 | P0 |
| --- | --- | --- |
| `file_object` | 文件对象 | 是 |
| `file_group` | 文件分组 | P1 |

`file_object` P0 专有字段：

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| storage_type | varchar(16) | 非空，默认 local | P0 只有 local，预留接口不等于已支持 OSS |
| storage_key | varchar(64) | 非空，唯一 | 服务端 UUID，不含用户路径 |
| relative_path | varchar(255) | 非空，唯一 | 仅服务端使用，不进入 API 响应或审计详情 |
| original_name | varchar(200) | 非空 | 清理后的展示名称 |
| extension | varchar(16) | 非空 | 小写白名单扩展名 |
| content_type | varchar(100) | 非空 | 服务端校验后的 MIME |
| size_bytes | bigint | 非空，大于 0 | 实际流式计数 |
| sha256 | char(64) | 非空 | 上传时计算，不用于 P0 跨用户去重 |
| status | varchar(20) | 非空 | uploading、active、deleting、delete_failed、deleted、failed |
| error_summary | varchar(500) | 可空 | 仅保存脱敏失败摘要，不保存绝对路径或堆栈 |

`file_object` 继承统一主键、创建人、创建时间、更新时间和 `deleted` 字段。只有 `active` 可下载或预览；状态进入 `deleted` 时同时设置 `deleted=1`，审计记录不得随文件删除。P0 不增加 business_type/business_id，业务附件绑定留到后续范围决策。

## 10. 任务表清单

| 表 | 说明 | P0 |
| --- | --- | --- |
| `job_task` | 后台任务 | P1 |
| `job_task_log` | 后台任务日志 | P1 |

P0 可先使用内存任务或简单数据库任务记录，复杂调度留到 P1。

## 11. 业务演示表

| 表 | 说明 | 来源 |
| --- | --- | --- |
| `biz_customer_visit` | 客户拜访记录 | `customer-visit-demo-spec.md` |

约束：演示表也必须走 Flyway 迁移。

## 12. 索引规范

| 类型 | 命名 | 示例 |
| --- | --- | --- |
| 主键 | `pk_{table}` | `pk_sys_user` |
| 唯一索引 | `uk_{table}_{columns}` | `uk_sys_user_username` |
| 普通索引 | `idx_{table}_{columns}` | `idx_biz_customer_visit_visit_time` |

索引策略：

| 场景 | 是否建索引 |
| --- | --- |
| 唯一业务键 | 是 |
| 高频查询字段 | 是 |
| 外键关联字段 | 是 |
| 低基数字段 | 谨慎，例如 status 单独索引意义有限 |
| 逻辑删除字段 | 可和业务查询字段组合索引 |

## 13. 约束与外键

首版不强制数据库外键，关系由应用层和索引约束维护。

| 决策 | 理由 |
| --- | --- |
| 不使用物理外键 | 降低迁移和导入复杂度 |
| 使用关系表 | 用户角色、角色菜单等明确关系 |
| 应用层校验 | 删除前检查引用 |

## 14. Flyway 迁移规范

文件路径：

```text
backend/vibe-starter/src/main/resources/db/migration/
```

命名：

```text
V{version}__{description}.sql
```

示例：

| 文件 | 说明 |
| --- | --- |
| `V1__init_system_tables.sql` | 系统基础表 |
| `V2__init_ai_tables.sql` | AI 表 |
| `V3__init_gen_tables.sql` | 代码生成表 |
| `V4__create_biz_customer_visit.sql` | 演示业务表 |

约束：

| 约束 | 说明 |
| --- | --- |
| 不修改已发布迁移 | 新增变更写新文件 |
| 高风险 SQL 需确认 | DROP/DELETE/ALTER 删除字段 |
| SQL 必须有注释 | 表和字段注释 |
| 迁移顺序稳定 | 版本号不可跳跃混乱 |

## 15. 初始数据规范

P0 初始数据：

| 数据 | 说明 |
| --- | --- |
| 超级管理员 | `admin`，初始密码安装时生成或首次启动提示 |
| 管理员角色 | 拥有全部权限 |
| 基础菜单 | 系统管理、AI 工作台、代码生成、文件管理 |
| 基础字典 | 状态、是否、拜访方式等 |
| 模型供应商模板 | OpenAI 兼容、国内模型占位 |

约束：初始密码不能硬编码为公开固定密码进入生产包。生产初始化必须通过安装输入、一次性随机生成或外置密钥文件设置超级管理员密码，并把 `password_reset_required` 和 `initial_password_flag` 置为 true，首次登录后强制修改密码并清除初始化标记。初始化密码不得写入 Flyway 明文 SQL、Git、日志、AI 上下文或备份摘要。

`sys_user.username` 使用规范化后的小写 ASCII 登录名并建立唯一索引；`password_hash` 使用 `varchar(255)` 保存自描述 PBKDF2 格式。密码 salt、算法和迭代次数包含在该字段中，不拆成全局 salt，不建立可逆密码字段。登录限流计数和 CSRF Token 只存在 Redis/会话中，不新增 MySQL 明文凭据表。

## 16. 字段类型映射

| 业务类型 | Java | TypeScript | MySQL |
| --- | --- | --- | --- |
| id | Long | string | bigint |
| string | String | string | varchar |
| text | String | string | text |
| int | Integer | number | int |
| long | Long | string | bigint |
| decimal | BigDecimal | number/string | decimal |
| boolean | Boolean | boolean | tinyint(1) |
| date | LocalDate | string | date |
| datetime | LocalDateTime | string | datetime |
| enum | String/Enum | string | varchar |

前端对 Long ID 使用 string，避免 JS 精度问题。

## 17. 数据安全约束

| 约束 | 说明 |
| --- | --- |
| 密钥不明文存储 | API Key 使用加密或受保护配置 |
| 密码只存 hash | 不存明文 |
| 日志表不记录敏感原文 | 请求参数需脱敏 |
| 删除使用逻辑删除 | P0 默认 |
| 生产迁移前备份 | release 包约束 |

逻辑删除与恢复边界：

| 场景 | P0 约束 |
| --- | --- |
| 普通业务删除 | 默认设置 `deleted=1`，列表和详情默认不返回 |
| 系统基础数据删除 | 用户、角色、菜单、部门、字典删除前必须做引用校验 |
| 物理删除 | P0 不提供业务后台入口，清理归档留到 P1 |
| 恢复删除数据 | P0 不提供通用恢复页面，依赖备份恢复或后续专门功能 |
| 唯一索引 | 需要考虑逻辑删除后的唯一约束策略，避免删除后无法重建同名业务数据 |

数据权限与审计字段：

| 字段/能力 | 约束 |
| --- | --- |
| `created_by` | 仅本人数据的默认依据之一 |
| `dept_id` | 需要部门数据范围的业务表可显式增加 |
| 操作日志目标对象 | 日志应记录 target_type、target_id 或等价字段 |
| traceId | 登录日志、操作日志、AI 任务和脚本日志应尽量可串联 |

## 18. 编码准入

进入数据库相关编码前必须确认：

| 条件 | 状态 |
| --- | --- |
| MySQL 8 | 已由 ADR-0001 确认 |
| Flyway | 已由 ADR-0001 确认 |
| 雪花 ID | 已由 ADR-0001 确认 |
| 基础字段 | 已由本文确认 |
| P0 表清单 | 已由本文确认 |
| 迁移路径 | 已由本文确认 |
| 长整型前端映射 | 已由本文确认 |

## 19. 一句话总结

Vibe Boot 的数据库基线必须支持真实企业系统的长期演进：命名统一、字段统一、迁移统一、权限和 AI 相关数据可审计，同时不为了首版引入多数据库和复杂外键体系。
