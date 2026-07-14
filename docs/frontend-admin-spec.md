# Vibe Boot 前端管理端规格

## 1. 文档目的

本文定义 Vibe Boot 首版 Vue 3 管理端的目录结构、路由、布局、菜单、权限、API 调用、页面模式、组件约束和生成规范。

前端管理端不是营销站，也不是低代码设计器。它是中小企业用户每天使用的工作台，应当稳定、清晰、密集但不杂乱，并且让 AI 生成的页面与人工编写页面保持一致。

## 2. 基本决策

| 项目 | 决策 |
| --- | --- |
| 前端框架 | Vue 3.5.39 |
| 构建工具 | Vite 8.1.3 |
| Vue 插件 | `@vitejs/plugin-vue` 6.0.7 |
| 语言 | TypeScript 6.0.3 |
| UI 组件库 | Element Plus 2.14.2 |
| 状态管理 | Pinia 3.0.4 |
| 路由 | Vue Router 4.6.4 |
| HTTP 客户端 | Axios 1.18.1 |
| 包管理器 | npm |
| Node 版本 | Node.js 24.x LTS（基线 24.18.0） |
| 目标终端 | PC 管理端 |
| 移动端 | P0 不做 |

以上决策已由 ADR-0001 和产品约束确认。首版不允许混用第二套 UI 组件库，不使用 `latest`、`*` 或未锁定主版本；`package.json#engines.node` 使用 `>=24.18.0 <25`，具体安装结果以 `package-lock.json` 为准。

## 3. 设计原则

| 原则 | 说明 |
| --- | --- |
| 工具优先 | 管理端是工作界面，不做营销式大 Hero |
| 信息密度适中 | 表格、搜索、操作区应便于重复使用 |
| 模式统一 | 列表、表单、详情、弹窗和按钮位置统一 |
| 权限同源 | 菜单、按钮和接口权限使用同一权限标识 |
| 中文优先 | 首版文案、错误、提示、空状态使用中文 |
| AI 友好 | 目录、命名、组件模式固定，便于生成和维护 |
| 构建可靠 | 任意生成页面后必须能通过 `npm run build` |

## 4. 不做事项

| 不做 | 原因 |
| --- | --- |
| 不做移动端/小程序 | 首版聚焦 PC 管理端 |
| 不做多主题系统 | 先保证业务可用和生成一致 |
| 不做拖拽页面设计器 | 避免偏向传统低代码运行时 |
| 不做大屏设计器 | P2 再根据真实需求评估 |
| 不做复杂前端微应用 | 单体应用优先 |
| 不引入第二套图标/UI 库 | 降低依赖和风格分裂 |
| 不做国际化 | 首版面向中国用户 |

## 5. 目录结构

```text
frontend/
├── package.json
├── package-lock.json
├── vite.config.ts
├── index.html
├── .npmrc
└── src/
    ├── api/
    │   ├── auth/
    │   ├── system/
    │   ├── ai/
    │   ├── gen/
    │   ├── file/
    │   └── biz/
    ├── assets/
    ├── components/
    │   ├── AppTable/
    │   ├── AppFormDialog/
    │   ├── PermissionButton/
    │   └── DictTag/
    ├── layout/
    ├── router/
    ├── stores/
    ├── styles/
    ├── utils/
    └── views/
        ├── login/
        ├── dashboard/
        ├── system/
        ├── ai/
        ├── gen/
        ├── file/
        └── biz/
```

约束：

| 目录 | 约束 |
| --- | --- |
| `src/api/<domain>` | 与后端 API domain 对齐 |
| `src/views/<domain>` | 与业务域对齐 |
| `src/components` | 只放跨页面复用组件 |
| `src/layout` | 只放管理端框架布局 |
| `src/stores` | 登录态、菜单、权限、字典等全局状态 |
| `src/utils` | 请求、权限、日期、下载等纯工具 |

## 6. 布局规格

P0 采用经典后台布局。

| 区域 | 要求 |
| --- | --- |
| 左侧菜单 | 后端菜单树驱动，支持目录和菜单 |
| 顶部栏 | 系统名、折叠菜单、用户菜单、退出 |
| 主内容区 | 承载页面内容，不使用嵌套卡片堆叠 |
| 面包屑 | P0 必做，由路由元信息生成；只显示当前层级，不引入额外依赖 |
| 标签页 | P1，可先不做 |
| 首页 | 简单系统状态和快捷入口，不做装饰性大屏 |

视觉约束：

| 约束 | 说明 |
| --- | --- |
| 卡片克制 | 页面主体不层层套卡片 |
| 边框圆角 | 8px 以内，遵守现有 Element Plus 风格 |
| 字号稳定 | 不使用随视口缩放的字体 |
| 文本不重叠 | 表格、按钮、弹窗在常见宽度下不得溢出 |
| 颜色克制 | 不做单一紫色/蓝紫渐变主题 |

## 7. 路由与菜单

后端 `sys_menu` 是菜单和路由的主要来源。

| 字段 | 前端用途 |
| --- | --- |
| `menu_type` | directory/menu/button |
| `menu_name` | 菜单标题 |
| `route_path` | 路由 path |
| `component` | 组件路径 |
| `permission` | 按钮或页面权限 |
| `icon` | 菜单图标 |
| `visible` | 是否显示 |
| `sort_order` | 排序 |

约束：

| 约束 | 说明 |
| --- | --- |
| 登录后加载菜单 | 调用 `/api/auth/menus` |
| 按钮权限单独加载 | 调用 `/api/auth/permissions` |
| 前端路由动态注册 | 根据菜单组件路径映射到本地 view |
| 后端权限为准 | 前端无菜单不代表接口可访问 |
| 404/403 页面 | P0 必须有中文提示 |

## 8. 权限按钮

按钮显示使用统一能力，不在页面里散落字符串判断。

| 场景 | 规则 |
| --- | --- |
| 新增按钮 | `system:user:create`、`biz:customerVisit:create` |
| 编辑按钮 | `*:update` |
| 删除按钮 | `*:delete` |
| 导出按钮 | `*:export` |
| 测试连接 | `ai:modelConfig:test` |

建议组件：

| 组件 | 作用 |
| --- | --- |
| `PermissionButton` | 根据权限决定是否渲染按钮 |
| `usePermission()` | 在脚本中判断权限 |

约束：权限隐藏只改善体验，安全边界必须由后端接口权限保证。

## 9. API 调用规范

API 文件遵守 `docs/api-conventions.md`。

| 项目 | 规范 |
| --- | --- |
| 路径 | `src/api/{domain}/{resource}.ts` |
| 请求封装 | 统一 request 实例 |
| 响应处理 | 解包 `Result<T>`，失败显示中文 message |
| Long ID | TypeScript 中使用 string |
| 分页类型 | 与 `PageResult<T>` 对齐 |
| 下载 | 使用统一 download 工具 |

示例命名：

| 后端动作 | 前端函数 |
| --- | --- |
| page | `pageUser`、`pageCustomerVisit` |
| detail | `getUser`、`getCustomerVisit` |
| create | `createUser`、`createCustomerVisit` |
| update | `updateUser`、`updateCustomerVisit` |
| delete | `deleteUser`、`deleteCustomerVisit` |

## 10. 页面模式

### 10.1 列表页

列表页是 P0 生成和人工开发的主模式。

| 区域 | 要求 |
| --- | --- |
| 查询区 | 顶部，常用 2-4 个条件，支持重置 |
| 工具栏 | 新增、导出、批量操作等 |
| 表格 | 中部，固定操作列，分页在底部 |
| 操作列 | 查看、编辑、删除等，危险操作需确认 |
| 分页 | pageNo/pageSize/total |

约束：

| 约束 | 说明 |
| --- | --- |
| 查询条件不过多 | 超过 4 个时 P1 再做展开收起 |
| 操作按钮不拥挤 | 超过 3 个可使用更多菜单 |
| 删除必须确认 | 使用 Element Plus 确认框 |
| 空状态中文 | 明确说明暂无数据 |
| 加载状态明确 | 查询期间显示 loading |

### 10.2 表单弹窗

P0 单表 CRUD 的新增和编辑固定使用同一个弹窗表单组件；不为同一实体再生成独立新增/编辑路由。

| 项目 | 规范 |
| --- | --- |
| 组件 | `form.vue` 或领域命名表单组件 |
| 宽度 | 桌面固定 720 px，窄屏使用 `calc(100vw - 32px)` 上限，不允许内容撑破视口 |
| 校验 | Element Plus Form rules |
| 提交 | 防重复提交 |
| 成功 | 关闭弹窗并刷新列表 |
| 失败 | 展示后端中文错误 |

当字段很多或存在复杂详情时，P1 再使用独立详情页。

### 10.3 详情页

P0 代码生成器不生成独立详情页；GET 详情接口只用于编辑回填和权限校验。复杂只读详情页统一属于 P1。

| P1 场景 | 规则 |
| --- | --- |
| 字段少 | 弹窗详情 |
| 字段多 | 独立详情页 |
| 有明细表 | P1 再设计 |

## 11. 字典与枚举

| 场景 | 规范 |
| --- | --- |
| 后端字典 | 使用 `sys_dict_type` 和 `sys_dict_item` |
| 前端展示 | 使用 `DictTag` 或统一字典渲染 |
| 表单选择 | P0 字典/枚举统一使用 Select，boolean 使用 Switch；Radio 变体到 P1 再决定 |
| 缓存 | 登录后或首次使用时加载 |
| 生成页面 | 字典字段必须声明 `dictType` |

业务枚举若需要用户维护，应使用系统字典；不可维护的技术枚举可放在前端常量中。

## 12. AI 工作台页面

AI 工作台是核心页面，不应藏在工具角落。

| 区域 | P0 要求 |
| --- | --- |
| 输入区 | 任务类型、模型、自然语言需求 |
| 上下文区 | 展示使用的文档和规则摘要 |
| 计划区 | 展示变更计划、文件、接口、SQL、权限 |
| 风险区 | 显示 L1/L2/L3 风险 |
| 变更区 | 展示 diff 或生成产物 |
| 验证区 | 展示构建/测试结果 |
| 历史区 | P1 可增强，P0 可简单列表 |

AI 工作台不使用营销文案，不做装饰性插画，重点是任务状态清晰。

## 13. 代码生成页面约束

AI 或生成器创建 Vue 页面时必须遵守：

| 生成项 | 规范 |
| --- | --- |
| API 文件 | `src/api/{domain}/{resource}.ts` |
| 列表页 | `src/views/{domain}/{resource}/index.vue` |
| 表单组件 | `src/views/{domain}/{resource}/form.vue` |
| 权限按钮 | 使用统一权限组件或指令 |
| 字典字段 | 使用统一字典组件 |
| Long ID | 使用 string 类型 |
| 构建验证 | 生成后必须运行或提示 `npm run build` |

生成前端代码还必须满足可接管要求：

| 要求 | 说明 |
| --- | --- |
| 不留 TODO 占位 | 页面不能包含未实现按钮、空 submit 或假数据 |
| 不硬编码 API Base | 只能使用统一 request |
| 不新增临时 UI 风格 | 复用 Element Plus 和既有组件模式 |
| 不隐藏失败 | API 失败必须展示后端中文 message |
| 不绕过权限组件 | 行操作和工具栏按钮必须接入权限判断 |
| 人工修改可保留 | 二次生成不能静默覆盖用户已修改的 Vue/TS 文件 |

禁止生成：

| 禁止 | 原因 |
| --- | --- |
| 绕过统一 request 的 fetch/axios | credentials、CSRF、错误处理和 traceId 会失效 |
| 直接硬编码 API Base | 破坏开发/生产模式 |
| 无权限按钮 | 与后端权限不一致 |
| 新增 UI 依赖 | 技术栈膨胀 |
| 整页营销式布局 | 管理端不是落地页 |

## 14. 状态管理

P0 全局状态保持克制。

| Store | 内容 |
| --- | --- |
| auth | 当前用户、登录状态、仅内存 CSRF Token；不保存会话 Token |
| menu | 菜单树、动态路由状态 |
| permission | 权限标识集合 |
| dict | 字典缓存 |
| app | 侧边栏折叠、基础 UI 状态 |

业务页面优先使用本地组件状态，避免把临时表单状态放入全局 Store。

认证请求约束：

| 项目 | P0 要求 |
| --- | --- |
| Cookie | 统一 request 使用同源 Cookie/`credentials`，JavaScript 不读取 `VIBEBOOT_SESSION` |
| Token 存储 | 禁止 localStorage、sessionStorage、IndexedDB、Pinia 持久化或 URL 保存会话 Token |
| CSRF | 登录后请求 `/api/auth/csrf`，仅在内存保存；所有 POST/PUT/PATCH/DELETE 自动添加 `X-CSRF-Token` |
| 页面刷新 | 重新调用 `/api/auth/me` 和 `/api/auth/csrf` 恢复状态，不从本地持久化恢复凭据 |
| 退出/401 | 清空用户、菜单、权限和 CSRF 内存状态，跳转登录页 |

## 15. 错误与空状态

| 场景 | 要求 |
| --- | --- |
| 401 | 跳转登录，提示登录失效 |
| 403 | 中文提示无权限 |
| `AUTH_0409` | 跳转强制改密页，不加载业务菜单 |
| 429/`AUTH_0429` | 显示后端等待提示，读取 `Retry-After` 后暂时禁用登录按钮 |
| 404 | 中文页面不存在 |
| 500 | 中文提示系统异常，可显示 traceId |
| 表格空数据 | 显示暂无数据 |
| 请求失败 | 展示后端 message |
| 构建失败 | 不在页面吞掉错误，AI 工作台需展示摘要 |

## 16. 质量门禁

| 门禁 | 验收方式 |
| --- | --- |
| 类型检查 | TypeScript 无明显类型错误 |
| 构建 | `npm run build` 通过 |
| 登录流程 | 登录、退出、登录失效处理可用 |
| 会话安全 | 浏览器存储中无会话 Token，CSRF Header 和 Cookie credentials 由统一 request 管理 |
| 菜单路由 | 后端菜单能生成前端路由 |
| 权限按钮 | 不同角色按钮显示不同 |
| 基础后台页面 | S2 页面按 `basic-admin-spec.md` 可用 |
| 生成页面 | 生成 CRUD 页面可查询、新增、编辑、删除 |

## 17. 实现前准入

进入前端编码前必须确认：

| 条件 | 状态 |
| --- | --- |
| UI 组件库 | 已由 ADR-0001 确认为 Element Plus |
| Node/npm | 已由 ADR-0001 确认 |
| 目录结构 | 已由 `docs/module-design.md` 和本文确认 |
| API 规范 | 已由 `docs/api-conventions.md` 确认 |
| 基础后台页面 | 已由 `docs/basic-admin-spec.md` 确认 |
| 生成页面模式 | 已由 `docs/code-generation-design.md` 和本文确认 |

## 18. 一句话总结

Vibe Boot 前端管理端要像一个可靠的企业工具：布局稳定、权限同源、页面模式统一、错误中文可读，并让 AI 生成的 Vue 页面自然融入同一个系统。
