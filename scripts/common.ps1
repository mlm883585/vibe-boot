Set-StrictMode -Version 2.0

$script:VibeBootRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$script:VibeBootBackend = Join-Path $script:VibeBootRoot 'backend'
$script:VibeBootFrontend = Join-Path $script:VibeBootRoot 'frontend'
$script:VibeBootRuntime = Join-Path $script:VibeBootRoot 'runtime'
$script:VibeBootLogs = Join-Path $script:VibeBootRoot 'logs'

try {
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [Console]::OutputEncoding = $utf8
    $global:OutputEncoding = $utf8
} catch {
    # 某些受限终端不允许修改编码，脚本仍可继续输出。
}

function Write-VibeSection {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "`n== $Message ==" -ForegroundColor Cyan
}

function Write-VibeSuccess {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[通过] $Message" -ForegroundColor Green
}

function Write-VibeWarning {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[提示] $Message" -ForegroundColor Yellow
}

function Write-VibeFailure {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[失败] $Message" -ForegroundColor Red
}

function New-VibeDirectory {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Get-VibeJavaHome {
    $candidates = New-Object System.Collections.Generic.List[string]
    $runtimeHome = Join-Path $script:VibeBootRuntime 'jdk'
    if (Test-Path -LiteralPath (Join-Path $runtimeHome 'bin\java.exe')) {
        [void]$candidates.Add($runtimeHome)
    }
    if (-not [string]::IsNullOrWhiteSpace($env:VIBE_JAVA_HOME)) {
        [void]$candidates.Add($env:VIBE_JAVA_HOME)
    }
    if (-not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
        [void]$candidates.Add($env:JAVA_HOME)
    }

    $javaCommand = Get-Command java.exe -ErrorAction SilentlyContinue
    if ($null -ne $javaCommand -and -not [string]::IsNullOrWhiteSpace($javaCommand.Source)) {
        [void]$candidates.Add((Split-Path -Parent (Split-Path -Parent $javaCommand.Source)))
    }

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        $resolved = [System.IO.Path]::GetFullPath($candidate)
        if ((Test-Path -LiteralPath (Join-Path $resolved 'bin\java.exe')) -and
            (Test-Path -LiteralPath (Join-Path $resolved 'bin\javac.exe'))) {
            return $resolved
        }
    }

    throw '未找到完整 JDK。请准备 runtime\jdk，或设置 VIBE_JAVA_HOME/JAVA_HOME。'
}

function Set-VibeJavaEnvironment {
    $javaHome = Get-VibeJavaHome
    $javaBin = Join-Path $javaHome 'bin'
    $env:JAVA_HOME = $javaHome
    if (-not $env:Path.StartsWith($javaBin, [System.StringComparison]::OrdinalIgnoreCase)) {
        $env:Path = $javaBin + [System.IO.Path]::PathSeparator + $env:Path
    }
    return $javaHome
}

function Get-VibeMavenCommand {
    $candidates = New-Object System.Collections.Generic.List[string]
    [void]$candidates.Add((Join-Path $script:VibeBootRuntime 'maven\bin\mvn.cmd'))
    if (-not [string]::IsNullOrWhiteSpace($env:VIBE_MAVEN_HOME)) {
        [void]$candidates.Add((Join-Path $env:VIBE_MAVEN_HOME 'bin\mvn.cmd'))
    }

    $mavenCommand = Get-Command mvn.cmd -ErrorAction SilentlyContinue
    if ($null -ne $mavenCommand -and -not [string]::IsNullOrWhiteSpace($mavenCommand.Source)) {
        [void]$candidates.Add($mavenCommand.Source)
    }

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    throw '未找到 Maven。请准备 runtime\maven，或设置 VIBE_MAVEN_HOME/PATH。'
}

function Get-VibeMavenVersion {
    param([Parameter(Mandatory = $true)][string]$MavenCommand)
    $output = @(& $MavenCommand -version 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw ('Maven 版本检查失败：' + ($output -join ' '))
    }
    $versionLine = $output | Where-Object { "$_" -match '^Apache Maven\s+([0-9]+\.[0-9]+\.[0-9]+)' } | Select-Object -First 1
    if ($null -eq $versionLine) {
        throw '无法识别 Maven 版本输出。'
    }
    [void]("$versionLine" -match '^Apache Maven\s+([0-9]+\.[0-9]+\.[0-9]+)')
    return $Matches[1]
}

function Get-VibeNodeRuntime {
    $homes = New-Object System.Collections.Generic.List[string]
    $runtimeHome = Join-Path $script:VibeBootRuntime 'node'
    if (Test-Path -LiteralPath (Join-Path $runtimeHome 'node.exe')) {
        [void]$homes.Add($runtimeHome)
    }
    if (-not [string]::IsNullOrWhiteSpace($env:VIBE_NODE_HOME)) {
        [void]$homes.Add($env:VIBE_NODE_HOME)
    }

    $nodeCommand = Get-Command node.exe -ErrorAction SilentlyContinue
    if ($null -ne $nodeCommand -and -not [string]::IsNullOrWhiteSpace($nodeCommand.Source)) {
        [void]$homes.Add((Split-Path -Parent $nodeCommand.Source))
    }

    foreach ($candidateHome in ($homes | Select-Object -Unique)) {
        $resolved = [System.IO.Path]::GetFullPath($candidateHome)
        $nodePath = Join-Path $resolved 'node.exe'
        $npmPath = Join-Path $resolved 'npm.cmd'
        if ((Test-Path -LiteralPath $nodePath -PathType Leaf) -and
            (Test-Path -LiteralPath $npmPath -PathType Leaf)) {
            return [pscustomobject]@{
                Home = $resolved
                NodePath = $nodePath
                NpmPath = $npmPath
            }
        }
    }

    throw '未找到 Node.js/npm。请准备 runtime\node，或设置 VIBE_NODE_HOME/PATH。'
}

function Set-VibeNodeEnvironment {
    $runtime = Get-VibeNodeRuntime
    if (-not $env:Path.StartsWith($runtime.Home, [System.StringComparison]::OrdinalIgnoreCase)) {
        $env:Path = $runtime.Home + [System.IO.Path]::PathSeparator + $env:Path
    }
    if ($env:VIBE_NPM_DIRECT -eq '1') {
        $env:npm_config_proxy = 'null'
        $env:npm_config_https_proxy = 'null'
    }
    if ([string]::IsNullOrWhiteSpace($env:NODE_OPTIONS)) {
        $env:NODE_OPTIONS = '--dns-result-order=ipv4first'
    } elseif ($env:NODE_OPTIONS -notmatch '(?:^|\s)--dns-result-order=') {
        $env:NODE_OPTIONS = $env:NODE_OPTIONS + ' --dns-result-order=ipv4first'
    }
    return $runtime
}

function Test-VibePortListening {
    param(
        [Parameter(Mandatory = $true)][string]$HostName,
        [Parameter(Mandatory = $true)][int]$Port,
        [int]$TimeoutMs = 300
    )

    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect($HostName, $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) {
            return $false
        }
        $client.EndConnect($async)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

function Wait-VibeHttp {
    param(
        [Parameter(Mandatory = $true)][string]$Uri,
        [int]$TimeoutSeconds = 60
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        try {
            $response = Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec 2
            if ($response.StatusCode -eq 200) {
                return $true
            }
        } catch {
            Start-Sleep -Milliseconds 500
        }
    }
    return $false
}

function Get-VibePidFile {
    param([Parameter(Mandatory = $true)][ValidateSet('backend', 'frontend')][string]$Name)
    return Join-Path (Join-Path $script:VibeBootRuntime 'dev') ($Name + '.pid.json')
}

function Save-VibeProcessRecord {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('backend', 'frontend')][string]$Name,
        [Parameter(Mandatory = $true)][System.Diagnostics.Process]$Process,
        [Parameter(Mandatory = $true)][string]$Executable
    )

    $pidDirectory = Join-Path $script:VibeBootRuntime 'dev'
    New-VibeDirectory $pidDirectory
    $Process.Refresh()
    $record = [ordered]@{
        name = $Name
        pid = $Process.Id
        startedAtUtc = $Process.StartTime.ToUniversalTime().ToString('o')
        executable = $Executable
    }
    $record | ConvertTo-Json | Set-Content -LiteralPath (Get-VibePidFile $Name) -Encoding UTF8
}

function Get-VibeTrackedProcess {
    param([Parameter(Mandatory = $true)][ValidateSet('backend', 'frontend')][string]$Name)
    $pidFile = Get-VibePidFile $Name
    if (-not (Test-Path -LiteralPath $pidFile -PathType Leaf)) {
        return $null
    }

    try {
        $record = Get-Content -LiteralPath $pidFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $process = Get-Process -Id ([int]$record.pid) -ErrorAction Stop
        if (-not [string]::IsNullOrWhiteSpace([string]$record.executable)) {
            $expectedExecutable = [System.IO.Path]::GetFullPath([string]$record.executable)
            if (-not $process.Path.Equals($expectedExecutable, [System.StringComparison]::OrdinalIgnoreCase)) {
                return $null
            }
        }
        $actual = $process.StartTime.ToUniversalTime()
        if ($record.startedAtUtc -is [DateTime]) {
            $expected = ([DateTime]$record.startedAtUtc).ToUniversalTime()
        } else {
            $expected = [DateTimeOffset]::Parse(
                [string]$record.startedAtUtc,
                [System.Globalization.CultureInfo]::InvariantCulture,
                [System.Globalization.DateTimeStyles]::RoundtripKind
            ).UtcDateTime
        }
        if ([Math]::Abs(($actual - $expected).TotalSeconds) -gt 2) {
            return $null
        }
        return $process
    } catch {
        return $null
    }
}

function Remove-VibeProcessRecord {
    param([Parameter(Mandatory = $true)][ValidateSet('backend', 'frontend')][string]$Name)
    $pidFile = Get-VibePidFile $Name
    if (Test-Path -LiteralPath $pidFile -PathType Leaf) {
        Remove-Item -LiteralPath $pidFile -Force
    }
}

function Stop-VibeTrackedProcess {
    param([Parameter(Mandatory = $true)][ValidateSet('backend', 'frontend')][string]$Name)
    $pidFile = Get-VibePidFile $Name
    if (-not (Test-Path -LiteralPath $pidFile -PathType Leaf)) {
        Write-VibeWarning "$Name 未记录为运行状态。"
        return $false
    }

    $process = Get-VibeTrackedProcess $Name
    if ($null -eq $process) {
        Write-VibeWarning "$name 的 PID 记录已失效；为避免误杀，只清理记录。"
        Remove-VibeProcessRecord $Name
        return $false
    }

    Stop-Process -Id $process.Id -Force -ErrorAction Stop
    [void]$process.WaitForExit(10000)
    Remove-VibeProcessRecord $Name
    Write-VibeSuccess "$Name 已停止（PID $($process.Id)）。"
    return $true
}
