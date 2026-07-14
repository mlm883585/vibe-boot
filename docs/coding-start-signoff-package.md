# Vibe Boot 编码启动签收包

## 1. 文档目的

本文是 Vibe Boot 从文档优先阶段进入 S1 工程骨架编码前的最终人工确认入口。

它不替代 `docs/coding-start-signoff.md`。签收状态仍以 `docs/coding-start-signoff.md` 为准。本文的作用是把分散在冻结清单、准入审计、读者测试、变更控制和 S1 工作令中的关键承诺压缩成一份可阅读、可确认、可拒绝的签收包。

## 2. 当前结论

| 项目 | 当前结论 |
| --- | --- |
| 文档是否足以支撑 S1 工程骨架 | 是 |
| 当前是否已经签收 | 是，签收人 `mlm883585`，签收日期 `2026-07-14` |
| 当前是否允许创建源码目录 | 否，尚未收到精确启动口令 |
| 当前允许做什么 | 继续修订 `docs/`、复核签收状态或等待精确启动口令 |
| 签收后允许做什么 | 只允许按 S1 工作令创建工程骨架 |
| 签收后是否允许自动进入 S2/S3/S4 | 否 |
| 签收依据 | 已提交文档快照 `5107e56c58c200966f491bdbb9058cce3c452573` |

签收不是“开始完整产品开发”，只是在当前冻结范围内允许启动 S1 工程骨架。

## 2.1 当前是否满足编码

当前方案已完成维护者签收，但尚未满足“直接开始编码”。判断口径如下：

| 判定项 | 当前状态 | 是否满足编码 |
| --- | --- | --- |
| 产品与技术约束 | 已成文 | 是，作为签收审查依据 |
| AI 工具使用方式 | 已分层定稿 | 是，作为签收审查依据 |
| S1 工程骨架范围 | 已成文 | 是，作为签收审查依据 |
| 签收前预检命令 | 已于 2026-07-14 重跑并通过 | 是 |
| 签收仓库基线 | `5107e56c58c200966f491bdbb9058cce3c452573` | 是 |
| 签收前最终审查表 | 维护者已确认第 3.2 节全部审查域 | 是 |
| `docs/coding-start-signoff.md` | 已签收 | 是，仅表示 S1 范围已授权 |
| S1 精确启动口令 | 未发出 | 否，签收后仍需维护者另行发出 |
| S1 `stageAdmission` | 未生成 | 否，精确口令后、源码目录前必须写入 **docs/stage-records/S1-admission.md** |

因此，当前允许的下一步是继续修订文档、复核签收记录或等待维护者另行发出精确启动口令；仍不得创建 `backend/`、`frontend/`、`scripts/` 或 `config/`。

从当前状态进入 S1 编码的最小动作链如下：

| 顺序 | 动作 | 产物 | 失败时处理 |
| --- | --- | --- | --- |
| 1 | 重跑签收前预检命令包 | Git 状态、索引与编号、引用与表格、机器契约、manifest、源码目录、签收状态、忽略规则和 Git 差异格式结果 | 修订文档或基线说明，继续留在文档阶段 |
| 2 | 确认签收仓库基线 | 提交哈希，或签收文档 manifest 的生成时间、文件数量和纳入范围 | 不得签收 |
| 3 | 确认签收前最终审查表 | 第 3.2 节全部审查域均有明确接受结论 | 不得签收 |
| 4 | 更新 `docs/coding-start-signoff.md` | 签收结论、S1 许可、签收人、日期、基线、最终审查表和全部签收项 | 不得编码 |
| 5 | 维护者另行发出精确口令 | `开始 S1 工程骨架编码` | 只能继续文档或等待启动 |
| 6 | 持久化 S1 阶段准入 | **docs/stage-records/S1-admission.md**，包含完整 `stageAdmission` 且 decision=pass | 不得创建源码目录 |
| 7 | 创建源码目录前输出 S1 开工检查 | `signoffStatus`、`s1Allowed`、`launchPhraseExact`、`stageAdmissionPath`、`sourceDirsBefore`、`allowedScope`、`forbiddenScope`、`admissionCard.result` | 检查失败则停止编码 |

## 3. 签收前最短阅读路径

维护者如果不想重新阅读全部文档，至少必须按以下顺序阅读。

| 顺序 | 文档 | 必须确认的问题 |
| --- | --- | --- |
| 1 | `docs/README.md` | 文档入口、关键决策和编码闸门是否清楚 |
| 2 | `docs/coding-freeze-checklist.md` | 是否接受冻结项 |
| 3 | `docs/documentation-readiness-review.md` | 文档体系是否足以支撑 S1 |
| 4 | `docs/post-coding-change-control.md` | 编码后新增请求如何处理 |
| 5 | `docs/pre-coding-reader-test.md` | 新维护者或外部 AI 是否能理解边界 |
| 6 | `docs/pre-coding-reader-test-results.md` | 当前读者测试是否通过 |
| 7 | `docs/requirements-traceability-matrix.md` | 原始产品要求是否均已有文档证据 |
| 8 | `docs/documentation-verification-log.md` | 索引与编号、引用与表格、机器契约、签收状态、目录状态、忽略规则和 Git 差异格式是否可复查 |
| 9 | `docs/s1-implementation-work-order.md` | S1 具体允许和禁止什么 |
| 10 | `docs/coding-start-signoff.md` | 是否正式签收 |

## 3.1 签收前预检命令包

维护者签收前必须至少完成以下预检。预检通过不自动授权编码，只证明签收材料可复查；真正开工仍必须更新 `docs/coding-start-signoff.md` 并在签收后发出精确启动口令。

| 预检项 | 命令或动作 | 期望结果 |
| --- | --- | --- |
| Git 状态 | `git status --short` | 明确哪些文件已修改、未跟踪或待提交；用于填写签收基线 |
| README 索引与编号 | 执行本文下方 README 索引检查命令 | `MissingFromIndex=0`、`MissingFiles=0`、`ReadmeNumbering=continuous` |
| Markdown 引用 | 执行本文下方 Markdown 引用检查命令 | `MissingMarkdownRefs=0` |
| Markdown 表格结构 | 执行本文下方 Markdown 表格结构检查命令 | `TableIssues=0` |
| 签收文档 manifest | 执行本文下方签收文档 manifest 生成命令 | 输出 `docs` 目录下每个文件的相对路径、SHA256、大小和更新时间；必须包含 Markdown、JSON Schema 和标准样例，用于签收未提交工作区 |
| JSON 机器契约 | 执行本文下方 Schema/样例及内嵌副本检查 | 两个样例均为 `valid`，`install-example-sync=true`、`install-schema-sync=true` |
| 源码目录 | `Test-Path backend, frontend, scripts, config` 或等价检查 | 签收前应为未创建，除非已有明确授权说明 |
| 签收状态 | 执行本文下方签收状态检查命令 | 签收前应显示未签收；签收时必须补齐签收基线 |
| 忽略规则 | 检查 `.gitignore` | `reference/`、runtime、data、logs、package、local 配置等已忽略 |
| Git 差异格式 | 执行本文下方 Git 差异格式检查命令 | `GitDiffCheck=passed`；不得有空白错误 |

签收状态检查：

```powershell
Select-String -Path docs\coding-start-signoff.md -Pattern "签收结论|是否允许开始 S1 编码|签收基线"
```

README 索引检查：

```powershell
$actual = Get-ChildItem docs -Recurse -Filter *.md | ForEach-Object { (Resolve-Path -LiteralPath $_.FullName -Relative).Replace('.\docs\','').Replace('\','/') } | Sort-Object
$indexed = Select-String -Path docs\README.md -Pattern '^\| \d+ \| `([^`]+)`' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Sort-Object
$missingFromIndex = @($actual | Where-Object { $_ -notin $indexed -and $_ -ne 'README.md' })
$missingFiles = @($indexed | Where-Object { $_ -notin $actual })
$nums = Select-String -Path docs\README.md -Pattern '^\| (\d+) \|' | ForEach-Object { [int]$_.Matches[0].Groups[1].Value }
$numberDiff = @(Compare-Object (1..$nums.Count) $nums)
'MissingFromIndex=' + $missingFromIndex.Count
'MissingFiles=' + $missingFiles.Count
'ActualDocs=' + $actual.Count
'IndexedDocs=' + $indexed.Count
if ($numberDiff.Count -eq 0) { 'ReadmeNumbering=continuous; Count=' + $nums.Count } else { 'ReadmeNumbering=invalid; Diff=' + $numberDiff.Count }
```

Markdown 引用检查：

```powershell
$files = Get-ChildItem docs -Recurse -Filter *.md
$missing = @()
foreach ($file in $files) {
  $text = Get-Content -LiteralPath $file.FullName -Raw
  $matches = [regex]::Matches($text, '`([^`]+\.md)`')
  foreach ($m in $matches) {
    $ref = $m.Groups[1].Value
    if ($ref.StartsWith('docs/')) { $path = Join-Path (Get-Location) $ref.Replace('/','\') }
    else { $path = Join-Path $file.DirectoryName $ref.Replace('/','\') }
    if (-not (Test-Path -LiteralPath $path)) { $missing += [pscustomobject]@{ File=$file.FullName; Ref=$ref; Resolved=$path } }
  }
}
'MissingMarkdownRefs=' + $missing.Count
```

Markdown 表格结构检查；使用开发包已固定的 Node.js，不安装额外依赖。检查器忽略 fenced code block，按未转义且不在行内代码中的 `|` 切分单元格：

```powershell
@'
const fs = require('fs');
const path = require('path');

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    return entry.isDirectory() ? walk(full) : (full.endsWith('.md') ? [full] : []);
  });
}

function splitRow(line) {
  const text = line.trim().replace(/^\|/, '').replace(/\|$/, '');
  const cells = [''];
  let inCode = false;
  for (let i = 0; i < text.length; i++) {
    const char = text[i];
    if (char === '\\' && i + 1 < text.length) cells[cells.length - 1] += char + text[++i];
    else if (char === '`') { inCode = !inCode; cells[cells.length - 1] += char; }
    else if (char === '|' && !inCode) cells.push('');
    else cells[cells.length - 1] += char;
  }
  return cells.map((cell) => cell.trim());
}

const issues = [];
for (const file of walk('docs')) {
  const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
  let fenced = false;
  for (let i = 0; i < lines.length; i++) {
    if (/^\s*```/.test(lines[i])) { fenced = !fenced; continue; }
    if (fenced || !/^\s*\|.*\|\s*$/.test(lines[i])) continue;
    const start = i;
    const block = [];
    while (i < lines.length && /^\s*\|.*\|\s*$/.test(lines[i])) block.push(lines[i++]);
    i--;
    if (block.length < 2) continue;
    const header = splitRow(block[0]);
    const separator = splitRow(block[1]);
    if (separator.length !== header.length || !separator.every((cell) => /^:?-{3,}:?$/.test(cell))) {
      issues.push(`${file}:${start + 1}: invalid table separator`);
      continue;
    }
    block.forEach((line, offset) => {
      const count = splitRow(line).length;
      if (count !== header.length) issues.push(`${file}:${start + offset + 1}: expected ${header.length} cells, got ${count}`);
    });
  }
}

console.log('TableIssues=' + issues.length);
if (issues.length) { console.log(issues.join('\n')); process.exit(1); }
'@ | node -
```

签收文档 manifest 生成：

```powershell
$manifest = Get-ChildItem docs -Recurse -File | Sort-Object FullName | ForEach-Object {
  $relative = (Resolve-Path -LiteralPath $_.FullName -Relative).Replace('.\','').Replace('\','/')
  $hash = Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256
  [pscustomobject]@{
    Path = $relative
    SHA256 = $hash.Hash
    Bytes = $_.Length
    LastWriteTime = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
  }
}
$manifest | Format-Table -AutoSize
'ManifestFiles=' + @($manifest).Count
```

JSON 机器契约检查；`npx` 必须使用受控 npm 镜像，固定 `ajv-cli@5.0.0`，该工具只用于文档审计，不进入产品依赖：

```powershell
npx --yes ajv-cli@5.0.0 validate --spec=draft2020 --strict=true -s docs/contracts/codegen-meta-model-v1.schema.json -d docs/contracts/examples/customer-visit-meta-model-v1.json
npx --yes ajv-cli@5.0.0 validate --spec=draft2020 --strict=true -s docs/contracts/install-v1.schema.json -d docs/contracts/examples/install-v1.example.json

@'
const fs = require('fs');
const md = fs.readFileSync('docs/release-package-design.md', 'utf8');
const blocks = [...md.matchAll(/^```json\r?\n([\s\S]*?)\r?\n```/gm)].map((m) => JSON.parse(m[1]));
const example = blocks.find((x) => x.schemaVersion === 1 && x.installRoot === 'C:\\VibeBoot');
const schema = blocks.find((x) => x.$id === 'https://vibe-boot.local/schemas/install-v1.json');
const stable = (x) => Array.isArray(x) ? x.map(stable) : x && typeof x === 'object' ? Object.fromEntries(Object.keys(x).sort().map((k) => [k, stable(x[k])])) : x;
const equal = (a, b) => JSON.stringify(stable(a)) === JSON.stringify(stable(b));
const fileExample = JSON.parse(fs.readFileSync('docs/contracts/examples/install-v1.example.json', 'utf8'));
const fileSchema = JSON.parse(fs.readFileSync('docs/contracts/install-v1.schema.json', 'utf8'));
console.log('install-example-sync=' + equal(example, fileExample));
console.log('install-schema-sync=' + equal(schema, fileSchema));
if (!equal(example, fileExample) || !equal(schema, fileSchema)) process.exit(1);
'@ | node -
```

Git 差异格式检查：

```powershell
git diff --check
if ($LASTEXITCODE -eq 0) { 'GitDiffCheck=passed' } else { throw 'git diff --check failed' }
```

签收基线规则：

| 基线类型 | 记录要求 | 约束 |
| --- | --- | --- |
| 已提交文档快照 | 在 `docs/coding-start-signoff.md` 记录提交哈希 | 签收只覆盖该提交中的文档内容 |
| 未提交工作区文档 | 记录 manifest 生成时间、`ManifestFiles` 数量、纳入范围，并保留 manifest 输出 | 签收只覆盖 manifest 中列出的文件和 SHA256；机器契约不得排除 |

如果选择签收未提交工作区，`git status --short` 不能单独作为基线。未列入签收文档 manifest 的草稿、临时文件和后续修改不得作为编码依据。

如果任一预检失败，不得签收。应先修订对应文档、索引、引用、忽略规则或签收基线说明，再重新执行预检。

## 3.2 签收前最终审查表

维护者完成第 3.1 节预检后，应按下表做最后一次人工审查。所有项目都必须有明确结论；不能用“基本可以”“先试试”“后面补”替代。

| 审查域 | 必须确认 | 签收结论 |
| --- | --- | --- |
| 产品范围 | P0/P1 不再扩大，首个演示仍是客户拜访记录 | 已确认 |
| 技术栈 | JDK 17、Maven 3.8.x、Spring Boot 3.5.16、MySQL 8、Redis、Node.js 24.x LTS（基线 24.18.0）、Vue 3.5.39、Vite 8.1.3、TypeScript 6.0.3、Element Plus 2.14.2、Pinia 3.0.4、Vue Router 4.6.4、Axios 1.18.1、npm 等最小栈不再新增 | 已确认 |
| Windows 优先 | 首版先做 Windows 开发包和生产安装包，Linux/Docker 延后 | 已确认 |
| AI 工具分层 | 外部 AI Coding 工具、平台 AI 工作台、模型网关、生产业务 AI 的分工接受 | 已确认 |
| 企业用户路径 | 企业用户不必懂源码，可通过平台工作台和实施人员完成需求到工程交接 | 已确认 |
| 模型数据与出站安全 | 数据分类、最小化、脱敏、权限过滤、出境风险提示和 API Base SSRF/DNS/TLS 门禁接受 | 已确认 |
| 开源合规 | 开发包必须有 runtime manifest/NOTICE；生产包必须有 runtime manifest、依赖 manifest、NOTICE，且来源、版本、许可证和 SHA256 可追踪 | 已确认 |
| 受控发布 | 生产只能走构建包、安装或升级脚本、版本化迁移和健康检查 | 已确认 |
| 签收基线 | 已明确提交哈希，或已生成签收文档 manifest 并保留 SHA256 清单 | 已确认 |
| 预检结果 | README 索引、Markdown 引用、源码目录、签收状态、忽略规则和 manifest 均已复查 | 已确认 |
| S1 范围 | S1 只做工程骨架，不提前做登录、AI 工作台、业务模块或生产包 | 已确认 |
| S1 开工检查 | 创建源码目录前仍必须输出结构化 S1 开工检查和 `admissionCard.result=pass` | 已确认 |
| S1 关闭证据 | S1 完成时必须提交阶段关闭证据包，不能自动进入 S2 | 已确认 |
| 变更控制 | 编码后新增请求必须按 C0-C4 判断，C0 不绕过阶段签收和启动指令 | 已确认 |
| 模糊签收排除 | “同意”“可以开始”“按文档做”“交给 AI 继续”均不视为签收 | 已确认 |

最终审查表不是新的授权动作。它只证明维护者已经读懂签收包；真正授权仍以 `docs/coding-start-signoff.md` 的签收记录和后续精确启动口令为准。

## 4. 必须接受的产品承诺

| 承诺 | 接受含义 |
| --- | --- |
| Vibe Boot 不是传统低代码运行时 | 首版生成真实 Java/Vue 代码，不做复杂拖拽解释器 |
| 目标用户是中国中小企业和实施人员 | 首版优先低成本、Windows 可用、中文提示、国内镜像 |
| 架构是模块化单体 | 不引入微服务治理复杂度 |
| P0/P1 不再扩大 | 编码阶段不继续把新想法塞进 MVP |
| 首个演示只做客户拜访记录 | 不同时扩展到多行业模板或复杂流程 |
| P0 文件能力保持基础服务范围 | S2 只实现本地单文件白名单上传、鉴权访问、图片预览、配额和两阶段删除；业务附件、Office、对象存储延后 |
| 开发成果进入生产必须走受控发布通道 | 只接受 `build-prod.ps1` 产物、`install.ps1`/`upgrade.ps1`、版本化迁移和健康检查 |
| 第三方依赖和 runtime 必须可追踪 | 开发包和生产包必须记录来源、完整版本、许可证、NOTICE、SHA256 和依赖 manifest；runtime patch 可升级但必须进入 manifest |
| 签收基线必须可复查 | 签收前必须检查 `git status`、文档索引、Markdown 引用、签收文档 manifest、源码目录和忽略规则；未纳入签收基线的草稿不得作为编码依据 |

## 5. 必须接受的技术承诺

| 承诺 | 接受含义 |
| --- | --- |
| JDK 17 + Maven 3.8.x | 不切 Gradle，不追新 JDK；允许同主版本安全补丁升级，但发行包必须记录完整版本和 SHA256 |
| Spring Boot 3.5.16 | 不引入 Spring Cloud，不自动升级 Spring Boot 4.x |
| MySQL 8 + Redis | 不做多数据库矩阵 |
| Vue 3.5.39 + Vite 8.1.3 + TypeScript 6.0.3 + Element Plus 2.14.2 + Pinia 3.0.4 + Vue Router 4.6.4 + Axios 1.18.1 | 不切 React，不引入第二套 UI，不使用 `latest` 或 `*` |
| Node.js 24.x LTS（基线 24.18.0）+ npm + `package-lock.json` | 不切 pnpm/yarn，不允许 EOL Node 运行时进入开发发行包 |
| Sa-Token 1.45.0、MyBatis-Plus 3.5.16、Springdoc OpenAPI 2.8.17、Velocity 2.4.1、Flyway、Procrun 1.6.1 | 按 ADR-0001 执行；Flyway 优先跟随 Spring Boot BOM，Procrun 只使用官方 1.6.1 x64 发布物 |
| OpenAI 兼容协议优先 | 模型接入先走统一模型网关 |
| 模型凭据不新增加密依赖 | 使用 JDK AES-256-GCM；供应商 API Key 密文入库，32-byte 主密钥外置，响应只返回 `credentialConfigured` |
| 并发与重复提交不新增中间件 | P0 使用唯一约束、version 乐观锁、状态条件更新和短事务；不为普通 CRUD 引入 Redis 锁或通用 Idempotency-Key |
| traceId 由服务端统一生成 | 统一响应体、`X-Trace-Id` 和 MDC 使用同一值，客户端不得覆盖，供应商 requestId 单独记录 |
| 密码存储不新增依赖 | 使用 JDK 17 PBKDF2-HMAC-SHA256/600000 次、独立 salt 和自描述格式，不使用快速摘要或可逆加密 |
| 浏览器会话不使用 JWT | Sa-Token + Redis 不透明 Token 只通过 HttpOnly Cookie 传递，P0 不生成 Token Secret，不写入 Web Storage |
| Cookie 写请求必须防 CSRF | 生产同源并默认关闭 CORS；写请求校验 Origin 和会话绑定 `X-CSRF-Token` |
| 生产非回环必须 HTTPS | local 模式只绑定 127.0.0.1；lan 模式缺少 PKCS12、匹配主机名或 allowedOrigin 时阻断安装 |
| 防火墙不默认放行 | 只有管理员显式确认才创建产品自有 HTTPS 业务端口规则，永不自动开放 Actuator 8081、MySQL 或 Redis |
| PowerShell 配置固定 JSON | Windows PowerShell 5.1 的 `ConvertFrom-Json` 只做初筛；已认证 Java classpath 从原始 bytes 做 strict duplicate detection 和机器 Schema 权威校验；Spring Boot 才读取 YAML |
| 安装配置只有一个机器契约 | `docs/contracts/install-v1.schema.json` 与标准样例是唯一结构输入，密码不在 schema，目录由 installRoot 派生，未知字段和非法跨字段组合拒绝 |
| 生产包必须可认证 | 首装先用 OS-only Authenticode API 比对带外 signer thumbprint，再由目标脚本验证所有签名和签名 `PACKAGE-MANIFEST.psd1`；包内自报哈希或 signer 不构成信任 |
| Windows 服务最小权限 | Procrun 固定 LocalService + service SID；安装根和各子目录关闭继承、写显式 ACE，`operations/` 与 `data/` 为兄弟目录，服务不能修改程序、配置、脚本或操作状态 |
| MySQL 运行/迁移账号分离 | 常驻服务只有 DML；独立迁移账号只进一次性 Jar migrate 子进程，常驻服务禁用 Flyway |
| MySQL/Redis 传输和备份客户端固定 | 非回环连接强制 CA 与主机名校验 TLS；安装前锁定 MySQL 8 `mysql.exe`/`mysqldump.exe` 路径、版本和 SHA256，不在脚本中联网下载 |
| 高风险迁移不能静默放行 | 风险源与 SQL 一一对应；开关、当次精确短语、operationId、列表 hash、二次 preflight/migrate 复核缺一不可，P0 不支持无人值守确认 |
| 备份不包含 secret | 数据库密文可备份，但模型主密钥、数据库/Redis/TLS 密码和私钥永远排除；manifest 只记录密钥指纹 |
| 恢复必须使 Redis 状态失效 | 数据库恢复或回滚后由同一应用 `clear-redis-namespace` 清空本实例 key 前缀，旧会话、CSRF、限流和权限缓存不得继续使用；失败保持停服 |
| 升级必须可从任意提升中断恢复 | state v2 对九类资源记录 before/target hash 与五态子状态；全局 phase、maintenance.flag、migrationStarted 和损坏状态保守处理固定，F09 的 18 个中断用例必须全跑 |
| 初始管理员不进入 Flyway SQL | 生产默认交互输入并二次确认；只有显式 `-GenerateInitialAdminPassword` 才生成一次性 24 位密码，migrate 后同一 Jar bootstrap-admin 仅从 stdin 接收，事务创建 admin 并强制首次改密 |
| P0 实现输入不得留白 | API 路径、DTO/VO、权限、状态、错误语义、逻辑 DDL、生成元模型 Schema/样例和 owned 路径均以签收基线为准，不在编码时另补设计 |
| S2-S4 不以快速构建关闭 | `-DskipTests package` 只供反馈；阶段关闭必须有完整 Maven 测试、关键 MockMvc/API、真实 MySQL 8 和前端构建，S4 还需生成 CRUD 与数据隔离验证 |
| S7 证据来自独立干净环境 | 使用全新 Windows Server 2022 x64 NTFS VM、系统 PowerShell 5.1、外部 TLS MySQL 8/Redis 7，跑完 F01-F16，不以开发机目录模拟替代 |

## 6. 必须接受的 AI 工具承诺

| 承诺 | 接受含义 |
| --- | --- |
| AI 工具使用方式已分层定稿 | 接受外部 AI Coding 工具、平台 AI 工作台、模型网关和生产业务 AI 的分工；不再把“如何使用 AI 工具”作为未定问题悬空 |
| 首版不替代 Codex/Cursor/Claude Code | 外部 AI Coding 工具是开发模式真实源码修改主路径 |
| 平台 AI 工作台是产品化入口 | 面向企业用户做需求澄清、计划、风险、元模型和验证摘要 |
| AI 工具责任边界必须清晰 | 企业用户确认业务，平台组织上下文和交接包，实施人员/开发者使用外部 AI Coding 工具，生产用户只使用业务 AI |
| 平台必须提供 AI 使用引导 | 首次使用路径、阅读顺序、任务单、验证命令和失败处理不能留给用户自行摸索 |
| 工作台必须能输出外部 AI 交接包 | 交接包包含阶段、目标、范围、禁止事项、风险、验证命令和输出格式 |
| AI 任务必须有准入卡结论 | 每次交给 AI 前必须以 `admissionCard` 确认编码许可、任务阶段、执行入口、上下文、风险、验证和生产边界 |
| S1 开工前必须有持久化准入和结构化检查 | 精确口令后先写 **docs/stage-records/S1-admission.md**，再确认签收、口令、准入路径、目录基线、范围和 `admissionCard.result` |
| S1 完成时必须有关闭证据包 | S1 输出摘要必须记录交付物、验证结果、越界检查、文档同步、残余风险和下一阶段请求；不得自动授权 S2 |
| 企业用户不会 AI Coding 工具时有托底路径 | 企业用户先用工作台表达业务，实施人员/开发者再使用外部 AI Coding 工具执行工程动作 |
| 企业用户不必懂源码 | 企业用户确认业务和风险，源码修改可由实施人员或开发者使用外部 AI 工具完成 |
| 生产只保留业务 AI | 生产不允许开发型 AI 改源码、执行脚本、改数据库结构 |
| 生产 AI 必须使用白名单 | 生产模型配置只允许业务问答、摘要、分类、文案、分析和连接测试 |
| 模型数据与出站安全必须可解释 | 模型调用前必须完成数据分类、最小化、脱敏、数据权限过滤和出境风险提示；API Base 必须阻断私网/metadata、重定向、无效 TLS 和超大响应 |
| 代码补丁只限开发工作区 | P0 通用补丁由外部 AI Coding 工具承接，确定性生成器只写 owned 路径；P1 本地执行器需另立 ADR，生产始终禁止 |
| 外部 AI 交接包不是生产执行脚本 | 交接包只用于开发和实施协作，不能在生产服务器直接执行补丁、SQL 或 shell |
| 外部 AI 交接包不是编码授权书 | 交接包不能绕过签收状态、阶段启动口令、允许范围和质量门禁 |
| 生产发布不能走旁路 | 不复制源码上线，不复制开发库上线，不执行交接包、补丁、临时 SQL 或 shell 作为发布方式 |
| 所有 AI 先读文档 | `docs/README.md` 是默认入口 |
| 生成代码必须验证 | Maven、npm、脚本或未验证原因必须记录 |

签收时必须特别确认以下 AI 使用取舍。若任何一项不接受，不能直接进入 S1 编码，应先回到 ADR-0003、AI 工具策略或使用指南修订。

| 取舍问题 | 签收口径 |
| --- | --- |
| AI 工具使用方式是否仍未确定 | 否，文档口径已分层定稿；如要改变，先修订 ADR-0003、AI 策略、使用指南、冻结清单和本文 |
| 平台是否首版自研完整 AI IDE | 否，P0 适配外部 AI Coding 工具 |
| 企业用户是否必须直接操作外部 AI Coding 工具 | 否，企业用户主要通过平台 AI 工作台确认业务和风险 |
| 企业用户不会 AI Coding 工具时是否可以继续 | 可以，平台工作台负责需求、澄清、计划和交接包，实施人员/开发者负责工程执行 |
| 实施人员是否可以作为 AI 工具桥接角色 | 是，实施人员可把工作台交接包交给外部 AI Coding 工具执行 |
| 生产用户是否可以因为已配置模型而触发开发动作 | 否，生产模型配置只代表业务 AI 可用，不代表允许代码修改、脚本执行或数据库结构变更 |
| 平台 AI 工作台是否可以退化成普通 Chat | 否，必须沉淀需求、上下文、计划、风险、交接包和验证摘要 |
| 交接包是否可以作为生产执行脚本 | 否，只能作为开发和实施协作材料 |
| 交接包是否可以作为编码授权书 | 否，必须同时满足签收、启动口令、允许范围和质量门禁 |
| 生产是否允许开发型 AI | 否，生产只允许受控业务 AI |
| 生产模型配置是否可以开启任意 AI 能力 | 否，只允许业务问答、摘要、分类、文案、分析和连接测试 |
| 企业业务数据是否可以默认进入模型上下文 | 否，必须先分类、最小化、脱敏；secret 数据禁止进入模型上下文 |
| 境外或未知模型供应商是否可以静默使用 | 否，必须有中文出境风险提示和确认 |
| 生产发布是否可以复制源码、开发库或手工 SQL | 否，必须走受控安装包、安装/升级脚本和版本化迁移 |

## 6.1 必须接受的文档收束承诺

签收前可以继续修订文档，但不应再通过不断新增文档来回避产品和技术取舍。

| 承诺 | 接受含义 |
| --- | --- |
| 后续优先修订已有文档 | 需求澄清、检查结果、读者测试和签收项默认合并到现有文档 |
| 新增文档必须有独立价值 | 只有新的决策源、证据链或验收入口才允许新增 |
| 文档新增必须同步索引和准入项 | 新增文档后必须同步 README、冻结清单、签收记录和相关审计 |
| AI 工具使用模型已随签收冻结 | 不再把首版重新解释为完整 AI IDE、生产 Agent 或普通 Chat 外壳 |

## 7. S1 启动承诺

签收后，S1 只允许做以下事情。

`docs/s1-implementation-work-order.md` 是施工说明，不是授权文件。只有 `docs/coding-start-signoff.md` 已签收，且维护者明确说出启动口令后，才允许依据 S1 工作令创建源码目录。

即使签收记录和启动口令都满足，创建任何源码目录前仍必须先输出 S1 开工检查。检查失败时不得继续编码，只能输出失败字段、原因、应修订文档和下一步签收建议。

| 开工检查字段 | 必须结论 |
| --- | --- |
| `signoffStatus` | `已签收` |
| `s1Allowed` | `是` |
| `launchPhraseExact` | `true`，且精确口令为 `开始 S1 工程骨架编码` |
| `sourceDirsBefore` | `none`，或说明目录来自已授权 S1 变更 |
| `allowedScope` | S1 工程骨架 |
| `forbiddenScope` | S2-S7、P2/P2+ 模块、冻结外依赖和生产安装包 |
| `admissionCard.result` | `pass` |

S1 完成时还必须提交阶段关闭证据包。关闭证据包通过只表示 S1 可以申请关闭，不表示 S2 已启动。

| 关闭证据 | 要求 |
| --- | --- |
| 交付物清单 | 对照 `docs/s1-task-breakdown.md` 标记完成、失败、跳过或不适用 |
| 验证结果 | 记录后端快速构建、前端构建、`scripts/doctor.ps1` 等命令状态或未执行原因 |
| 越界检查 | 明确未提前实现 S2-S7、P2/P2+ 模块或冻结外依赖 |
| 文档同步 | 说明 README、任务分解、质量门禁或签收材料是否已同步 |
| 残余风险 | 说明环境、依赖、脚本、未执行验证或人工复核项 |
| 下一阶段请求 | 只能申请进入 S2，不得写成已授权 S2 |

| 允许 | 说明 |
| --- | --- |
| 创建 `backend/` Maven 多模块 | 只搭骨架和最小启动 |
| 创建 P0 后端模块 | `vibe-common`、`vibe-security`、`vibe-system`、`vibe-ai`、`vibe-skill`、`vibe-gen`、`vibe-file`、`vibe-starter` |
| 创建 `frontend/` Vue 工程 | 只保证基础结构和构建 |
| 创建 `scripts/` 开发脚本骨架 | `common.ps1`、`doctor.ps1`、`dev-start.ps1`、`dev-stop.ps1` |
| 创建 `config/*.example` | 不提交真实密钥 |
| 更新根 README 和忽略规则 | 指向文档入口和验证命令 |

S1 仍禁止：

| 禁止 | 原因 |
| --- | --- |
| 登录、用户、角色、菜单 | S2 |
| 模型调用、模型配置管理 | S3 |
| AI 工作台、代码生成模板 | S4 |
| 客户拜访记录模块 | S4/S7 |
| 生产安装包、备份恢复 | S6 |
| `vibe-job` | 当前不进入 S1 |
| `vibe-workflow`、`vibe-report`、`vibe-message`、`vibe-integration` | P2/P2+ 预留 |

## 8. 编码后变更承诺

签收后新增请求按 C0-C4 处理。C0 不是未签收或未启动状态下的编码许可，只有在对应阶段已签收、维护者已发出阶段启动指令、且请求完全落在该阶段任务文档内时才成立。任何补丁应用、文件写入或外部 AI 交接包执行，都必须继续遵守开发工作区边界和生产禁用开发型 AI 的安全底线。

| 级别 | 处理 |
| --- | --- |
| C0 已授权小实现 | 阶段签收和启动指令均满足后，才可直接实现并验证 |
| C1 文档同步 | 可直接修订文档并同步索引 |
| C2 范围边界变化 | 暂停编码，先修订路线图、任务分解和冻结清单 |
| C3 技术决策变化 | 暂停编码，先新增或修订 ADR |
| C4 安全/生产高风险 | 默认拒绝，除非重新设计并完成安全审计 |

任何“顺便做一下”的请求，都必须先判断级别。

质量门禁不能替代变更分级。即使构建、测试或脚本验证通过，只要请求属于 C2-C4，仍然必须暂停编码并按上表回到文档、ADR 或安全设计。

## 9. 签收动作

如果维护者接受本文全部承诺，应更新 `docs/coding-start-signoff.md`：

| 项目 | 更新要求 |
| --- | --- |
| 签收结论 | 改为已签收 |
| 是否允许开始 S1 编码 | 改为是 |
| 签收人 | 填写姓名或账号 |
| 签收日期 | 填写日期 |
| 签收基线 | 填写提交哈希；若签收未提交工作区，则填写 manifest 生成时间、`ManifestFiles` 数量、纳入范围和 manifest 输出保存位置 |
| 最终审查表 | 明确填写已确认第 3.2 节全部审查域 |
| 第 4 节当前记录 | 全部改为已签收 |

推荐以 `docs/coding-start-signoff.md` 文件记录作为唯一签收动作。如果维护者选择在协作记录中做等价确认，必须明确包含：接受本文全部承诺、只启动 S1 工程骨架、第 3.2 节最终审查表全部确认、第 4 节全部签收项均接受、签收人、签收日期、签收基线。缺少任一项时，不视为完成签收。

以下表达不能视为签收：

| 表达 | 原因 |
| --- | --- |
| “同意” | 没有确认全部承诺和签收项 |
| “可以开始” | 没有确认 S1 范围、签收人和日期 |
| “按文档做” | 没有确认签收包已接受 |
| “开始 S1 工程骨架编码” | 只是签收完成后的启动口令，不是签收动作 |

完成以上更新后，仍需要维护者明确说出启动口令。启动口令必须使用下方文本，不带句号、冒号或额外后缀：

```text
开始 S1 工程骨架编码
```

没有签收记录和启动口令，外部 AI Coding 工具不得创建源码目录。

## 10. 拒绝签收时的处理

| 不接受项 | 处理 |
| --- | --- |
| 不接受产品范围 | 先更新 `docs/product-constraints.md` 或 `docs/mvp-roadmap.md` |
| 不接受技术栈 | 先更新 ADR |
| 不接受 AI 工具边界 | 先更新 ADR-0003、AI 工具策略和使用指南 |
| 不接受模型数据安全边界 | 先更新 `docs/security-governance.md`、`docs/model-gateway-spec.md` 和质量门禁 |
| 不接受开源合规边界 | 先更新 `docs/product-constraints.md`、`docs/windows-devkit-design.md`、`docs/release-package-design.md` 和质量门禁 |
| 不接受 S1 起步范围 | 先更新 S1 工作令、工程骨架规格和任务分解 |
| 不接受变更控制 | 先更新 `docs/post-coding-change-control.md` 和冻结清单 |

## 11. 一句话总结

这份签收包的意思是：如果接受，就只开 S1 工程骨架这一扇小门；如果不接受，就继续修订文档，而不是带着分歧开始编码。
