$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

Write-VibeSection '停止 Vibe Boot 开发模式'

$stopped = 0
foreach ($name in @('frontend', 'backend')) {
    try {
        if (Stop-VibeTrackedProcess $name) {
            $stopped++
        }
    } catch {
        Write-VibeFailure "$name 停止失败：$($_.Exception.Message)"
        exit 1
    }
}

if ($stopped -eq 0) {
    Write-VibeWarning '没有由 dev-start.ps1 启动的进程需要停止。'
} else {
    Write-VibeSuccess "开发模式已停止，共处理 $stopped 个进程。"
}
