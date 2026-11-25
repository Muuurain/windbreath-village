param(
    [switch]$ExportAndroid = $false,
    [switch]$ExportWindows = $false
)

$ErrorActionPreference = "Stop"
$Godot = "D:\Godot\Godot_v4.7.2-stable_mono_win64\Godot_v4.7.2-stable_mono_win64_console.exe"
$Proj = "D:\Code\project\windbreath_village"

Write-Host "=== 1. Running Headless Test Suite ===" -ForegroundColor Cyan
& $Godot --headless --path $Proj "res://tests/test_runner.tscn"
if ($LASTEXITCODE -ne 0) {
    throw "TestSuite failed with exit code $LASTEXITCODE"
}

if ($ExportAndroid) {
    Write-Host "`n=== 2. Exporting Android Debug APK ===" -ForegroundColor Cyan
    & $Godot --headless --path $Proj --export-debug "Android" "$Proj\build\windbreath_village_debug.apk"
    if ($LASTEXITCODE -ne 0) {
        throw "Android export failed with exit code $LASTEXITCODE"
    }
}

if ($ExportWindows) {
    Write-Host "`n=== 3. Exporting Windows Desktop Release ===" -ForegroundColor Cyan
    & $Godot --headless --path $Proj --export-release "WindowsDesktop" "$Proj\build\windbreath_village_win64.exe"
    if ($LASTEXITCODE -ne 0) {
        throw "Windows export failed with exit code $LASTEXITCODE"
    }
}

Write-Host "`n=== All Verification Steps Completed Cleanly ===" -ForegroundColor Green
