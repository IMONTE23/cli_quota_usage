# Automated installer for Antigravity CLI Custom Statusline
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$targetDir = Join-Path $HOME ".gemini\antigravity-cli"
$targetScript = Join-Path $targetDir "statusline.ps1"
$targetSettings = Join-Path $targetDir "settings.json"

Write-Host "==> Installing Antigravity CLI Custom Statusline..." -ForegroundColor Cyan

# 1. Ensure target directory exists
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Write-Host "Created directory: $targetDir" -ForegroundColor Green
}

# 2. Copy script
$sourceScript = Join-Path $PSScriptRoot "statusline.ps1"
if (-not (Test-Path $sourceScript)) {
    Write-Error "Source script '$sourceScript' not found."
    exit 1
}
Copy-Item -Path $sourceScript -Destination $targetScript -Force
Write-Host "Copied script to: $targetScript" -ForegroundColor Green

# 3. Update or create settings.json
$normalizedScriptPath = ($targetScript -replace '\\', '/')
$statusLineConfig = @{
    "type"               = "command"
    "command"            = "powershell -NoProfile -ExecutionPolicy Bypass -File $normalizedScriptPath"
    "enabled"            = $true
    "stack_with_default" = $true
}

$settingsObj = [ordered]@{}
if (Test-Path $targetSettings) {
    try {
        $raw = Get-Content -Raw -Path $targetSettings -Encoding UTF8
        if (-not [string]::IsNullOrWhiteSpace($raw)) {
            $settingsObj = $raw | ConvertFrom-Json -AsHashtable
        }
    } catch {
        Write-Warning "Could not parse existing settings.json. Backing up and creating new configuration."
        Copy-Item -Path $targetSettings -Destination "$targetSettings.bak" -Force
    }
}

$settingsObj["statusLine"] = $statusLineConfig
$newJson = $settingsObj | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($targetSettings, $newJson, [System.Text.Encoding]::UTF8)
Write-Host "Updated configuration: $targetSettings" -ForegroundColor Green

Write-Host "`nInstallation completed successfully!" -ForegroundColor Green
Write-Host "Launch 'agy' in your terminal to see the statusline in action." -ForegroundColor Cyan
