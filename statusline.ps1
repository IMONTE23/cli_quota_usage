[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$inputJson = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($inputJson)) { exit 0 }

try {
    $data = $inputJson | ConvertFrom-Json
} catch {
    exit 0
}

# Terminal width and ANSI color setup
$termWidth = if ($null -ne $data.terminal_width -and [int]$data.terminal_width -gt 0) { [int]$data.terminal_width } else { 120 }
$barWidth = if ($termWidth -ge 120) { 5 } else { 4 }
$showResetTime = ($termWidth -ge 130)

$esc = [char]27
$cReset  = "$esc[0m"
$cBold   = "$esc[1m"
$cDim    = "$esc[90m"
$cCyan   = "$esc[1;36m"
$cGreen  = "$esc[92m"
$cYellow = "$esc[93m"
$cRed    = "$esc[91m"

function Format-Bar([double]$frac, [int]$width) {
    $filled = [int][math]::Round($frac * $width)
    if ($frac -gt 0 -and $filled -eq 0) { $filled = 1 }
    $empty = $width - $filled
    
    $color = if ($frac -ge 0.5) { $cGreen } elseif ($frac -ge 0.2) { $cYellow } else { $cRed }
    $bar = ([string]::new([char]0x2588, $filled)) + $cDim + ([string]::new([char]0x2591, $empty)) + $cReset
    return "${color}[${bar}${color}]${cReset}"
}

function Format-Time([int]$sec) {
    if ($sec -le 0) { return "0m" }
    $h = [math]::Floor($sec / 3600)
    $m = [math]::Floor(($sec % 3600) / 60)
    if ($h -ge 24) {
        $d = [math]::Round($h / 24, 1)
        return "${d}d"
    }
    if ($h -gt 0) { return "${h}h" }
    return "${m}m"
}

# Group quotas by model family
$models = [ordered]@{
    "Gemini" = [ordered]@{}
    "Argon"  = [ordered]@{}
    "Claude" = [ordered]@{}
}

if ($null -ne $data.quota) {
    foreach ($prop in $data.quota.PSObject.Properties) {
        $k = $prop.Name
        $val = $prop.Value
        if ($k -match '^gemini-argon') {
            $win = if ($k -match '5h') { "5h" } elseif ($k -match 'weekly') { "Wk" } else { $k }
            $models["Argon"][$win] = $val
        } elseif ($k -match '^gemini') {
            $win = if ($k -match '5h') { "5h" } elseif ($k -match 'weekly') { "Wk" } else { $k }
            $models["Gemini"][$win] = $val
        } elseif ($k -match '^(3p|claude)') {
            $win = if ($k -match '5h') { "5h" } elseif ($k -match 'weekly') { "Wk" } else { $k }
            $models["Claude"][$win] = $val
        } else {
            $prefix = ($k -split '-')[0]
            if (-not $models.Contains($prefix)) { $models[$prefix] = [ordered]@{} }
            $models[$prefix][$k] = $val
        }
    }
}

$activeModel = if ($null -ne $data.model.display_name) { $data.model.display_name } else { "" }

$modelOutputs = @()
foreach ($mName in $models.Keys) {
    $buckets = $models[$mName]
    if ($buckets.Count -eq 0) { continue }
    
    $isActive = $false
    if ($mName -eq "Argon" -and $activeModel -match "Argon") { $isActive = $true }
    elseif ($mName -eq "Gemini" -and $activeModel -match "Gemini" -and $activeModel -notmatch "Argon") { $isActive = $true }
    elseif ($mName -eq "Claude" -and ($activeModel -match "Claude" -or $activeModel -match "3p")) { $isActive = $true }
    
    $badge = if ($isActive) { "${cCyan}*[$mName]*${cReset}" } else { "${cBold}[$mName]${cReset}" }
    
    $partList = @()
    foreach ($w in $buckets.Keys) {
        $info = $buckets[$w]
        $frac = if ($null -ne $info.remaining_fraction) { [math]::Max(0.0, [math]::Min(1.0, [double]$info.remaining_fraction)) } else { 0.0 }
        $pct = [int][math]::Round($frac * 100)
        $bar = Format-Bar $frac $barWidth
        
        $pctColor = if ($frac -ge 0.5) { $cGreen } elseif ($frac -ge 0.2) { $cYellow } else { $cRed }
        $pctStr = "${pctColor}${pct}%${cReset}"

        if ($showResetTime) {
            $resetStr = Format-Time ([int]$info.reset_in_seconds)
            $partList += "${w}:${bar} ${pctStr} ${cDim}(${resetStr})${cReset}"
        } else {
            $partList += "${w}:${bar} ${pctStr}"
        }
    }
    
    $modelOutputs += "${badge} " + ($partList -join "  ")
}

if ($modelOutputs.Count -eq 0) {
    Write-Output "Quota: N/A"
} else {
    Write-Output ($modelOutputs -join "  ${cDim}|${cReset}  ")
}
