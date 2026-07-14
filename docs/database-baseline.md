# Vibe Boot 数据库基线设计

## 1. 文档目的

本文定义 Vibe Boot MVP 阶段数据库命名、基础字段、表域、迁移、索引、逻辑删除和初始表清单。后续人工编码和 AI 代码生成必须遵守本文。

## 2. 基本决策

| 项目 | 决策 |
| --- | --- |
| 数据库 | MySQL 8 |
| 字符集 | `utf8mb4` |
| 排序规则 | 固定 `utf8mb4_0900_ai_ci`；P0 不提供第二排序规则分支 |
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

按具体表声明的可选字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| remark | varchar(500) | 备注 |
| tenant_id | bigint | P0 禁止创建；未来多租户 ADR 通过后只能以新 Flyway 迁移增加 |

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

`ai_model_config` 的凭据字段固定如下：

| 字段 | 类型 | 约束 |
| --- | --- | --- |
| `credential_ciphertext` | varchar(2048) | 可空；只保存 ADR-0002 的版本化 AES-GCM 密文，不保存明文或主密钥 |
| `version` | int | 非空；更新凭据和配置时使用乐观锁，防止并发覆盖 |

API DTO 不得复用数据库实体。`credential_ciphertext` 永不序列化到响应；响应通过“字段非空且格式可识别”派生 `credentialConfigured`，实际解密只发生在连接测试或供应商调用的最短作用域。

`ai_task` P0 固定保留下列 AI 准入与审计字段，不允许改名或拆到未定义关联表：

| 字段 | 说明 |
| --- | --- |
| `stage_code` | S1-S7 或后续阶段 |
| `risk_level` | L0-L3 |
| `admission_card_json` | AI 使用准入卡快照，对应 API 字段 `admissionCard` |
| `handoff_package_json` | 外部 AI 交接包快照 |
| `verification_summary_json` | 验证摘要或待验证原因 |
| `skill_snapshot_json` | 当次加载的 Skill 版本、来源和 checksum 快照 |
| `rule_snapshot_json` | 当次规则、优先级、状态和处理动作快照 |
| `resolution_trace_json` | 规则冲突裁决、阻断项和警告项轨迹 |

这些字段只用于开发模式和实施交接追踪，不得作为生产在线执行补丁、SQL 或 shell 的入口。

## 7. Skill 与规则表清单

P0 固定以仓库内 Markdown 文件作为 Skill/规则权威源，不创建下表；每个 AI 任务只在 `ai_task` 的快照字段中保存当次加载结果。下表统一属于 P1，只有完成新的阶段准入和数据库迁移评审后才能创建。

| 表 | 说明 | P0 |
| --- | --- | --- |
| `skill_definition` | Skill 定义 | P1 |
| `skill_rule` | 规则 | P1 |
| `skill_context` | 上下文引用 | P1 |
| `skill_execution_log` | 使用记录 | P1 |

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

P0 不实现通用后台任务调度，也不创建 `job_*` 表或通用内存任务框架。AI 任务固定持久化到 `ai_task`，代码生成作业固定持久化到 `gen_task`；通用调度统一留到 P1。

## 11. 业务演示表

| 表 | 说明 | 来源 |
| --- | --- | --- |
| `biz_customer_visit` | 客户拜访记录 | `customer-visit-demo-spec.md` |

约束：演示表也必须走 Flyway 迁移。

## 12. P0 规范化逻辑 DDL

本节是 S2-S4 迁移的唯一字段基线，不再把列名、长度、null/default 或枚举留给实现者。记号：`N`=NOT NULL，`?`=NULL；未写 default 即无 default。所有表使用 InnoDB、`utf8mb4_0900_ai_ci`，主键均为应用生成的 signed `bigint` 雪花 ID，不使用 AUTO_INCREMENT。

通用列模板只有以下三种；具体表不得暗中增加模板列：

| 模板 | 精确列 |
| --- | --- |
| `E` 可编辑实体 | `id bigint N`；`created_at datetime(3) N default CURRENT_TIMESTAMP(3)`；`updated_at datetime(3) N default CURRENT_TIMESTAMP(3) on update CURRENT_TIMESTAMP(3)`；`created_by bigint ?`；`updated_by bigint ?`；`deleted tinyint(1) N default 0`；`version int N default 0` |
| `R` 关系记录 | `id bigint N`；`created_at datetime(3) N default CURRENT_TIMESTAMP(3)`；`created_by bigint ?`；不含 deleted/version，集合保存时允许物理删除关系行 |
| `A` 追加记录 | `id bigint N`；其事件时间、操作者和 traceId 由表专有列声明；不含 updated/deleted/version，P0 API 不提供删除或更新 |

数据库会话时区固定 UTC，所有 `datetime(3)` 存 UTC；API 输出 ISO 8601 UTC，前端显示时转换为用户时区，P0 默认 `Asia/Shanghai`。模型每日配额仍按 `Asia/Shanghai` 自然日计算，不能用数据库 UTC 日期直接替代。

### 12.1 系统域

| 表 | 模板 | 专有列（名称 类型 null/default/约束） |
| --- | --- | --- |
| `sys_user` | E | `username varchar(64) N`；`password_hash varchar(255) N`；`nickname varchar(64) N`；`mobile varchar(32) ?`；`email varchar(128) ?`；`dept_id bigint N`；`status varchar(16) N default 'enabled'`；`last_login_at datetime(3) ?`；`password_changed_at datetime(3) ?`；`password_reset_required tinyint(1) N default 1`；`initial_password_flag tinyint(1) N default 1` |
| `sys_role` | E | `role_code varchar(64) N`；`role_name varchar(100) N`；`data_scope varchar(32) N default 'self'`；`status varchar(16) N default 'enabled'`；`sort_order int N default 0`；`built_in tinyint(1) N default 0`；`remark varchar(500) ?` |
| `sys_menu` | E | `parent_id bigint N default 0`；`menu_type varchar(16) N`；`menu_name varchar(100) N`；`route_path varchar(200) ?`；`component varchar(255) ?`；`permission varchar(128) ?`；`icon varchar(64) ?`；`visible tinyint(1) N default 1`；`status varchar(16) N default 'enabled'`；`sort_order int N default 0` |
| `sys_dept` | E | `parent_id bigint N default 0`；`dept_name varchar(100) N`；`dept_code varchar(64) N`；`status varchar(16) N default 'enabled'`；`sort_order int N default 0`；`remark varchar(500) ?` |
| `sys_user_role` | R | `user_id bigint N`；`role_id bigint N` |
| `sys_role_menu` | R | `role_id bigint N`；`menu_id bigint N` |
| `sys_dict_type` | E | `dict_code varchar(64) N`；`dict_name varchar(100) N`；`status varchar(16) N default 'enabled'`；`remark varchar(500) ?` |
| `sys_dict_item` | E | `dict_code varchar(64) N`；`item_label varchar(100) N`；`item_value varchar(100) N`；`status varchar(16) N default 'enabled'`；`sort_order int N default 0`；`remark varchar(500) ?` |
| `sys_config` | E | `config_key varchar(128) N`；`config_value varchar(2000) N`；`config_name varchar(100) N`；`config_type varchar(32) N default 'system'`；`status varchar(16) N default 'enabled'`；`remark varchar(500) ?` |
| `sys_login_log` | A | `username varchar(64) N`；`user_id bigint ?`；`login_ip varchar(45) N`；`login_status varchar(16) N`；`fail_reason varchar(255) ?`；`user_agent varchar(500) ?`；`trace_id char(32) N`；`login_at datetime(3) N default CURRENT_TIMESTAMP(3)` |
| `sys_oper_log` | A | `user_id bigint ?`；`username varchar(64) ?`；`module varchar(64) N`；`operation varchar(64) N`；`method varchar(255) N`；`path varchar(255) N`；`request_method varchar(10) N`；`status varchar(16) N`；`error_code varchar(64) ?`；`error_message varchar(500) ?`；`duration_ms bigint N default 0`；`target_type varchar(64) ?`；`target_id varchar(64) ?`；`trace_id char(32) N`；`oper_at datetime(3) N default CURRENT_TIMESTAMP(3)` |

`sys_user.username`、`sys_role.role_code`、`sys_menu.permission`、`sys_dept.dept_code`、`sys_dict_type.dict_code` 和 `sys_config.config_key` 一经使用不得因逻辑删除而复用，使用全表唯一索引。`sys_menu.permission` 可为 null，目录项和无按钮权限的菜单允许多个 null。

### 12.2 AI 域

| 表 | 模板 | 专有列（名称 类型 null/default/约束） |
| --- | --- | --- |
| `ai_provider` | E | `provider_code varchar(64) N`；`provider_name varchar(100) N`；`default_api_base varchar(500) ?`；`status varchar(16) N default 'enabled'`；`sort_order int N default 0`；`remark varchar(500) ?` |
| `ai_model_config` | E | `provider_code varchar(64) N`；`api_base varchar(500) N`；`credential_ciphertext varchar(2048) ?`；`model_name varchar(128) N`；`model_type varchar(16) N default 'chat'`；`enabled tinyint(1) N default 1`；`timeout_seconds int N default 60`；`max_tokens int N default 2048`；`rate_limit_per_minute int N default 30`；`user_rate_limit_per_minute int N default 10`；`daily_call_limit int N default 1000`；`daily_token_limit bigint N default 1000000`；`remark varchar(500) ?` |
| `ai_task` | E | `task_title varchar(200) N`；`task_type varchar(32) N`；`status varchar(32) N default 'draft'`；`user_input text N`；`context_summary text ?`；`plan_json json ?`；`risk_level varchar(2) N default 'L0'`；`model_config_id bigint ?`；`stage_code varchar(16) N`；`admission_card_json json N`；`handoff_package_json json ?`；`verification_summary_json json ?`；`skill_snapshot_json json N`；`rule_snapshot_json json N`；`resolution_trace_json json N`；`confirmation_json json ?`；`confirmed_by bigint ?`；`error_code varchar(64) ?`；`error_summary varchar(500) ?`；`confirmed_at datetime(3) ?`；`completed_at datetime(3) ?` |
| `ai_conversation` | E | `task_id bigint N`；`title varchar(200) N`；`status varchar(16) N default 'active'` |
| `ai_message` | A | `task_id bigint N`；`conversation_id bigint N`；`sequence_no int N`；`role varchar(16) N`；`content mediumtext N`；`model_config_id bigint ?`；`prompt_tokens int ?`；`completion_tokens int ?`；`trace_id char(32) N`；`created_by bigint ?`；`created_at datetime(3) N default CURRENT_TIMESTAMP(3)` |
| `ai_context_ref` | E | `task_id bigint N`；`ref_type varchar(32) N`；`ref_path varchar(500) N`；`display_name varchar(200) N`；`content_sha256 char(64) ?`；`data_class varchar(16) N default 'internal'`；`included tinyint(1) N default 1` |
| `ai_usage_log` | A | `task_id bigint ?`；`model_config_id bigint N`；`provider_code varchar(64) N`；`model_name varchar(128) N`；`purpose varchar(32) N`；`prompt_tokens int ?`；`completion_tokens int ?`；`total_tokens int ?`；`duration_ms bigint N`；`success tinyint(1) N`；`error_code varchar(64) ?`；`quota_result varchar(32) N`；`trace_id char(32) N`；`provider_request_id varchar(128) ?`；`created_by bigint ?`；`created_at datetime(3) N default CURRENT_TIMESTAMP(3)` |

P0 `ai_task.task_type` 固定为 `requirements_clarification|document_revision|crud_generation|code_change|handoff_generation|code_explanation`；status 使用 AI 工作台冻结状态集合。`ai_message.role` 固定 `system_summary|user|assistant`，禁止保存原始 system secret；`data_class` 固定 `public|internal|sensitive|secret`，secret 不得进入 message/context。生产包不包含 ai_task/conversation/message/context 的开发型页面或 API，但为同一代码线保留数据库历史不等于生产可执行开发任务。

### 12.3 代码生成、文件与演示业务域

| 表 | 模板 | 专有列（名称 类型 null/default/约束） |
| --- | --- | --- |
| `gen_entity` | E | `ai_task_id bigint ?`；`schema_version int N default 1`；`entity_name varchar(64) N`；`table_name varchar(64) N`；`module_name varchar(32) N default 'biz'`；`resource_name varchar(64) N`；`display_name varchar(100) N`；`description varchar(500) N`；`meta_json json N`；`meta_hash char(64) N`；`status varchar(16) N default 'draft'` |
| `gen_field` | E | `entity_id bigint N`；`field_name varchar(64) N`；`column_name varchar(64) N`；`display_name varchar(100) N`；`data_type varchar(32) N`；`db_type varchar(64) N`；`required_flag tinyint(1) N default 0`；`unique_flag tinyint(1) N default 0`；`searchable tinyint(1) N default 0`；`list_visible tinyint(1) N default 1`；`form_visible tinyint(1) N default 1`；`dict_type varchar(64) ?`；`default_value varchar(500) ?`；`validation_json json N`；`enum_values_json json N`；`sort_order int N default 0` |
| `gen_page` | E | `entity_id bigint N`；`list_page tinyint(1) N default 1`；`create_form tinyint(1) N default 1`；`update_form tinyint(1) N default 1`；`detail_page tinyint(1) N default 0`；`search_fields_json json N`；`table_columns_json json N`；`row_actions_json json N`；`batch_actions_json json N` |
| `gen_permission` | E | `entity_id bigint N`；`action varchar(32) N`；`permission varchar(128) N`；`display_name varchar(100) N` |
| `gen_task` | E | `ai_task_id bigint ?`；`entity_id bigint N`；`meta_hash char(64) N`；`status varchar(32) N default 'draft'`；`target_module varchar(32) N default 'vibe-biz'`；`preview_json json ?`；`preview_hash char(64) ?`；`conflict_summary varchar(1000) ?`；`verification_summary_json json ?`；`started_at datetime(3) ?`；`completed_at datetime(3) ?` |
| `gen_artifact` | E | `gen_task_id bigint N`；`entity_id bigint N`；`artifact_path varchar(500) N`；`artifact_type varchar(32) N`；`template_version varchar(32) N`；`meta_hash char(64) N`；`artifact_hash char(64) N`；`ownership varchar(16) N default 'generated'`；`last_generated_at datetime(3) N` |
| `file_object` | E | `storage_type varchar(16) N default 'local'`；`storage_key varchar(64) N`；`relative_path varchar(255) N`；`original_name varchar(200) N`；`extension varchar(16) N`；`content_type varchar(100) N`；`size_bytes bigint N`；`sha256 char(64) N`；`status varchar(20) N`；`error_summary varchar(500) ?` |
| `biz_customer_visit` | E | `customer_name varchar(100) N`；`contact_name varchar(50) ?`；`visit_time datetime(3) N`；`visit_type varchar(16) N`；`summary text N`；`next_action varchar(255) ?`；`owner_user_id bigint N`；`status varchar(16) N default 'draft'` |

固定枚举：gen entity status=`draft|confirmed|conflict`；gen task status=`draft|planned|confirmed|generated|conflict|blocked|verified|failed`；artifact type=`java|vue|sql|menu|doc`；ownership=`generated|user_owned|conflict`；file status=`uploading|active|deleting|delete_failed|deleted|failed`；visit_type=`phone|onsite|online`；visit status=`draft|completed|cancelled`。静态枚举必须同时由 Bean Validation 和 MySQL 8 enforced CHECK 约束，布尔列 CHECK in (0,1)，version/size/token/duration 不得为负。

P0 迁移不得创建 view、trigger、stored procedure/function 或 event；所有表均为 InnoDB。这样应用行为、`mysqldump` 最小权限和恢复检查使用同一对象集合。

## 13. 索引规范

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

所有 P0 表必须创建 `pk_{table}(id)`；除此之外的基线索引固定如下，没有列出的索引不得在首个迁移里凭感觉增加：

| 表 | 唯一索引 | 普通索引 |
| --- | --- | --- |
| `sys_user` | `uk_sys_user_username(username)` | `idx_sys_user_dept_deleted(dept_id,deleted,id)`；`idx_sys_user_status_deleted(status,deleted,id)` |
| `sys_role` | `uk_sys_role_role_code(role_code)` | `idx_sys_role_status_sort(status,deleted,sort_order,id)` |
| `sys_menu` | `uk_sys_menu_permission(permission)`；`uk_sys_menu_route_path(route_path)` | `idx_sys_menu_parent_sort(parent_id,deleted,sort_order,id)` |
| `sys_dept` | `uk_sys_dept_dept_code(dept_code)` | `idx_sys_dept_parent_sort(parent_id,deleted,sort_order,id)` |
| `sys_user_role` | `uk_sys_user_role_user_role(user_id,role_id)` | `idx_sys_user_role_role_user(role_id,user_id)` |
| `sys_role_menu` | `uk_sys_role_menu_role_menu(role_id,menu_id)` | `idx_sys_role_menu_menu_role(menu_id,role_id)` |
| `sys_dict_type` | `uk_sys_dict_type_dict_code(dict_code)` | `idx_sys_dict_type_status(status,deleted,id)` |
| `sys_dict_item` | `uk_sys_dict_item_code_value(dict_code,item_value)` | `idx_sys_dict_item_code_status_sort(dict_code,status,deleted,sort_order,id)` |
| `sys_config` | `uk_sys_config_config_key(config_key)` | `idx_sys_config_status(status,deleted,id)` |
| `sys_login_log` | 无 | `idx_sys_login_log_login_at(login_at,id)`；`idx_sys_login_log_user_at(user_id,login_at,id)`；`idx_sys_login_log_trace(trace_id)` |
| `sys_oper_log` | 无 | `idx_sys_oper_log_oper_at(oper_at,id)`；`idx_sys_oper_log_user_at(user_id,oper_at,id)`；`idx_sys_oper_log_target(target_type,target_id,oper_at)`；`idx_sys_oper_log_trace(trace_id)` |
| `ai_provider` | `uk_ai_provider_code(provider_code)` | `idx_ai_provider_status_sort(status,deleted,sort_order,id)` |
| `ai_model_config` | 无 | `idx_ai_model_provider_enabled(provider_code,enabled,deleted,id)` |
| `ai_task` | 无 | `idx_ai_task_status_created(status,created_at,id)`；`idx_ai_task_creator_created(created_by,created_at,id)`；`idx_ai_task_stage_status(stage_code,status,id)` |
| `ai_conversation` | 无 | `idx_ai_conversation_task_created(task_id,created_at,id)` |
| `ai_message` | `uk_ai_message_conversation_seq(conversation_id,sequence_no)` | `idx_ai_message_task_created(task_id,created_at,id)`；`idx_ai_message_trace(trace_id)` |
| `ai_context_ref` | `uk_ai_context_task_type_path(task_id,ref_type,ref_path)` | `idx_ai_context_task_included(task_id,included,deleted,id)` |
| `ai_usage_log` | 无 | `idx_ai_usage_model_created(model_config_id,created_at,id)`；`idx_ai_usage_task_created(task_id,created_at,id)`；`idx_ai_usage_trace(trace_id)` |
| `gen_entity` | `uk_gen_entity_table_name(table_name)`；`uk_gen_entity_resource_name(resource_name)` | `idx_gen_entity_status(status,deleted,id)` |
| `gen_field` | `uk_gen_field_entity_field(entity_id,field_name)`；`uk_gen_field_entity_column(entity_id,column_name)` | `idx_gen_field_entity_sort(entity_id,deleted,sort_order,id)` |
| `gen_page` | `uk_gen_page_entity(entity_id)` | 无 |
| `gen_permission` | `uk_gen_permission_entity_action(entity_id,action)`；`uk_gen_permission_value(permission)` | `idx_gen_permission_entity(entity_id,deleted,id)` |
| `gen_task` | 无 | `idx_gen_task_entity_created(entity_id,created_at,id)`；`idx_gen_task_status_created(status,created_at,id)` |
| `gen_artifact` | `uk_gen_artifact_path(artifact_path)` | `idx_gen_artifact_task(gen_task_id,deleted,id)`；`idx_gen_artifact_entity(entity_id,deleted,id)` |
| `file_object` | `uk_file_object_storage_key(storage_key)`；`uk_file_object_relative_path(relative_path)` | `idx_file_object_status_created(status,created_at,id)`；`idx_file_object_creator_created(created_by,created_at,id)` |
| `biz_customer_visit` | 无 | `idx_biz_visit_owner_time(owner_user_id,deleted,visit_time,id)`；`idx_biz_visit_status_time(status,deleted,visit_time,id)`；`idx_biz_visit_customer(customer_name,deleted,id)` |

分页排序只能使用上述索引可支持的白名单。上线后只有慢查询证据、预期基数和回归测试齐全时才可通过新 Flyway 增加索引；不得修改已发布迁移。

## 14. 约束与外键

首版不强制数据库外键，关系由应用层和索引约束维护。

| 决策 | 理由 |
| --- | --- |
| 不使用物理外键 | 降低迁移和导入复杂度 |
| 使用关系表 | 用户角色、角色菜单等明确关系 |
| 应用层校验 | 删除前检查引用 |

## 15. Flyway 迁移规范

文件路径：

```text
backend/vibe-starter/src/main/resources/db/migration/
backend/vibe-starter/src/main/resources/db/migration-risk.json
```

该目录中的 SQL 是唯一执行源，`migration-risk.json` 是唯一风险元数据源。Maven 将两者原样打入生产 jar；`build-prod.ps1` 同时生成 `db/migration/` 只读审计副本和 `db/MIGRATION-MANIFEST.json` 投影，并校验源码、jar 内资源、风险条目和审计副本 SHA256 一致。审计副本/生成 manifest 不得被安装脚本执行或手工覆盖风险。

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
| 风险条目完整 | 每个 SQL 在 `migration-risk.json` 恰好一项，schema/字段/分类/sha256 规则以 `release-package-design.md` 第 9 节为准 |
| 高风险 SQL 需确认 | 构建期保守词法扫描与人工 high 标记取更高者；生产按 `-ConfirmHighRiskMigration` + 精确短语 + 列表 hash 双重确认 |
| SQL 必须有注释 | 表和字段注释 |
| 迁移顺序稳定 | 版本号不可跳跃混乱 |
| 执行器唯一 | 只允许同一 `vibe-boot.jar` 的 `--vibe.operation=migrate` 维护进程内 Flyway 执行；PowerShell、常驻服务、Flyway CLI 和手工 SQL 不得执行迁移 |
| 空库同一路径 | 初始化表和初始数据也使用版本化迁移，不建立独立 `db/init` 流程 |
| 包内副本可验证 | `db/MIGRATION-MANIFEST.json` 必须记录版本、文件名、SHA256 和风险标记，任一副本不一致即阻断 |
| 失败不重试 | 迁移失败时 readiness 不得为 `UP`，服务保持停止；升级按同一次回滚点整套恢复 |

## 16. 初始数据规范

P0 初始数据：

| 数据 | 说明 |
| --- | --- |
| 超级管理员 | 不由 Flyway 插入；迁移后由同一 Jar 的 `bootstrap-admin` 维护模式创建固定用户名 `admin` |
| 根部门 | Flyway 插入不可删除的 `ROOT` 部门，bootstrap-admin 的 dept_id 固定指向该记录 |
| 管理员角色 | 拥有全部权限 |
| 基础菜单 | 系统管理、AI 工作台、代码生成、文件管理 |
| 基础字典 | 状态、是否、拜访方式等 |
| 模型供应商模板 | OpenAI 兼容、国内模型占位 |

约束：Flyway 只插入不含 secret 的根部门、角色、菜单、字典和供应商模板。生产迁移成功后，`install.ps1` 调用同一 Jar 的 `--vibe.operation=bootstrap-admin`；初始密码默认由 `Read-Host -AsSecureString` 交互输入并二次确认，只有显式 `-GenerateInitialAdminPassword` 才生成冻结规则的 24 位随机值并在成功后只显示一次。两种方式都只经子进程 stdin 传入，不进入命令行、环境变量、文件或日志。维护模式以运行账号在单个事务中写用户、管理员角色关系和初始化标记，把 `password_reset_required`、`initial_password_flag` 置为 true；若已存在用户或初始化完成标记则拒绝重复执行。首次登录后必须强制改密并清除两个标记。

`sys_user.username` 使用规范化后的小写 ASCII 登录名并建立唯一索引；`password_hash` 使用 `varchar(255)` 保存自描述 PBKDF2 格式。密码 salt、算法和迭代次数包含在该字段中，不拆成全局 salt，不建立可逆密码字段。登录限流计数和 CSRF Token 只存在 Redis/会话中，不新增 MySQL 明文凭据表。

## 17. 字段类型映射

| 业务类型 | Java | TypeScript | MySQL |
| --- | --- | --- | --- |
| id | Long | string | bigint |
| string | String | string | varchar |
| text | String | string | text |
| int | Integer | number | int |
| long | Long | string | bigint |
| decimal | BigDecimal | string | decimal(p,s)，默认 `decimal(20,4)`；元模型可显式收窄 precision/scale |
| boolean | Boolean | boolean | tinyint(1) |
| date | LocalDate | string | date |
| datetime | LocalDateTime | string | datetime(3) |
| enum | String + Bean Validation | string literal union | 最长 value≤16/32/64 时分别使用 `varchar(16/32/64)` + enforced CHECK；P0 禁止 MySQL ENUM |

前端对 Long ID 使用 string，避免 JS 精度问题。

## 18. 数据安全约束

| 约束 | 说明 |
| --- | --- |
| 密钥不明文存储 | 模型 API Key 使用 ADR-0002 的 AES-GCM 密文；32-byte 外置主密钥不得进入数据库 |
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
| 唯一索引 | 逻辑删除表若业务键要求“仅活动记录唯一”，固定增加生成列 `active_unique_flag tinyint generated always as (if(deleted=0,1,null)) stored`，并建立 `(规范化业务键, active_unique_flag)` 唯一索引；利用 MySQL 多个 NULL 可共存，禁止只建 `(业务键, deleted)` |

数据权限与审计字段：

| 字段/能力 | 约束 |
| --- | --- |
| `created_by` | 仅本人数据的默认依据之一 |
| `dept_id` | 需要部门数据范围的业务表可显式增加 |
| 操作日志目标对象 | 固定字段 `target_type varchar(64)` 与 `target_id varchar(64)`；无目标对象的动作允许两者均为 null，不使用随意命名的等价字段 |
| traceId | 登录日志、操作日志和 AI 用量/任务记录固定保存 `trace_id varchar(64)`；脚本日志每次操作固定保存 `operationId` 并在调用应用时同时记录 traceId |

## 19. 编码准入

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

## 20. 一句话总结

Vibe Boot 的数据库基线必须支持真实企业系统的长期演进：命名统一、字段统一、迁移统一、权限和 AI 相关数据可审计，同时不为了首版引入多数据库和复杂外键体系。
