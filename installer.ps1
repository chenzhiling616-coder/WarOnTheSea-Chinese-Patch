# War on the Sea 简体中文补丁 安装器（图形界面）
# 用法：双击「中文补丁安装器.bat」启动图形界面
#       命令行模式：powershell -File installer.ps1 -Action install|restore （供脚本化调用）
param(
    [ValidateSet("gui","install","restore","testui")]
    [string]$Action = "gui"
)
$ErrorActionPreference = "Stop"
$AppId = "1280780"
$PatchSrc = Join-Path $PSScriptRoot "patch\chinese"

# ---------------- 游戏目录定位 ----------------
function Find-GameDir {
    $candidates = @()
    $steamPaths = @()
    foreach ($reg in @("HKCU:\Software\Valve\Steam", "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam")) {
        try {
            $p = (Get-ItemProperty $reg -ErrorAction Stop)
            if ($p.SteamPath) { $steamPaths += $p.SteamPath.Replace("/", "\") }
            if ($p.InstallPath) { $steamPaths += $p.InstallPath }
        } catch {}
    }
    $libs = @()
    foreach ($sp in ($steamPaths | Where-Object { $_ } | Select-Object -Unique)) {
        $vdf = Join-Path $sp "steamapps\libraryfolders.vdf"
        if (Test-Path $vdf) {
            $libs += $sp
            $content = Get-Content $vdf -Raw
            foreach ($m in [regex]::Matches($content, '"path"\s+"([^"]+)"')) {
                $libs += $m.Groups[1].Value.Replace("\\\\", "\").Replace("\\", "\")
            }
        }
    }
    foreach ($lib in ($libs | Select-Object -Unique)) {
        $manifest = Join-Path $lib "steamapps\appmanifest_$AppId.acf"
        if (Test-Path $manifest) {
            $mc = Get-Content $manifest -Raw
            $dirMatch = [regex]::Match($mc, '"installdir"\s+"([^"]+)"')
            if ($dirMatch.Success) {
                $gd = Join-Path $lib ("steamapps\common\" + $dirMatch.Groups[1].Value)
                if (Test-Path $gd) { $candidates += $gd }
            }
        }
    }
    if ($candidates.Count -eq 0) {
        foreach ($drive in (Get-PSDrive -PSProvider FileSystem).Root) {
            foreach ($sub in @("Steam\steamapps\common\War on the Sea", "SteamLibrary\steamapps\common\War on the Sea", "Program Files (x86)\Steam\steamapps\common\War on the Sea")) {
                $gd = Join-Path $drive $sub
                if (Test-Path $gd) { $candidates += $gd }
            }
        }
    }
    foreach ($c in ($candidates | Select-Object -Unique)) {
        if (Test-Path (Join-Path $c "WarOnTheSea_Data\StreamingAssets\default\language\english")) { return $c }
    }
    return $null
}

function Test-GameDir([string]$dir) {
    if (-not $dir) { return $false }
    return (Test-Path (Join-Path $dir "WarOnTheSea_Data\StreamingAssets\default\language\english"))
}

# ---------------- 核心动作 ----------------
# $log 是接收一行文本的脚本块
function Install-Patch([string]$gameDir, [scriptblock]$log) {
    if (-not (Test-Path $PatchSrc)) { & $log "错误：找不到补丁文件目录 patch\chinese，请勿单独移动安装器。"; return $false }
    if (Get-Process -Name "WarOnTheSea" -ErrorAction SilentlyContinue) { & $log "请先关闭正在运行的游戏，再进行操作。"; return $false }
    $sa       = Join-Path $gameDir "WarOnTheSea_Data\StreamingAssets"
    $override = Join-Path $sa "override"

    & $log "正在复制汉化文件（268 个）..."
    New-Item -ItemType Directory -Force (Join-Path $override "language") | Out-Null
    Copy-Item $PatchSrc (Join-Path $override "language\chinese") -Recurse -Force
    & $log "√ 汉化文件已复制到 override\language\chinese"

    $ovrCfg = Join-Path $override "config.txt"
    $defCfg = Join-Path $sa "default\config.txt"
    if (Test-Path $ovrCfg) {
        $bak = "$ovrCfg.zhpatch.bak"
        if (-not (Test-Path $bak)) { Copy-Item $ovrCfg $bak }
        $cfg = [System.IO.File]::ReadAllText($ovrCfg)
        $cfg = [regex]::Replace($cfg, '"language"\s*:\s*"[^"]*"', '"language":"chinese"')
        [System.IO.File]::WriteAllText($ovrCfg, $cfg, (New-Object System.Text.UTF8Encoding $false))
        & $log "√ 已修改现有 override\config.txt 的语言为 chinese（原文件已备份）"
    } else {
        $cfg = [System.IO.File]::ReadAllText($defCfg)
        $cfg = [regex]::Replace($cfg, '"language"\s*:\s*"[^"]*"', '"language":"chinese"')
        [System.IO.File]::WriteAllText($ovrCfg, $cfg, (New-Object System.Text.UTF8Encoding $false))
        & $log "√ 已生成 override\config.txt（语言设为 chinese）"
    }
    & $log ""
    & $log "════════ 汉化完成！启动游戏即为简体中文 ════════"
    & $log "提示：本补丁不修改任何原版文件，游戏更新后依然有效。"
    return $true
}

function Restore-Game([string]$gameDir, [scriptblock]$log) {
    if (Get-Process -Name "WarOnTheSea" -ErrorAction SilentlyContinue) { & $log "请先关闭正在运行的游戏，再进行操作。"; return $false }
    $override = Join-Path $gameDir "WarOnTheSea_Data\StreamingAssets\override"
    $chinese  = Join-Path $override "language\chinese"
    $ovrCfg   = Join-Path $override "config.txt"
    $bak      = "$ovrCfg.zhpatch.bak"
    $bakOld   = "$ovrCfg.中文补丁备份"   # 兼容旧版补丁的备份名
    $did = $false

    if (Test-Path $chinese) {
        Remove-Item $chinese -Recurse -Force
        & $log "√ 已删除汉化语言文件"
        $did = $true
        $langDir = Join-Path $override "language"
        if ((Test-Path $langDir) -and ((Get-ChildItem $langDir -Force | Measure-Object).Count -eq 0)) { Remove-Item $langDir -Force }
    } else {
        & $log "未发现汉化语言文件（可能已还原）。"
    }

    if (Test-Path $bakOld) { Move-Item $bakOld $bak -Force }
    if (Test-Path $bak) {
        Move-Item $bak $ovrCfg -Force
        & $log "√ 已恢复安装前的 override\config.txt（其他 MOD 配置保留）"
        $did = $true
    } elseif (Test-Path $ovrCfg) {
        $cfg = [System.IO.File]::ReadAllText($ovrCfg)
        if ($cfg -match '"language"\s*:\s*"chinese"') {
            Remove-Item $ovrCfg -Force
            & $log "√ 已删除补丁生成的 override\config.txt"
            $did = $true
        } else {
            & $log "override\config.txt 非本补丁生成，保持不动。"
        }
    }

    if ((Test-Path $override) -and ((Get-ChildItem $override -Force | Measure-Object).Count -eq 0)) {
        Remove-Item $override -Force
        & $log "√ 已删除空的 override 目录"
    }
    & $log ""
    if ($did) { & $log "════════ 还原完成，游戏已恢复英文原版 ════════" }
    else      { & $log "游戏本来就是初始状态，无需还原。" }
    return $true
}

# ---------------- 命令行模式 ----------------
if ($Action -eq "install" -or $Action -eq "restore") {
    $gameDir = Find-GameDir
    if (-not (Test-GameDir $gameDir)) { Write-Output "未找到游戏目录"; exit 1 }
    Write-Host "游戏目录：$gameDir"
    $clog = { param($s) Write-Host $s }
    if ($Action -eq "install") { $ok = Install-Patch $gameDir $clog } else { $ok = Restore-Game $gameDir $clog }
    if ($ok) { exit 0 } else { exit 1 }
}

# ---------------- 图形界面 ----------------
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form                 = New-Object System.Windows.Forms.Form
$form.Text            = "War on the Sea 简体中文补丁 v1.0"
$form.Size            = New-Object System.Drawing.Size(560, 470)
$form.StartPosition   = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox     = $false
$form.Font            = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$form.BackColor       = [System.Drawing.Color]::FromArgb(245, 247, 250)

$title          = New-Object System.Windows.Forms.Label
$title.Text     = "《War on the Sea》怒海激战 · 简体中文补丁"
$title.Font     = New-Object System.Drawing.Font("Microsoft YaHei UI", 13, [System.Drawing.FontStyle]::Bold)
$title.AutoSize = $false
$title.TextAlign = "MiddleCenter"
$title.Size     = New-Object System.Drawing.Size(540, 36)
$title.Location = New-Object System.Drawing.Point(2, 12)
$form.Controls.Add($title)

$lblPath          = New-Object System.Windows.Forms.Label
$lblPath.Text     = "游戏目录："
$lblPath.AutoSize = $true
$lblPath.Location = New-Object System.Drawing.Point(18, 62)
$form.Controls.Add($lblPath)

$txtPath          = New-Object System.Windows.Forms.TextBox
$txtPath.ReadOnly = $true
$txtPath.Size     = New-Object System.Drawing.Size(370, 24)
$txtPath.Location = New-Object System.Drawing.Point(88, 58)
$form.Controls.Add($txtPath)

$btnBrowse          = New-Object System.Windows.Forms.Button
$btnBrowse.Text     = "浏览..."
$btnBrowse.Size     = New-Object System.Drawing.Size(68, 26)
$btnBrowse.Location = New-Object System.Drawing.Point(466, 57)
$form.Controls.Add($btnBrowse)

$btnInstall           = New-Object System.Windows.Forms.Button
$btnInstall.Text      = "汉化为简体中文"
$btnInstall.Font      = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnInstall.Size      = New-Object System.Drawing.Size(245, 52)
$btnInstall.Location  = New-Object System.Drawing.Point(18, 96)
$btnInstall.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 70)
$btnInstall.ForeColor = [System.Drawing.Color]::White
$btnInstall.FlatStyle = "Flat"
$form.Controls.Add($btnInstall)

$btnRestore           = New-Object System.Windows.Forms.Button
$btnRestore.Text      = "还原为初始状态"
$btnRestore.Font      = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnRestore.Size      = New-Object System.Drawing.Size(245, 52)
$btnRestore.Location  = New-Object System.Drawing.Point(289, 96)
$btnRestore.BackColor = [System.Drawing.Color]::FromArgb(120, 60, 40)
$btnRestore.ForeColor = [System.Drawing.Color]::White
$btnRestore.FlatStyle = "Flat"
$form.Controls.Add($btnRestore)

$txtLog            = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline  = $true
$txtLog.ReadOnly   = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.Font       = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$txtLog.Size       = New-Object System.Drawing.Size(516, 235)
$txtLog.Location   = New-Object System.Drawing.Point(18, 162)
$txtLog.BackColor  = [System.Drawing.Color]::White
$form.Controls.Add($txtLog)

$lblFoot          = New-Object System.Windows.Forms.Label
$lblFoot.Text     = "不修改任何原版文件 · 存档完全兼容 · 游戏更新后补丁依然有效"
$lblFoot.AutoSize = $false
$lblFoot.TextAlign = "MiddleCenter"
$lblFoot.ForeColor = [System.Drawing.Color]::Gray
$lblFoot.Size     = New-Object System.Drawing.Size(540, 20)
$lblFoot.Location = New-Object System.Drawing.Point(2, 404)
$form.Controls.Add($lblFoot)

$script:gameDir = $null

function Add-Log([string]$s) {
    $txtLog.AppendText($s + [Environment]::NewLine)
    [System.Windows.Forms.Application]::DoEvents()
}
$guiLog = { param($s) Add-Log $s }

function Update-PathState {
    if (Test-GameDir $script:gameDir) {
        $txtPath.Text = $script:gameDir
        $btnInstall.Enabled = $true
        $btnRestore.Enabled = $true
        $chinese = Join-Path $script:gameDir "WarOnTheSea_Data\StreamingAssets\override\language\chinese"
        if (Test-Path $chinese) { Add-Log "当前状态：已安装简体中文补丁。" } else { Add-Log "当前状态：英文原版（未安装补丁）。" }
    } else {
        $txtPath.Text = "（未找到，请点击「浏览...」手动选择游戏文件夹）"
        $btnInstall.Enabled = $false
        $btnRestore.Enabled = $false
        Add-Log "未能自动找到游戏目录，请点击右上角「浏览...」选择"
        Add-Log "包含 WarOnTheSea.exe 的游戏文件夹。"
    }
}

$btnBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "请选择 War on the Sea 游戏文件夹（包含 WarOnTheSea.exe）"
    if ($dlg.ShowDialog() -eq "OK") {
        if (Test-GameDir $dlg.SelectedPath) {
            $script:gameDir = $dlg.SelectedPath
            $txtLog.Clear()
            Add-Log "已选择游戏目录：$($dlg.SelectedPath)"
            Update-PathState
        } else {
            [System.Windows.Forms.MessageBox]::Show("所选文件夹不是有效的 War on the Sea 游戏目录。`n（需包含 WarOnTheSea_Data\StreamingAssets）", "路径无效", "OK", "Warning") | Out-Null
        }
    }
})

$btnInstall.Add_Click({
    $btnInstall.Enabled = $false; $btnRestore.Enabled = $false
    $txtLog.Clear()
    try {
        $ok = Install-Patch $script:gameDir $guiLog
        if ($ok) { [System.Windows.Forms.MessageBox]::Show("汉化完成！启动游戏即为简体中文。", "完成", "OK", "Information") | Out-Null }
    } catch {
        Add-Log ("发生错误：" + $_.Exception.Message)
        [System.Windows.Forms.MessageBox]::Show("操作失败：$($_.Exception.Message)", "错误", "OK", "Error") | Out-Null
    }
    $btnInstall.Enabled = $true; $btnRestore.Enabled = $true
})

$btnRestore.Add_Click({
    $btnInstall.Enabled = $false; $btnRestore.Enabled = $false
    $txtLog.Clear()
    try {
        $ok = Restore-Game $script:gameDir $guiLog
        if ($ok) { [System.Windows.Forms.MessageBox]::Show("已还原为英文原版初始状态。", "完成", "OK", "Information") | Out-Null }
    } catch {
        Add-Log ("发生错误：" + $_.Exception.Message)
        [System.Windows.Forms.MessageBox]::Show("操作失败：$($_.Exception.Message)", "错误", "OK", "Error") | Out-Null
    }
    $btnInstall.Enabled = $true; $btnRestore.Enabled = $true
})

# 测试模式：构建界面后立即退出（用于自动化检查）
if ($Action -eq "testui") {
    Write-Output "UI controls created OK: $($form.Controls.Count) controls"
    $form.Dispose()
    exit 0
}

$form.Add_Shown({
    $script:gameDir = Find-GameDir
    Update-PathState
})

[void]$form.ShowDialog()
