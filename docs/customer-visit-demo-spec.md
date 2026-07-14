# Vibe Boot MVP 演示用例：客户拜访记录

## 1. 文档目的

本文定义 Vibe Boot MVP 第一条端到端演示用例：“客户拜访记录”模块。该模块用于验证 AI 工作台、代码生成、权限菜单、前端页面、SQL 迁移、验证命令和生产打包链路。

本文只定义演示规格，不实现代码。

本用例的 API、错误码、权限标识遵循 `docs/api-conventions.md`；数据库字段、迁移、基础字段和类型映射遵循 `docs/database-baseline.md`。

## 2. 演示目标

| 目标 | 说明 |
| --- | --- |
| 验证 AI coding | 用户通过自然语言提出需求，AI 生成计划和代码 |
| 验证 CRUD 生成 | 单表业务模块完整生成 |
| 验证权限菜单 | 生成菜单、按钮和接口权限 |
| 验证前后端 | Java API 和 Vue 页面可配合 |
| 验证数据库迁移 | Flyway SQL 可创建表和权限数据 |
| 验证质量门禁 | 后端编译、前端构建可通过 |
| 验证发布链路 | 后续可进入生产安装包 |

## 3. 用户原始需求

演示时用户输入：

```text
帮我做一个客户拜访记录模块，销售人员可以记录拜访客户的时间、联系人、拜访方式、纪要和下一步动作，主管可以查看所有记录。
```

AI 不应直接生成代码，应先澄清关键问题。

## 4. AI 澄清问题

P0 演示建议 AI 至少提出：

| 问题 | 默认答案 |
| --- | --- |
| 客户是否需要单独建表 | P0 不建客户表，先用客户名称文本 |
| 拜访方式有哪些 | 电话、上门、线上会议 |
| 状态有哪些 | 草稿、已完成、已取消 |
| 谁能查看数据 | 销售看本人，主管/管理员看全部 |
| 是否需要导出 | P0 不做，P1 支持 |
| 是否需要附件 | P0 不做 |
| 是否需要审批 | P0 不做 |

## 5. 业务边界

| 范围 | P0 是否支持 |
| --- | --- |
| 新增拜访记录 | 支持 |
| 编辑拜访记录 | 支持 |
| 删除拜访记录 | 支持，逻辑删除 |
| 列表查询 | 支持 |
| 按客户名称搜索 | 支持 |
| 按拜访时间搜索 | 支持 |
| 按状态搜索 | 支持 |
| 数据权限 | P0 生成说明，S2/S4 实现时接入 |
| 导出 Excel | 不支持，P2 |
| 附件上传 | 不支持，P2；平台 P0 文件基础服务不等于业务附件已绑定 |
| 审批流 | 不支持，P2 |
| 关联客户主数据 | 不支持，P2 |

## 6. 实体元模型

| 字段 | 值 |
| --- | --- |
| entityName | CustomerVisit |
| displayName | 客户拜访记录 |
| moduleName | biz |
| resourceName | customerVisit |
| tableName | biz_customer_visit |
| packageName | com.vibeboot.biz.customervisit |

说明：`biz` 业务模块在 S4 可作为生成目标模块；若首版暂未创建独立 `vibe-biz` 模块，也可以生成到 `vibe-system` 的 demo 包，但必须在生成计划中说明。

## 7. 字段定义

| 字段名 | 数据库字段 | 类型 | 必填 | 列表 | 表单 | 搜索 | 说明 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| id | id | Long | 是 | 否 | 否 | 否 | 雪花 ID |
| customerName | customer_name | String(100) | 是 | 是 | 是 | 是 | 客户名称 |
| contactName | contact_name | String(50) | 否 | 是 | 是 | 否 | 联系人 |
| visitTime | visit_time | DateTime | 是 | 是 | 是 | 是 | 拜访时间 |
| visitType | visit_type | Enum | 是 | 是 | 是 | 否 | 拜访方式 |
| summary | summary | Text | 是 | 否 | 是 | 否 | 拜访纪要 |
| nextAction | next_action | String(255) | 否 | 是 | 是 | 否 | 下一步动作 |
| ownerUserId | owner_user_id | Long | 是 | 是 | 否 | 否 | 负责人 |
| status | status | Enum | 是 | 是 | 是 | 是 | 状态 |
| createdAt | created_at | DateTime | 是 | 是 | 否 | 否 | 创建时间 |
| updatedAt | updated_at | DateTime | 是 | 否 | 否 | 否 | 更新时间 |
| createdBy | created_by | Long | 否 | 否 | 否 | 否 | 创建人 |
| updatedBy | updated_by | Long | 否 | 否 | 否 | 否 | 更新人 |
| deleted | deleted | Boolean | 是 | 否 | 否 | 否 | 逻辑删除 |
| version | version | Integer | 是 | 是 | 否 | 否 | 乐观锁版本，默认 0 |

编辑接口必须提交当前 version，成功后原子加一。两个会话编辑同一条拜访记录时，后提交者返回 `DATA_0409` 并提示重新加载，不得静默覆盖先提交内容。

## 8. 枚举定义

### 8.1 拜访方式

| 值 | 标签 |
| --- | --- |
| phone | 电话 |
| onsite | 上门 |
| online | 线上会议 |

### 8.2 状态

| 值 | 标签 |
| --- | --- |
| draft | 草稿 |
| completed | 已完成 |
| cancelled | 已取消 |

## 9. 权限定义

| 动作 | 权限标识 | 说明 |
| --- | --- | --- |
| list | `biz:customerVisit:list` | 查看列表 |
| query | `biz:customerVisit:query` | 查询详情 |
| create | `biz:customerVisit:create` | 新增 |
| update | `biz:customerVisit:update` | 编辑 |
| delete | `biz:customerVisit:delete` | 删除 |
| export | `biz:customerVisit:export` | P1 预留 |

菜单：

| 字段 | 值 |
| --- | --- |
| 菜单名称 | 客户拜访记录 |
| 路由 | `/biz/customer-visit` |
| 组件 | `views/biz/customer-visit/index.vue` |
| 图标 | 可使用通用列表图标 |

## 10. API 设计

| 方法 | 路径 | 权限 | 说明 |
| --- | --- | --- | --- |
| GET | `/api/biz/customer-visits/page` | `biz:customerVisit:list` | 分页列表 |
| GET | `/api/biz/customer-visits/{id}` | `biz:customerVisit:query` | 详情 |
| POST | `/api/biz/customer-visits` | `biz:customerVisit:create` | 新增 |
| PUT | `/api/biz/customer-visits/{id}` | `biz:customerVisit:update` | 编辑 |
| DELETE | `/api/biz/customer-visits/{id}` | `biz:customerVisit:delete` | 删除 |

约束：

| 约束 | 说明 |
| --- | --- |
| 统一响应 | `Result<T>` |
| 分页响应 | `PageResult<T>` |
| 入参 | Create/Update DTO |
| 出参 | VO |
| 删除 | 逻辑删除 |

## 11. 页面设计

### 11.1 列表页

| 区域 | 内容 |
| --- | --- |
| 搜索 | 客户名称、拜访时间范围、状态 |
| 操作栏 | 新增、刷新 |
| 表格列 | 客户名称、联系人、拜访时间、拜访方式、下一步动作、负责人、状态、创建时间 |
| 行操作 | 编辑、删除 |

### 11.2 表单

| 字段 | 控件 |
| --- | --- |
| 客户名称 | 输入框 |
| 联系人 | 输入框 |
| 拜访时间 | 日期时间选择 |
| 拜访方式 | 下拉选择 |
| 拜访纪要 | 多行文本 |
| 下一步动作 | 输入框 |
| 状态 | 下拉选择 |

负责人字段 P0 默认使用当前登录用户，不在表单中编辑。

## 12. 数据权限说明

P0 演示数据权限策略：

| 角色 | 可见范围 |
| --- | --- |
| 销售人员 | 本人创建或负责的记录 |
| 销售主管 | 全部客户拜访记录 |
| 管理员 | 全部客户拜访记录 |

如果 S4 代码生成阶段数据权限能力尚未完成，AI 必须在生成摘要中标记：

> 数据权限已在需求和权限说明中定义，当前生成结果需等待数据权限基础能力接入后完全生效。

演示验收不得只使用管理员账号。至少需要准备两个业务用户，以证明菜单权限、接口权限和数据范围是三个不同层次。

| 验收账号 | 预期 |
| --- | --- |
| 销售人员 A | 能看到自己创建或负责的拜访记录 |
| 销售人员 B | 不能看到 A 的仅本人范围记录 |
| 销售主管 | 按当前实现能力查看本部门或全部演示数据；若未生效必须在演示摘要说明 |

若数据权限基础能力尚未接入，S7 演示输出必须把该项列为限制，不能宣称“销售人员和主管数据范围已通过”。

## 13. 生成产物清单

后端：

| 文件 | 说明 |
| --- | --- |
| `CustomerVisit.java` | Entity |
| `CustomerVisitCreateDTO.java` | 新增入参 |
| `CustomerVisitUpdateDTO.java` | 编辑入参 |
| `CustomerVisitQuery.java` | 查询条件 |
| `CustomerVisitVO.java` | 出参 |
| `CustomerVisitMapper.java` | Mapper |
| `CustomerVisitService.java` | Service |
| `CustomerVisitServiceImpl.java` | Service 实现 |
| `CustomerVisitController.java` | Controller |

前端：

| 文件 | 说明 |
| --- | --- |
| `src/api/biz/customerVisit.ts` | API |
| `src/views/biz/customer-visit/index.vue` | 列表页 |
| `src/views/biz/customer-visit/form.vue` | 表单 |

数据库：

| 文件 | 说明 |
| --- | --- |
| `V*_create_biz_customer_visit.sql` | 建表 |
| `V*_menu_biz_customer_visit.sql` | 菜单权限 |

文档：

| 文件 | 说明 |
| --- | --- |
| docs/generated/biz/customer-visit.md | S4 生成后产生的模块说明，编码前不要求存在 |

## 14. 验证标准

| 验证项 | 标准 |
| --- | --- |
| 后端编译 | `mvn -pl vibe-starter -am test` 通过 |
| 前端构建 | `npm run build` 通过 |
| SQL 迁移 | Flyway 可识别迁移文件 |
| 菜单权限 | 菜单和按钮权限生成 |
| 页面访问 | 管理端可进入客户拜访记录页面 |
| 新增记录 | 表单可提交 |
| 列表查询 | 新记录出现在列表 |
| 编辑记录 | 可修改状态和下一步动作 |
| 删除记录 | 逻辑删除后列表不展示 |

## 15. AI 输出摘要要求

AI 完成生成后必须输出：

| 内容 | 说明 |
| --- | --- |
| 需求摘要 | 用户要做什么 |
| 澄清结果 | 采用了哪些默认答案 |
| 生成文件 | 文件列表 |
| 权限说明 | 菜单和按钮权限 |
| 数据权限说明 | 当前支持程度 |
| 验证结果 | 执行了哪些命令 |
| 风险和限制 | 未实现的 P1/P2 能力 |

## 16. 不接受的演示结果

| 情况 | 原因 |
| --- | --- |
| 只生成前端页面 | 不是完整闭环 |
| 只生成后端 CRUD | 未验证前后端 |
| 没有权限标识 | 违反安全规则 |
| SQL 未版本化 | 违反迁移规则 |
| 生成后无法构建 | 未通过质量门禁 |
| 不说明数据权限限制 | 误导用户 |

## 17. 一句话总结

客户拜访记录模块是 Vibe Boot MVP 的第一把尺子：如果它不能从自然语言稳定生成真实代码、权限、页面、SQL、验证结果和交付说明，就说明 Vibe Boot 还没有真正超过传统低代码。
