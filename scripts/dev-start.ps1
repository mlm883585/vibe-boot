$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

Write-VibeSection '启动 Vibe Boot 开发模式'

foreach ($name in @('backend', 'frontend')) {
    $pidFile = Get-VibePidFile $name
    if ((Test-Path -LiteralPath $pidFile) -and $null -eq (Get-VibeTrackedProcess $name)) {
        Write-VibeWarning "$name 的旧 PID 记录已失效，正在清理。"
        Remove-VibeProcessRecord $name
    }
}

$existingBackend = Get-VibeTrackedProcess 'backend'
$existingFrontend = Get-VibeTrackedProcess 'frontend'
if ($null -ne $existingBackend -and $null -ne $existingFrontend) {
    Write-VibeSuccess "开发模式已运行（后端 PID $($existingBackend.Id)，前端 PID $($existingFrontend.Id)）。"
    Write-Host '前端地址：http://127.0.0.1:5173/'
    Write-Host '健康地址：http://127.0.0.1:8081/actuator/health/readiness'
    exit 0
}
if ($null -ne $existingBackend -or $null -ne $existingFrontend) {
    Write-VibeFailure '检测到仅部分受管进程在运行。请先执行 scripts/dev-stop.ps1，再重新启动。'
    exit 1
}

$occupiedPorts = @(
    foreach ($port in @(8080, 8081, 5173)) {
        if (Test-VibePortListening '127.0.0.1' $port) {
            $port
        }
    }
)
if ($occupiedPorts.Count -gt 0) {
    Write-VibeFailure ('端口已被未受管进程占用：' + ($occupiedPorts -join ', ') + '。为避免影响其他进程，启动已停止。')
    exit 1
}

& (Join-Path $PSScriptRoot 'doctor.ps1')
if ($LASTEXITCODE -ne 0) {
    Write-VibeFailure '环境诊断未通过，开发模式未启动。'
    exit 1
}

Write-VibeSection '构建后端'
& (Join-Path $PSScriptRoot 'mvn.ps1') -pl vibe-starter -am -DskipTests package
if ($LASTEXITCODE -ne 0) {
    Write-VibeFailure '后端构建失败，开发模式未启动。'
    exit 1
}

$nodeRuntime = Set-VibeNodeEnvironment
if (-not (Test-Path -LiteralPath (Join-Path $script:VibeBootFrontend 'node_modules') -PathType Container)) {
    Write-VibeSection '安装前端依赖'
    Push-Location $script:VibeBootFrontend
    try {
        & $nodeRuntime.NpmPath install
        if ($LASTEXITCODE -ne 0) {
            throw 'npm install 失败。'
        }
    } finally {
        Pop-Location
    }
}

$javaHome = Set-VibeJavaEnvironment
$javaPath = Join-Path $javaHome 'bin\java.exe'
$jar = Get-ChildItem -LiteralPath (Join-Path $script:VibeBootBackend 'vibe-starter\target') -Filter 'vibe-starter-*.jar' |
    Where-Object { $_.Name -notlike '*.original' } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if ($null -eq $jar) {
    Write-VibeFailure '未找到 vibe-starter 可执行 Jar。'
    exit 1
}

$logDirectory = Join-Path $script:VibeBootLogs 'dev'
New-VibeDirectory $logDirectory
$backendOut = Join-Path $logDirectory 'backend.out.log'
$backendErr = Join-Path $logDirectory 'backend.err.log'
$frontendOut = Join-Path $logDirectory 'frontend.out.log'
$frontendErr = Join-Path $logDirectory 'frontend.err.log'

try {
    Write-VibeSection '启动后端'
    $backendArgs = @('-jar', ('"' + $jar.FullName + '"'), '--spring.profiles.active=dev')
    $backendProcess = Start-Process -FilePath $javaPath -ArgumentList $backendArgs `
        -WorkingDirectory $script:VibeBootBackend -PassThru -WindowStyle Hidden `
        -RedirectStandardOutput $backendOut -RedirectStandardError $backendErr
    Save-VibeProcessRecord 'backend' $backendProcess $javaPath

    if (-not (Wait-VibeHttp 'http://127.0.0.1:8081/actuator/health/readiness' 60)) {
        throw "后端 readiness 未在 60 秒内就绪，请检查 $backendErr。"
    }
    Write-VibeSuccess "后端已启动（PID $($backendProcess.Id)）。"

    Write-VibeSection '启动前端'
    $viteScript = Join-Path $script:VibeBootFrontend 'node_modules\vite\bin\vite.js'
    if (-not (Test-Path -LiteralPath $viteScript -PathType Leaf)) {
        throw '未找到 Vite 启动脚本，请重新执行 npm install。'
    }
    $frontendArgs = @(('"' + $viteScript + '"'), '--host', '127.0.0.1', '--port', '5173', '--strictPort')
    $frontendProcess = Start-Process -FilePath $nodeRuntime.NodePath -ArgumentList $frontendArgs `
        -WorkingDirectory $script:VibeBootFrontend -PassThru -WindowStyle Hidden `
        -RedirectStandardOutput $frontendOut -RedirectStandardError $frontendErr
    Save-VibeProcessRecord 'frontend' $frontendProcess $nodeRuntime.NodePath

    if (-not (Wait-VibeHttp 'http://127.0.0.1:5173/' 30)) {
        throw "前端未在 30 秒内就绪，请检查 $frontendErr。"
    }
    Write-VibeSuccess "前端已启动（PID $($frontendProcess.Id)）。"
} catch {
    Write-VibeFailure $_.Exception.Message
    foreach ($name in @('frontend', 'backend')) {
        try {
            if (Test-Path -LiteralPath (Get-VibePidFile $name)) {
                [void](Stop-VibeTrackedProcess $name)
            }
        } catch {
            Write-VibeWarning "$name 清理失败：$($_.Exception.Message)"
        }
    }
    exit 1
}

Write-Host ''
Write-VibeSuccess 'Vibe Boot 开发模式启动完成。'
Write-Host '前端地址：http://127.0.0.1:5173/'
Write-Host '后端业务地址：http://127.0.0.1:8080/'
Write-Host '后端健康地址：http://127.0.0.1:8081/actuator/health/readiness'
Write-Host "日志目录：$logDirectory"
