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

说明：S4 固定新增独立 Maven 模块 `vibe-biz`，并将其作为 P0 生成业务代码的唯一目标模块；客户拜访记录必须生成到 `com.vibeboot.biz.customervisit`。不得把演示业务代码放入 `vibe-system`，S1 也不得提前创建 `vibe-biz`。

机器可读样例固定为 `docs/contracts/examples/customer-visit-meta-model-v1.json`，必须同时通过 `docs/contracts/codegen-meta-model-v1.schema.json` 和代码生成设计第 5.5 节语义校验。表格与样例冲突时不得自行选择，必须先修订两者。

## 7. 业务字段定义

| 字段名 | 数据库字段 | 类型 | 必填 | 列表 | 表单 | 搜索 | 说明 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| customerName | customer_name | String(100) | 是 | 是 | 是 | 是 | 客户名称 |
| contactName | contact_name | String(50) | 否 | 是 | 是 | 否 | 联系人 |
| visitTime | visit_time | DateTime | 是 | 是 | 是 | 是 | 拜访时间 |
| visitType | visit_type | Enum | 是 | 是 | 是 | 否 | 拜访方式 |
| summary | summary | Text | 是 | 否 | 是 | 否 | 拜访纪要 |
| nextAction | next_action | String(255) | 否 | 是 | 是 | 否 | 下一步动作 |
| ownerUserId | owner_user_id | Long | 是 | 是 | 否 | 否 | 负责人 |
| status | status | Enum | 是 | 是 | 是 | 是 | 状态 |

`id/createdAt/updatedAt/createdBy/updatedBy/deleted/version` 不进入元模型 fields，由生成器按 `docs/code-generation-design.md` 第 5.6 节固定注入。VO 返回除 deleted 外的系统字段，UpdateDTO 只额外接收 version。

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

DELETE 固定使用 `?version={int>=0}`，所有详情、更新和删除都必须先应用当前用户数据范围，不能先查全库再在 Controller 判断 owner。

| 对象 | 精确字段与校验 |
| --- | --- |
| `CustomerVisitPageQuery` | `customerName? 1..100` 模糊匹配并转义 `%/_`；`visitTimeFrom?/visitTimeTo?:ISO-8601 datetime` 且 from≤to、跨度≤366天；`status?:draft|completed|cancelled`；`pageNo 1..100000`；`pageSize 1..100`；`sortField=visitTime|createdAt` 默认 visitTime；`sortOrder=asc|desc` 默认 desc |
| `CustomerVisitCreateDTO` | `customerName 1..100`；`contactName? <=50`；`visitTime`；`visitType=phone|onsite|online`；`summary 1..10000`；`nextAction? <=255`；`status=draft|completed|cancelled`；不接收 ownerUserId/id/audit/deleted/version |
| `CustomerVisitUpdateDTO` | 与 CreateDTO 相同业务字段 + `version:int>=0`；不接收 ownerUserId/id/audit/deleted |
| `CustomerVisitVO` | `id/customerName/contactName/visitTime/visitType/summary/nextAction/ownerUserId/ownerNickname/status/createdAt/updatedAt/createdBy/updatedBy/version`；Long 均为 string，不返回 deleted |

字符串字段先 trim；trim 后空字符串按必填失败或可选 null 处理。visitTime 以 `Asia/Shanghai` 解释无 offset 的管理端输入，服务端按 UTC 写入 `datetime(3)`，响应统一输出带 `Z` 的 UTC ISO-8601。创建时 ownerUserId 固定为当前用户，管理员也不能代填；P0 不提供转交负责人接口。更新和删除使用 `id + version + deleted=0 + 数据范围条件` 原子执行，未命中时：记录不存在/越权统一返回 `DATA_0404`，已授权但 version 冲突返回 `DATA_0409`，不得泄露他人记录是否存在。

约束：

| 约束 | 说明 |
| --- | --- |
| 统一响应 | `Result<T>` |
| 分页响应 | `PageResult<T>` |
| 入参 | Create/Update DTO |
| 出参 | VO |
| 删除 | 逻辑删除 |

分页返回 `PageResult<CustomerVisitVO>`，详情/创建/更新返回 `CustomerVisitVO`，删除返回 null。所有请求拒绝未知字段，Controller 不接收 Entity、Map 或任意 JSON。

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

演示验收不得只使用管理员账号。至少需要准备两个业务用户，以证明菜单权限、接口权限和数据范围是三个不同层次。

| 验收账号 | 预期 |
| --- | --- |
| 销售人员 A | 能看到自己创建或负责的拜访记录 |
| 销售人员 B | 不能看到 A 的仅本人范围记录 |
| 销售主管 | 能查看全部客户拜访演示数据 |

S2 的数据权限基础是 S4 前置条件。客户拜访记录生成结果必须接入当前用户和数据范围查询扩展点：销售人员只看本人创建或负责的记录，销售主管和管理员看全部记录。该门禁未通过时 S4 不能关闭，S7 也不能以“已说明限制”替代失败。

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
| `CustomerVisitControllerTest.java` | CRUD、权限、参数和并发冲突 MockMvc 正反用例 |
| `CustomerVisitDataScopeTest.java` | 销售 A/B、主管、管理员数据隔离集成用例 |

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
| 后端编译 | `scripts/mvn.ps1 -pl vibe-starter -am test` 通过 |
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
| 数据权限证据 | 销售 A、销售 B、销售主管三类账号的查询结果与隔离验证 |
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
| 数据权限未接入或只写限制说明 | P0 核心验收失败，不能用说明替代实现 |

## 17. 一句话总结

客户拜访记录模块是 Vibe Boot MVP 的第一把尺子：如果它不能从自然语言稳定生成真实代码、权限、页面、SQL、验证结果和交付说明，就说明 Vibe Boot 还没有真正超过传统低代码。
