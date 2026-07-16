param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$MavenArgs
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

try {
    $javaHome = Set-VibeJavaEnvironment
    $mavenCommand = Get-VibeMavenCommand
    $mavenVersion = Get-VibeMavenVersion $mavenCommand
    if ($mavenVersion -notmatch '^3\.8\.') {
        throw "检测到 Maven $mavenVersion；Vibe Boot S1 只允许 Maven 3.8.x。"
    }

    $settingsPath = Join-Path $script:VibeBootBackend '.mvn\settings.xml'
    if (-not (Test-Path -LiteralPath $settingsPath -PathType Leaf)) {
        throw "缺少受控 Maven 配置：$settingsPath"
    }

    Write-VibeSuccess "使用 JDK：$javaHome"
    Write-VibeSuccess "使用 Maven：$mavenVersion"
    Write-VibeSuccess '使用镜像：vibe-boot-aliyun'

    Push-Location $script:VibeBootBackend
    try {
        & $mavenCommand -s $settingsPath @MavenArgs
        $exitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }
    exit $exitCode
} catch {
    Write-VibeFailure $_.Exception.Message
    exit 1
}
