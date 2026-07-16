$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$results = New-Object System.Collections.Generic.List[object]
$requiredFailure = $false

function Add-DoctorResult {
    param(
        [Parameter(Mandatory = $true)][string]$Item,
        [Parameter(Mandatory = $true)][ValidateSet('PASS', 'WARN', 'FAIL')][string]$Status,
        [Parameter(Mandatory = $true)][string]$Detail,
        [bool]$Required = $false
    )
    [void]$results.Add([pscustomobject]@{
        检查项 = $Item
        状态 = $Status
        说明 = $Detail
    })
    if ($Required -and $Status -eq 'FAIL') {
        $script:requiredFailure = $true
    }
}

Write-VibeSection 'Vibe Boot 开发环境诊断'

try {
    $javaHome = Set-VibeJavaEnvironment
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $javaOutput = @(& (Join-Path $javaHome 'bin\java.exe') -version 2>&1)
        $javaExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($javaExitCode -ne 0) {
        throw ('JDK 版本检查失败：' + ($javaOutput -join ' '))
    }
    $javaLine = "$($javaOutput[0])"
    if ($javaLine -match 'version "17\.') {
        Add-DoctorResult 'JDK' 'PASS' "$javaLine；$javaHome" $true
    } else {
        Add-DoctorResult 'JDK' 'FAIL' "需要 JDK 17，当前为 $javaLine" $true
    }
} catch {
    Add-DoctorResult 'JDK' 'FAIL' $_.Exception.Message $true
}

try {
    $mavenCommand = Get-VibeMavenCommand
    $mavenVersion = Get-VibeMavenVersion $mavenCommand
    if ($mavenVersion -match '^3\.8\.') {
        Add-DoctorResult 'Maven' 'PASS' "$mavenVersion；$mavenCommand" $true
    } else {
        Add-DoctorResult 'Maven' 'FAIL' "需要 Maven 3.8.x，当前为 $mavenVersion" $true
    }
} catch {
    Add-DoctorResult 'Maven' 'FAIL' $_.Exception.Message $true
}

try {
    $nodeRuntime = Set-VibeNodeEnvironment
    $nodeText = (& $nodeRuntime.NodePath --version).Trim().TrimStart('v')
    $nodeVersion = [Version]$nodeText
    if ($nodeVersion -ge [Version]'24.18.0' -and $nodeVersion -lt [Version]'25.0.0') {
        Add-DoctorResult 'Node.js' 'PASS' "$nodeText；$($nodeRuntime.NodePath)" $true
    } else {
        Add-DoctorResult 'Node.js' 'FAIL' "需要 >=24.18.0 <25，当前为 $nodeText" $true
    }

    $npmVersion = (& $nodeRuntime.NpmPath --version).Trim()
    if ($LASTEXITCODE -eq 0) {
        Add-DoctorResult 'npm' 'PASS' "$npmVersion；$($nodeRuntime.NpmPath)" $true
    } else {
        Add-DoctorResult 'npm' 'FAIL' 'npm 版本检查失败。' $true
    }
} catch {
    Add-DoctorResult 'Node.js/npm' 'FAIL' $_.Exception.Message $true
}

try {
    [xml]$settings = Get-Content -LiteralPath (Join-Path $script:VibeBootBackend '.mvn\settings.xml') -Raw -Encoding UTF8
    $mirror = $settings.settings.mirrors.mirror | Where-Object { $_.id -eq 'vibe-boot-aliyun' } | Select-Object -First 1
    if ($null -ne $mirror -and $mirror.mirrorOf -eq 'central' -and $mirror.url -eq 'https://maven.aliyun.com/repository/public') {
        Add-DoctorResult 'Maven 国内镜像' 'PASS' 'vibe-boot-aliyun -> maven.aliyun.com' $true
    } else {
        Add-DoctorResult 'Maven 国内镜像' 'FAIL' '项目 settings 与冻结配置不一致。' $true
    }
} catch {
    Add-DoctorResult 'Maven 国内镜像' 'FAIL' $_.Exception.Message $true
}

$npmrcPath = Join-Path $script:VibeBootFrontend '.npmrc'
if ((Test-Path -LiteralPath $npmrcPath) -and
    ((Get-Content -LiteralPath $npmrcPath -Raw -Encoding UTF8) -match 'registry=https://registry\.npmmirror\.com/')) {
    Add-DoctorResult 'npm 国内镜像' 'PASS' 'registry.npmmirror.com' $true
} else {
    Add-DoctorResult 'npm 国内镜像' 'FAIL' 'frontend/.npmrc 缺少冻结镜像。' $true
}

try {
    $npmCliPath = Join-Path $nodeRuntime.Home 'node_modules\npm\bin\npm-cli.js'
    $configuredProxies = New-Object System.Collections.Generic.List[string]
    foreach ($configName in @('proxy', 'https-proxy')) {
        $configValue = (& $nodeRuntime.NodePath $npmCliPath config get $configName).Trim()
        if (-not [string]::IsNullOrWhiteSpace($configValue) -and $configValue -ne 'null' -and $configValue -ne 'undefined') {
            [void]$configuredProxies.Add($configValue)
        }
    }

    $unavailableLocalProxy = $null
    foreach ($proxyValue in ($configuredProxies | Select-Object -Unique)) {
        $proxyUri = [Uri]$proxyValue
        $proxyPort = $proxyUri.Port
        if ($proxyPort -le 0) {
            $proxyPort = if ($proxyUri.Scheme -eq 'https') { 443 } else { 80 }
        }
        if ($proxyUri.Host -in @('127.0.0.1', 'localhost', '::1') -and
            -not (Test-VibePortListening $proxyUri.Host $proxyPort)) {
            $unavailableLocalProxy = $proxyValue
            break
        }
    }

    if ($null -ne $unavailableLocalProxy) {
        Add-DoctorResult 'npm 代理' 'FAIL' "本地代理不可达：$unavailableLocalProxy；启动代理或设置 VIBE_NPM_DIRECT=1。" $true
    } elseif ($configuredProxies.Count -gt 0) {
        Add-DoctorResult 'npm 代理' 'WARN' ('已配置代理：' + (($configuredProxies | Select-Object -Unique) -join ', '))
    } else {
        Add-DoctorResult 'npm 代理' 'PASS' '未配置额外代理，直接使用项目国内镜像。'
    }
} catch {
    Add-DoctorResult 'npm 代理' 'FAIL' ('代理配置检查失败：' + $_.Exception.Message) $true
}

foreach ($port in @(8080, 8081, 5173)) {
    if (Test-VibePortListening '127.0.0.1' $port) {
        Add-DoctorResult "端口 $port" 'WARN' '端口已占用；如非 Vibe Boot 进程，请先释放。'
    } else {
        Add-DoctorResult "端口 $port" 'PASS' '端口可用。'
    }
}

if (Test-VibePortListening '127.0.0.1' 3306) {
    Add-DoctorResult 'MySQL 8' 'PASS' '127.0.0.1:3306 可连接；S1 不读取数据库。'
} else {
    Add-DoctorResult 'MySQL 8' 'WARN' '未检测到本机 3306；S1 可继续，S2 前需准备外部 MySQL 8。'
}

if (Test-VibePortListening '127.0.0.1' 6379) {
    Add-DoctorResult 'Redis' 'PASS' '127.0.0.1:6379 可连接；S1 不读取 Redis。'
} else {
    Add-DoctorResult 'Redis' 'WARN' '未检测到本机 6379；S1 可继续，生产阶段需外部 Redis。'
}

$probePath = Join-Path $script:VibeBootRoot ('.vibe-write-test-' + $PID + '.tmp')
try {
    [System.IO.File]::WriteAllText($probePath, 'vibe-boot')
    Remove-Item -LiteralPath $probePath -Force
    Add-DoctorResult '项目目录权限' 'PASS' '项目根目录可写。' $true
} catch {
    Add-DoctorResult '项目目录权限' 'FAIL' $_.Exception.Message $true
}

$aiGuide = Join-Path $script:VibeBootRoot 'docs\ai-tool-usage-guide.md'
if (Test-Path -LiteralPath $aiGuide -PathType Leaf) {
    Add-DoctorResult 'AI 使用指南' 'PASS' 'docs/ai-tool-usage-guide.md'
} else {
    Add-DoctorResult 'AI 使用指南' 'FAIL' '缺少 AI 使用入口文档。' $true
}

$results | Format-Table -AutoSize
Write-Host 'AI 接入与外部 AI 交接边界请阅读 docs/ai-tool-usage-guide.md。'

if ($requiredFailure) {
    Write-VibeFailure '必需环境检查未通过，请按上表修复后重试。'
    exit 1
}

Write-VibeSuccess 'S1 必需环境检查通过。'
exit 0
