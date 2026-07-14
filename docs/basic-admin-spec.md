# Vibe Boot 基础后台规格

## 1. 文档目的

本文定义 Vibe Boot S2 阶段基础后台的产品范围、页面、接口、权限、数据表、默认数据和验收标准。

基础后台不是 Vibe Boot 的差异化终点，但它是 AI 工作台、代码生成、生产安装包和企业业务系统的地基。首版必须克制、稳定、完整，避免做成“大而全 Admin 换皮”。

## 2. S2 目标

| 目标 | 说明 |
| --- | --- |
| 管理员可登录 | 支持用户名密码登录、Cookie 会话、登出、空闲续期和失效 |
| 权限可闭环 | 用户、角色、菜单、按钮、接口权限一致 |
| 菜单可驱动前端 | 管理端菜单来自后端，前端按权限渲染 |
| 基础数据可维护 | 部门、字典、系统参数可管理 |
| 行为可审计 | 登录日志、操作日志可查询 |
| 文件基础可管理 | 管理员可在受控本地存储中上传、下载、预览图片和删除文件 |
| 支撑后续生成 | 代码生成能复用菜单、权限、字典和审计能力 |

S2 完成后，应能支持管理员进入系统，创建用户和角色，配置菜单权限，使用受控本地文件服务，并为后续 AI 工作台和业务模块生成提供基础能力。

## 3. 不做事项

| 不做 | 原因 |
| --- | --- |
| 多租户 SaaS | 首版面向单企业内部系统，降低复杂度 |
| 复杂组织权限 | 先支持部门树和常见数据范围 |
| 工作流权限 | P2 再结合真实流程需求设计 |
| 岗位完整管理 | `sys_post` P1，可先预留表设计 |
| 在线表单设计器 | 容易偏向传统低代码运行时 |
| OAuth/LDAP/企业微信登录 | P1/P2，首版只做用户名密码 |
| 细粒度字段权限 | 首版先完成菜单、按钮、接口、数据范围 |
| 国际化 | 首版面向中国用户，中文优先 |
| 业务附件、Office 在线预览、对象存储 | P0 文件基础服务不包含这些能力 |

## 4. 功能范围

| 功能 | P0 | 说明 |
| --- | --- | --- |
| 登录/登出 | 是 | 用户名密码、Token、失败日志 |
| 当前用户信息 | 是 | 用户信息、角色、权限、菜单 |
| 用户管理 | 是 | 列表、创建、编辑、禁用、重置密码、分配角色 |
| 角色管理 | 是 | 列表、创建、编辑、禁用、分配菜单权限 |
| 菜单管理 | 是 | 目录、菜单、按钮、权限标识 |
| 部门管理 | 是 | 树形部门、用户归属 |
| 字典管理 | 是 | 字典类型、字典项 |
| 参数配置 | 是 | 系统参数，不保存密钥 |
| 登录日志 | 是 | 查询登录成功/失败 |
| 操作日志 | 是 | 查询关键操作记录 |
| 文件管理 | 是 | 本地单文件白名单上传、鉴权访问、图片预览和两阶段删除 |
| 首页仪表盘 | 可选 | P0 可只做简单欢迎页和系统状态 |

## 5. 用户流程

### 5.1 首次启动

| 步骤 | 行为 |
| --- | --- |
| 1 | Flyway 初始化系统表、角色、基础菜单和字典，不写入任何管理员密码 |
| 2 | 生产 install 通过同一 Jar `bootstrap-admin` 从 stdin 接收初始密码并创建 `admin`；开发 profile 使用显式开发初始化器 |
| 3 | bootstrap 在同一事务中关联管理员角色，并设置强制改密与初始化标记 |
| 4 | 开发模式可使用明确标识的演示密码；生产模式不得使用公开固定初始密码 |
| 5 | 首次登录只能进入改密流程，成功后清除初始化标记并撤销其他会话 |

生产安装包的初始管理员策略由 `docs/release-package-design.md` 约束：默认由安装人员交互输入并二次确认；只有显式 `-GenerateInitialAdminPassword` 才生成一次性密码。两种方式都只经 bootstrap 子进程 stdin 传递，不把公开固定密码打入生产包。

初始管理员约束：

| 场景 | 账号 | 密码策略 | 登录要求 |
| --- | --- | --- | --- |
| 开发模式 | 可使用 `admin` | 允许使用本地 example 中的演示密码或首次启动生成提示，必须标注仅限开发 | 登录后可提示改密 |
| 生产安装 | 默认创建 `admin` | 默认由安装人员交互输入并二次确认；只有显式使用 `-GenerateInitialAdminPassword` 时才生成 24 位随机密码并在成功后只显示一次；两种方式都只经 bootstrap 子进程 stdin 传递 | 首次登录必须强制改密 |
| 生产升级 | 保留已有管理员 | 不覆盖已有密码，不重置为公开默认值 | 如检测到初始化密码标记，继续强制改密 |

实现约束：`sys_user.password_reset_required=true` 时，除修改本人密码、登出和读取当前用户基础信息外，不得访问其他管理接口。初始密码、重置密码和随机生成密码只能向当前有权限的操作者显示一次，不得进入命令行参数、环境变量、文件、登录日志、操作日志、AI 上下文或备份摘要；P0 不接受“外置初始密码文件”作为第三条输入通道。

### 5.2 普通管理

| 步骤 | 行为 |
| --- | --- |
| 1 | 管理员创建部门 |
| 2 | 管理员创建角色并勾选菜单/按钮权限 |
| 3 | 管理员创建用户并分配部门和角色 |
| 4 | 用户登录后只看到有权限的菜单和按钮 |
| 5 | 用户访问无权限接口时后端返回 `AUTH_0403` |
| 6 | 新增、修改、删除、导出等关键操作进入操作日志 |

## 6. 页面规格

| 页面 | 路由 | P0 控件 |
| --- | --- | --- |
| 登录页 | `/login` | 用户名、密码、登录按钮 |
| 首页 | `/dashboard` | 系统状态、快捷入口，可先简化 |
| 用户管理 | `/system/user` | 查询表单、表格、新增、编辑、禁用、重置密码、分配角色 |
| 角色管理 | `/system/role` | 查询表单、表格、新增、编辑、禁用、分配菜单 |
| 菜单管理 | `/system/menu` | 树表、新增目录、新增菜单、新增按钮、编辑、删除 |
| 部门管理 | `/system/dept` | 部门树、列表/表单、新增、编辑、禁用 |
| 字典类型 | `/system/dict-type` | 查询、表格、新增、编辑、禁用 |
| 字典项 | `/system/dict-item` | 按类型查看、新增、编辑、排序、禁用 |
| 参数配置 | `/system/config` | 查询、表格、新增、编辑、禁用 |
| 登录日志 | `/system/login-log` | 查询、表格 |
| 操作日志 | `/system/oper-log` | 查询、表格、详情 |

前端页面必须使用 Element Plus，表格、表单、树、弹窗、确认框保持统一交互。

## 7. API 范围

所有管理端 API 以 `/api` 开头，响应遵守 `docs/api-conventions.md`。

### 7.1 认证 API

| Method | Path | 说明 | 权限 |
| --- | --- | --- | --- |
| POST | `/api/auth/login` | 登录 | 公开 |
| POST | `/api/auth/logout` | 登出 | 登录 |
| POST | `/api/auth/change-password` | 修改本人密码；初始/重置密码必须走此接口 | 登录 |
| GET | `/api/auth/csrf` | 获取当前会话绑定的 CSRF Token | 登录 |
| GET | `/api/auth/me` | 当前用户信息 | 登录 |
| GET | `/api/auth/menus` | 当前用户菜单树 | 登录 |
| GET | `/api/auth/permissions` | 当前用户权限标识 | 登录 |

认证 DTO/VO 固定如下，Controller 不得直接接收 Entity、Map 或任意 JSON：

| 接口 | 请求字段 | `data` 字段 |
| --- | --- | --- |
| login | `username:string(4..64)`、`password:string(1..128 code points)` | `CurrentUserVO`；同时设置 Cookie，不返回 token |
| logout | 无；写请求必须带 CSRF | `null` |
| change-password | `currentPassword`、`newPassword`、`confirmPassword`，均最多 128 code points | `null`；成功撤销全部会话并清 Cookie，用户重新登录 |
| csrf | 无 | `token:string`、`expiresAt:string(ISO-8601 UTC)` |
| me | 无 | `id/username/nickname/deptId/deptName/roleCodes/dataScopes/passwordResetRequired` |
| menus | 无 | `MenuTreeVO[]`：`id/parentId/menuType/menuName/routePath/component/icon/visible/sortOrder/children`；不返回无权限按钮 |
| permissions | 无 | 去重排序后的 `string[]` 权限标识 |

`CurrentUserVO` 与 me 字段相同。所有 Long ID 在 JSON 中为 string；认证和一次性凭据响应固定 `Cache-Control: no-store, no-cache, must-revalidate`、`Pragma: no-cache`，不得被前端状态持久化。

认证接口固定语义：

| 场景 | P0 处理 |
| --- | --- |
| 登录成功 | 通过 HttpOnly `VIBEBOOT_SESSION` Cookie 建立 Redis 会话；响应体不返回 Token |
| 登录失败 | 用户不存在、密码错误、已删除账号统一返回 `AUTH_0401`，避免账号枚举 |
| 登录限流 | 账号连续失败 5 次暂停 15 分钟；同一 IP 5 分钟 20 次后暂停 10 分钟，返回 `AUTH_0429` 和 `Retry-After` |
| 首次改密 | 其他管理接口返回 `AUTH_0409`；只允许 `/me`、`/csrf`、`/change-password` 和 `/logout` |
| CSRF | 登录后的 POST/PUT/PATCH/DELETE 必须携带会话绑定的 `X-CSRF-Token` |
| 登出 | 当前会话失效并清除 Cookie；重复登出不得恢复或延长会话 |
| 改密/重置/禁用 | 修改本人密码、管理员重置密码、禁用或删除用户后，该账号全部会话失效 |

生产前端由后端承载并保持同源；开发通过 Vite `/api` 代理。前端不得把会话 Token 写入 localStorage、sessionStorage、URL、日志或状态持久化插件。

### 7.2 系统管理 API

| 资源 | Path | P0 动作 |
| --- | --- | --- |
| 用户 | `/api/system/users` | page、detail、create、update、delete、status、reset-password、assign-roles |
| 角色 | `/api/system/roles` | page、detail、create、update、delete、status、assign-menus |
| 菜单 | `/api/system/menus` | tree、detail、create、update、delete |
| 部门 | `/api/system/depts` | tree、detail、create、update、delete、status |
| 字典类型 | `/api/system/dict-types` | page、detail、create、update、delete、status |
| 字典项 | `/api/system/dict-items` | list、detail、create、update、delete、status |
| 参数配置 | `/api/system/configs` | page、detail、create、update、delete、status |
| 登录日志 | `/api/system/login-logs` | page、detail |
| 操作日志 | `/api/system/oper-logs` | page、detail |
| 健康检查 | `/api/system/health` | info；对应权限 `system:health:info`，只返回脱敏明细 |

上表只是导航，规范 Method/Path/权限以以下清单为准；不存在 `/page`、`/tree` 或动作名的替代写法。

| 资源 | Method + Path | 权限 | 请求/查询 |
| --- | --- | --- | --- |
| 用户分页 | `GET /api/system/users/page` | `system:user:list` | `username/nickname/deptId/status/pageNo/pageSize/sortField/sortOrder` |
| 用户详情 | `GET /api/system/users/{id}` | `system:user:query` | path id |
| 创建用户 | `POST /api/system/users` | `system:user:create` | `UserCreateDTO` |
| 更新用户 | `PUT /api/system/users/{id}` | `system:user:update` | `UserUpdateDTO` |
| 删除用户 | `DELETE /api/system/users/{id}` | `system:user:delete` | query `version:int>=0` |
| 用户状态 | `PUT /api/system/users/{id}/status` | `system:user:status` | `StatusChangeDTO` |
| 重置密码 | `POST /api/system/users/{id}/reset-password` | `system:user:resetPassword` | `VersionDTO` |
| 分配角色 | `PUT /api/system/users/{id}/roles` | `system:user:assignRoles` | `IdSetVersionDTO(roleIds)` |
| 角色分页/详情 | `GET /api/system/roles/page`；`GET /api/system/roles/{id}` | `system:role:list`；`system:role:query` | `roleCode/roleName/status` + 分页；path id |
| 创建/更新/删除角色 | `POST /api/system/roles`；`PUT /api/system/roles/{id}`；`DELETE /api/system/roles/{id}` | 依次 `system:role:create`；`system:role:update`；`system:role:delete` | `RoleCreateDTO`；`RoleUpdateDTO`；删除 query `version:int>=0` |
| 角色状态 | `PUT /api/system/roles/{id}/status` | `system:role:status` | `StatusChangeDTO` |
| 分配菜单 | `PUT /api/system/roles/{id}/menus` | `system:role:assignMenus` | `IdSetVersionDTO(menuIds)` |
| 菜单树/详情 | `GET /api/system/menus/tree`；`GET /api/system/menus/{id}` | `system:menu:list`；`system:menu:query` | `menuName/status`；path id |
| 创建/更新/删除菜单 | `POST /api/system/menus`；`PUT /api/system/menus/{id}`；`DELETE /api/system/menus/{id}` | 依次 `system:menu:create`；`system:menu:update`；`system:menu:delete` | `MenuCreateDTO`；`MenuUpdateDTO`；删除 query `version:int>=0` |
| 部门树/详情 | `GET /api/system/depts/tree`；`GET /api/system/depts/{id}` | `system:dept:list`；`system:dept:query` | `deptName/status`；path id |
| 创建/更新/删除部门 | `POST /api/system/depts`；`PUT /api/system/depts/{id}`；`DELETE /api/system/depts/{id}` | 依次 `system:dept:create`；`system:dept:update`；`system:dept:delete` | `DeptCreateDTO`；`DeptUpdateDTO`；删除 query `version:int>=0` |
| 部门状态 | `PUT /api/system/depts/{id}/status` | `system:dept:status` | `StatusChangeDTO` |
| 字典类型分页/详情 | `GET /api/system/dict-types/page`；`GET /api/system/dict-types/{id}` | `system:dict:list`；`system:dict:query` | `dictCode/dictName/status` + 分页；path id |
| 创建/更新/删除字典类型 | `POST /api/system/dict-types`；`PUT /api/system/dict-types/{id}`；`DELETE /api/system/dict-types/{id}` | 依次 `system:dict:create`；`system:dict:update`；`system:dict:delete` | `DictTypeCreateDTO`；`DictTypeUpdateDTO`；删除 query `version:int>=0` |
| 字典类型状态 | `PUT /api/system/dict-types/{id}/status` | `system:dict:update` | `StatusChangeDTO` |
| 字典项列表/详情 | `GET /api/system/dict-items/list`；`GET /api/system/dict-items/{id}` | `system:dict:list`；`system:dict:query` | `dictCode` 必填、`status` 可选；path id |
| 创建/更新/删除字典项 | `POST /api/system/dict-items`；`PUT /api/system/dict-items/{id}`；`DELETE /api/system/dict-items/{id}` | 依次 `system:dict:create`；`system:dict:update`；`system:dict:delete` | `DictItemCreateDTO`；`DictItemUpdateDTO`；删除 query `version:int>=0` |
| 字典项状态 | `PUT /api/system/dict-items/{id}/status` | `system:dict:update` | `StatusChangeDTO` |
| 参数分页/详情 | `GET /api/system/configs/page`；`GET /api/system/configs/{id}` | `system:config:list`；`system:config:query` | `configKey/configName/status` + 分页；path id |
| 创建/更新/删除参数 | `POST /api/system/configs`；`PUT /api/system/configs/{id}`；`DELETE /api/system/configs/{id}` | 依次 `system:config:create`；`system:config:update`；`system:config:delete` | `ConfigCreateDTO`；`ConfigUpdateDTO`；删除 query `version:int>=0` |
| 参数状态 | `PUT /api/system/configs/{id}/status` | `system:config:update` | `StatusChangeDTO` |
| 登录日志 | `GET /api/system/login-logs/page`；`GET /api/system/login-logs/{id}` | 依次 `system:loginLog:list`；`system:loginLog:query` | `username/loginStatus/loginIp/beginAt/endAt` + 分页；path id |
| 操作日志 | `GET /api/system/oper-logs/page`；`GET /api/system/oper-logs/{id}` | 依次 `system:operLog:list`；`system:operLog:query` | `username/module/status/targetType/targetId/traceId/beginAt/endAt` + 分页；path id |
| 系统健康 | `GET /api/system/health` | `system:health:info` | 无；返回 ADR-0002 冻结的脱敏三态结构 |

分页公共参数使用 `pageNo/pageSize/sortField/sortOrder`，边界遵守 API 规范。排序白名单固定如下；省略时都按表中默认顺序，树/列表接口不接受 sortField：

| 资源 | sortField 白名单 | 默认 |
| --- | --- | --- |
| 用户 | `username/createdAt/lastLoginAt` | createdAt desc |
| 角色 | `sortOrder/roleCode/createdAt` | sortOrder asc、id asc |
| 字典类型 | `dictCode/createdAt` | dictCode asc |
| 参数 | `configKey/createdAt` | configKey asc |
| 登录日志 | `loginAt` | loginAt desc、id desc |
| 操作日志 | `operAt` | operAt desc、id desc |

所有 path id 和 query version 都必须存在且为正十进制 Long/string、`version>=0`；未知 query 参数返回 `VALID_0400`。所有逻辑删除使用 `id + version + deleted=0`，未命中按存在性与授权规则返回 `DATA_0404` 或 `DATA_0409`，不能静默成功。

查询字段校验固定为：username/roleCode/dictCode/configKey 使用各自创建 DTO 的格式；其余名称/keyword 最长 100；status 只允许 enabled/disabled；loginStatus/status 使用对应冻结枚举；ID 使用正十进制 string；beginAt/endAt 必须成对、from≤to 且跨度≤90 天；loginIp 必须是合法 IPv4/IPv6 字面量；traceId 必须是 32 位小写 hex。字符串查询先 trim，空值按未提供处理，未知字段不兼容接收。

DTO 字段精确集合如下；字符串先 trim 的字段按表格执行，密码不 trim。所有 create DTO 都拒绝客户端 id/audit/deleted/version，所有 update DTO 的 version 必填且大于等于 0。

| DTO | 字段与校验 |
| --- | --- |
| `UserCreateDTO` | `username` 规范化规则见 10.1；`nickname 1..64`；`mobile? <=32`；`email? <=128 + Email`；`deptId:string`；不接收 roleIds，角色必须走独立 `assignRoles` 权限接口 |
| `UserUpdateDTO` | `nickname/mobile/email/deptId/version`；不允许改 username/password/status/roles |
| `StatusChangeDTO` | `status:enabled|disabled`、`version:int>=0` |
| `VersionDTO` | `version:int>=0` |
| `IdSetVersionDTO` | `roleIds` 或 `menuIds` 只能出现约定字段，ID 去重、最多 500；`version:int>=0` |
| `RoleCreateDTO` | `roleCode:[a-z][a-z0-9_-]{2,63}`、`roleName 1..100`、`dataScope:all|dept|dept_tree|self`、`status`、`sortOrder 0..9999`、`remark? <=500` |
| `RoleUpdateDTO` | `roleName/dataScope/sortOrder/remark/version`；roleCode/builtIn/status 不在此接口修改 |
| `MenuCreateDTO` | `parentId`、`menuType:directory|menu|button`、`menuName 1..100`、`routePath?/component?/permission?/icon?`、`visible/status/sortOrder`；字段组合规则见 10.3 |
| `MenuUpdateDTO` | MenuCreateDTO 可编辑字段 + `version`；不接收 id |
| `DeptCreateDTO` | `parentId`、`deptName 1..100`、`deptCode:[A-Z][A-Z0-9_-]{1,63}`、`status/sortOrder/remark?` |
| `DeptUpdateDTO` | `parentId/deptName/status/sortOrder/remark/version`；deptCode 不可修改，且 parentId 不能形成环 |
| `DictTypeCreateDTO` | `dictCode:[a-z][a-z0-9_.-]{2,63}`、`dictName 1..100`、`status/remark?` |
| `DictTypeUpdateDTO` | `dictName/remark/version`；dictCode/status 不在此接口修改 |
| `DictItemCreateDTO` | `dictCode`、`itemLabel 1..100`、`itemValue 1..100`、`status/sortOrder/remark?` |
| `DictItemUpdateDTO` | `itemLabel/status/sortOrder/remark/version`；dictCode/itemValue 不可修改 |
| `ConfigCreateDTO` | `configKey:[a-z][a-z0-9_.-]{2,127}`、`configValue <=2000`、`configName 1..100`、`configType:system|business`、`status/remark?`；secret 模式命中即拒绝 |
| `ConfigUpdateDTO` | `configValue/configName/configType/remark/version`；configKey/status 不在此接口修改 |

创建用户和重置密码使用安全治理冻结的 24 位临时密码。创建成功 `data={user:UserVO,oneTimePassword:string}`，重置成功 `data={userId:string,oneTimePassword:string,passwordResetRequired:true}`；这两个响应只发送一次并带 no-store，前端只能在不可再次打开的结果弹窗显示。网络失败或操作者关闭弹窗后不得查询旧明文，只能再次确认重置并生成新密码。

公共 VO 精确字段如下，未列字段不得返回：

| VO | 字段 |
| --- | --- |
| `UserVO` | `id/username/nickname/mobile/email/deptId/deptName/status/roleIds/roleNames/passwordResetRequired/lastLoginAt/version/createdAt` |
| `RoleVO` | `id/roleCode/roleName/dataScope/status/sortOrder/builtIn/menuIds/version/createdAt` |
| `MenuVO` | `id/parentId/menuType/menuName/routePath/component/permission/icon/visible/status/sortOrder/version/children` |
| `DeptVO` | `id/parentId/deptName/deptCode/status/sortOrder/remark/version/children` |
| `DictTypeVO` | `id/dictCode/dictName/status/remark/version/createdAt` |
| `DictItemVO` | `id/dictCode/itemLabel/itemValue/status/sortOrder/remark/version/createdAt` |
| `ConfigVO` | `id/configKey/configValue/configName/configType/status/remark/version/createdAt` |
| `LoginLogVO` | `id/username/userId/loginIp/loginStatus/failReason/userAgent/traceId/loginAt` |
| `OperLogVO` | `id/userId/username/module/operation/method/path/requestMethod/status/errorCode/errorMessage/durationMs/targetType/targetId/traceId/operAt` |

日志 VO 不返回 password、Cookie、CSRF、request body、服务器绝对路径或堆栈；errorMessage 是最长 500 字的脱敏中文摘要。所有 ID 字段在 JSON 中为十进制 string，durationMs 和分页计数为非负 number，树 children 始终返回数组而不是 null。

### 7.3 文件管理 API

| Method | Path | 说明 | 权限 |
| --- | --- | --- | --- |
| POST | `/api/files` | 单文件上传 | `file:object:upload` |
| GET | `/api/files/page` | 脱敏元数据分页 | `file:object:list` |
| GET | `/api/files/{id}/download` | 鉴权下载 | `file:object:download` |
| GET | `/api/files/{id}/preview` | 仅图片预览 | `file:object:preview` |
| DELETE | `/api/files/{id}` | 两阶段删除 | `file:object:delete` |
| POST | `/api/files/{id}/retry-delete` | 重试失败的物理删除 | `file:object:delete` |

文件管理属于 S2 基础服务，但不表示客户拜访记录等业务已经支持附件。所有大小、类型、配额、路径、响应头和状态机约束以 ADR-0002 为准。

### 7.4 删除策略

| 场景 | 策略 |
| --- | --- |
| 用户删除 | 逻辑删除，不删除日志 |
| 角色删除 | 若有用户绑定，禁止删除或先解除绑定 |
| 菜单删除 | 若有子菜单，禁止删除 |
| 部门删除 | 若有子部门或用户，禁止删除 |
| 字典类型删除 | 若有字典项，禁止删除或要求先清理 |
| 日志删除 | P0 不提供删除，P1 再考虑清理策略 |

不可绕过的系统保护：内置管理员角色、根部门和系统保留菜单只能由 Flyway 维护，P0 API 不允许删除或改编码；任何用户不得禁用/删除自己；不得禁用、删除或移除最后一个有效超级管理员；只有当前超级管理员可给他人分配内置管理员角色。违反时统一返回 `DATA_0409` 并写脱敏操作日志，前端隐藏按钮不能替代后端校验。

并发与重复提交约束：

| 场景 | P0 规则 |
| --- | --- |
| 编辑用户、角色、菜单、部门、字典、参数 | 表单加载并提交 `version`；其他管理员已修改时返回 `DATA_0409`，前端提示刷新后重试 |
| 用户名、角色编码、菜单权限、字典编码 | 数据库唯一索引作为最终约束，重复创建返回 `DATA_0409` |
| 分配角色、分配菜单 | 在单个事务内保存目标集合，重复提交结果一致，关系表唯一索引不得产生重复行 |
| 禁用/启用 | 使用当前 version 和预期状态条件更新；并发变化不得静默覆盖 |
| 重置密码 | 每次确认后都是一次新的安全动作，不自动重放；成功响应可按 7.2 节仅返回一次新临时密码并强制 `Cache-Control: no-store`，服务端日志/审计/持久化不得记录明文 |
| 删除 | 已逻辑删除的相同 ID 再次删除按成功处理，不重复写业务副作用；存在依赖时保持阻断 |

## 8. 权限模型

权限标识遵守 `docs/api-conventions.md` 和 ADR-0002 的 `{domain}:{resource}:{action}`。

| 对象 | 示例 |
| --- | --- |
| 用户列表 | `system:user:list` |
| 用户新增 | `system:user:create` |
| 用户编辑 | `system:user:update` |
| 用户删除 | `system:user:delete` |
| 用户重置密码 | `system:user:resetPassword` |
| 角色分配菜单 | `system:role:assignMenus` |
| 菜单管理 | `system:menu:list`、`system:menu:create` |
| 字典管理 | `system:dict:list`、`system:dict:create` |
| 参数配置 | `system:config:list`、`system:config:update` |
| 日志查询 | `system:loginLog:list`、`system:operLog:list` |

约束：

| 约束 | 说明 |
| --- | --- |
| 后端强校验 | Controller 必须有权限校验或显式公开说明 |
| 前端只做体验优化 | 隐藏按钮不是安全边界 |
| 超级管理员可绕过菜单勾选 | 仅限内置管理员角色或管理员标记 |
| 代码生成复用同一规则 | 业务模块生成的权限必须能写入菜单表 |

## 9. 数据权限

S2 必须提供数据权限基础表达，但 P0 不要求所有业务模块都完成复杂拦截。

| 数据范围 | P0 状态 | 说明 |
| --- | --- | --- |
| 全部数据 | 必做 | 管理员角色 |
| 本部门数据 | 必做 | 基于当前用户 `deptId` |
| 本部门及下级 | 必做 | 基于部门树 |
| 仅本人数据 | 必做 | 基于 `created_by` 或业务负责人 |
| 自定义部门 | P1 | 需要额外关系表和管理 UI |

S2 验收时至少要完成数据范围枚举、当前用户上下文、部门树查询能力和可被业务查询接入的扩展点。

数据权限状态必须可被接口和页面解释，不能只存在于角色表字段里。

| 能力 | P0 验收要求 |
| --- | --- |
| 数据范围枚举 | 角色管理能选择全部、本部门、本部门及下级、仅本人 |
| 当前用户上下文 | `/api/auth/me` 返回 deptId、角色和数据范围摘要 |
| 查询扩展点 | 后端提供统一数据范围对象或注解，业务查询可接入 |
| 生效状态说明 | 若某业务模块尚未接入数据权限，页面或生成摘要必须说明限制 |
| 演示验证 | 至少用两个不同部门/角色账号证明菜单权限与数据范围不是同一件事 |

## 10. 数据表字段要求

详细表域见 `docs/database-baseline.md`。S2 实现时必须至少覆盖以下核心字段。

### 10.1 `sys_user`

| 字段 | 说明 |
| --- | --- |
| id | 雪花 ID |
| username | 登录名，trim 后转小写；4-64 位，匹配 `[a-z][a-z0-9._-]{3,63}`，唯一 |
| password_hash | `varchar(255)`，保存带算法、迭代次数和 salt 的 PBKDF2 格式，不保存明文 |
| nickname | 昵称 |
| mobile | 手机号，可选 |
| email | 邮箱，可选 |
| dept_id | 部门 ID |
| status | enabled/disabled |
| last_login_at | 最后登录时间 |
| password_reset_required | 是否要求改密 |
| initial_password_flag | 是否仍处于初始化密码状态，仅用于强制改密和安全提示 |

密码字段只保存 `security-governance.md` 规定的 `$pbkdf2-sha256$...` 格式。登录名规范化发生在唯一性检查、限流 key 和查询之前；昵称仍可使用中文。密码按 NFC 规范化但不得 trim，避免用户输入与实际哈希内容不一致。

### 10.2 `sys_role`

| 字段 | 说明 |
| --- | --- |
| id | 雪花 ID |
| role_code | 角色编码，唯一 |
| role_name | 角色名称 |
| data_scope | 数据范围 |
| status | enabled/disabled |
| sort_order | 排序 |

### 10.3 `sys_menu`

| 字段 | 说明 |
| --- | --- |
| id | 雪花 ID |
| parent_id | 父级 ID |
| menu_type | directory/menu/button |
| menu_name | 名称 |
| route_path | 前端路由 |
| component | 前端组件路径 |
| permission | 权限标识 |
| icon | 图标 |
| visible | 是否显示 |
| status | enabled/disabled |
| sort_order | 排序 |

菜单字段组合必须同时由 DTO 校验和 Service 校验：

| menu_type | route_path | component | permission |
| --- | --- | --- | --- |
| directory | 必填，以 `/` 开头的 kebab-case 路径，无 query/fragment | null | null |
| menu | 必填且全局唯一 | 必填，以 `views/` 开头、不得含 `..` 或绝对路径 | 必填，符合 `{domain}:{resource}:{action}` |
| button | null | null | 必填且全局唯一 |

父级必须存在且为 directory；任何更新都不得形成环。icon 只能是前端已注册的 Lucide/Element 图标 key，不接受 SVG/HTML 字符串。

### 10.4 `sys_dept`

| 字段 | 说明 |
| --- | --- |
| id | 雪花 ID |
| parent_id | 父级 ID |
| dept_name | 部门名称 |
| dept_code | 部门编码，创建后不可修改且全局唯一 |
| status | enabled/disabled |
| sort_order | 排序 |

### 10.5 字典、配置、日志

| 表 | 关键字段 |
| --- | --- |
| `sys_dict_type` | dict_code、dict_name、status |
| `sys_dict_item` | dict_code、item_label、item_value、status、sort_order |
| `sys_config` | config_key、config_value、config_name、config_type、status |
| `sys_login_log` | username、user_id、login_ip、login_status、fail_reason、login_at |
| `sys_oper_log` | user_id、username、module、operation、method、path、request_method、status、error_message、oper_at |

`sys_config` 不用于保存模型 API Key、数据库密码、Redis 密码、TLS 私钥密码等敏感密钥。P0 使用 Redis 不透明会话，不存在需要保存的 JWT Token Secret。

## 11. 初始数据

| 数据 | P0 要求 |
| --- | --- |
| 超级管理员 | 开发模式由显式 dev initializer 创建；生产由 migrate 后的 `bootstrap-admin` 创建，密码只经 stdin |
| 管理员角色 | `admin`，全部权限 |
| 默认部门 | 总部 |
| 基础菜单 | 首页、系统管理、AI 工作台、代码生成、文件管理 |
| 系统管理子菜单 | 用户、角色、菜单、部门、字典、参数、登录日志、操作日志 |
| 基础字典 | 是否、状态、菜单类型、数据范围、登录状态、操作状态 |

不含 secret 的角色、菜单、部门、字典由 Flyway 写入；带密码的超级管理员只能由冻结的 bootstrap 维护模式写入。两者都不能被手工 SQL 或 PowerShell 直写替代。

## 12. 审计要求

| 操作 | 日志要求 |
| --- | --- |
| 登录成功 | 记录登录日志 |
| 登录失败 | 记录登录日志和失败原因 |
| 登出 | 可记录登录日志或操作日志 |
| 新增/修改/删除 | 记录操作日志 |
| 权限变更 | 记录操作日志，标记为高价值审计事件 |
| 密码重置 | 记录操作日志，不记录明文密码 |
| 参数配置修改 | 记录操作日志 |
| 日志查询 | P0 可不记录查询日志 |

日志不得记录明文密码、Token、API Key、数据库密码。

操作日志详情页必须能帮助实施人员定位问题，而不是只显示一行成功/失败。

| 内容 | P0 要求 |
| --- | --- |
| 基本信息 | 操作人、模块、动作、时间、状态 |
| 请求信息 | 方法、路径、IP、traceId |
| 对象信息 | 目标对象类型和 ID，无法确定时说明为空 |
| 错误信息 | 失败原因中文摘要，不展示堆栈给普通用户 |
| 脱敏参数 | 可选展示关键参数，但必须脱敏 |

## 13. 与 AI 和代码生成的关系

| 能力 | S2 提供 |
| --- | --- |
| AI 工作台登录态 | 当前用户、角色、权限 |
| AI 任务审计 | 可复用操作人、日志字段 |
| 代码生成菜单 | 生成模块可写入 `sys_menu` |
| 代码生成权限 | 权限标识和按钮权限与系统管理一致 |
| 字典字段生成 | 业务字段可引用 `sys_dict_type` |
| 数据权限说明 | 生成模块必须选择或说明数据范围 |

约束：AI 不能绕过 S2 权限基础。AI 生成的菜单、接口和按钮必须和系统权限模型保持一致。

## 14. 前端交互约束

| 约束 | 说明 |
| --- | --- |
| 表格页统一 | 查询区、表格、分页、操作列位置一致 |
| 表单校验中文 | 必填、长度、格式提示使用中文 |
| 危险操作确认 | 删除、禁用、重置密码必须确认 |
| Long ID 字符串化 | 前端 ID 使用 string |
| version 原样传递 | 编辑表单保存加载时的 version，冲突后不得自动覆盖，必须重新读取 |
| 菜单树懒加载可选 | P0 可一次性加载 |
| 失败提示可读 | 后端错误 message 直接可展示 |

P0 不追求复杂动效和多主题，优先保证功能清楚、权限正确、可维护。

## 15. 质量门禁

| 门禁 | 验收方式 |
| --- | --- |
| 登录成功 | 管理员能登录进入首页 |
| 登录失败 | 错误密码返回中文错误并记录日志 |
| 密码存储 | PBKDF2-HMAC-SHA256/600000 次、独立 salt，数据库和日志无明文或可逆密码 |
| 登录限流 | 账号/IP 双维度限制生效，返回 `AUTH_0429` 和 `Retry-After`，未知账号不泄漏存在性 |
| Cookie 会话 | 响应体不返回 Token；Cookie 为 Host-only、HttpOnly、SameSite=Strict，HTTPS 模式带 Secure |
| CSRF | 缺失或错误 `X-CSRF-Token` 的已登录写请求被拒绝；合法同源请求通过 |
| 会话失效 | 登出失效当前会话；改密、重置、禁用和删除使目标账号全部会话失效 |
| 菜单权限 | 不同角色看到不同菜单 |
| 接口权限 | 无权限访问返回 `AUTH_0403` |
| 用户管理 | 可创建、编辑、禁用、重置密码、分配角色 |
| 角色管理 | 可分配菜单和按钮权限 |
| 部门管理 | 可维护树形部门 |
| 字典管理 | 可维护字典类型和字典项 |
| 操作日志 | 新增、修改、删除、重置密码有记录 |
| 数据权限基础 | 数据范围枚举、当前用户上下文、部门树和查询扩展点可验证；未接入模块有明确限制说明 |
| 审计详情 | 操作日志详情能看到 traceId、操作人、路径、目标对象、状态和脱敏后的错误摘要 |
| 并发冲突 | 两个会话编辑同一记录时，后提交者收到 `DATA_0409`，不能覆盖先提交结果 |
| 重复提交 | 唯一键、关系保存和重复删除行为符合 `docs/api-conventions.md`，不产生重复关系或重复副作用 |
| 构建验证 | 后端测试或打包、前端 build 通过 |

## 16. 实现前准入

进入 S2 编码前必须确认：

| 条件 | 状态 |
| --- | --- |
| 权限框架 | 已由 ADR-0001 确认为 Sa-Token 1.45.0 |
| Token 策略 | 已由 ADR-0002 确认为 Sa-Token + Redis |
| API 规范 | 已由 `docs/api-conventions.md` 确认 |
| 数据库表域 | 已由 `docs/database-baseline.md` 确认 |
| 安全底线 | 已由 `docs/security-governance.md` 确认 |
| 页面范围 | 已由本文确认 |
| S2 验收门禁 | 已由本文确认 |

## 17. 一句话总结

基础后台的目标不是展示功能丰富，而是建立一个可靠的企业应用地基：登录可信、权限闭环、菜单可控、数据可维护、行为可审计，并能支撑 AI 生成真实业务模块。
