<#
.SYNOPSIS
  Standard, pinned Windows build for directory_dash Flutter app.

.DESCRIPTION
  Wraps the exact environment and command sequence confirmed working, so
  rebuilding this repo never again depends on tribal knowledge or whatever happens to be on PATH.
  Safe to re-run; does not modify the system/global PATH.

  This project requires Flutter SDK ^3.13.0 (Dart SDK constraint).
  The pinned version is Flutter 3.47.5 which uses Dart 3.13.4.
#>

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

# Pinned Flutter SDK - uses Dart 3.13.4 which satisfies the pubspec.yaml constraint: sdk: ^3.13.0
$flutterPinned = "C:\Users\chris\flutter\bin"

if (-not (Test-Path $flutterPinned)) {
    throw "Pinned Flutter 3.47.5 not found at $flutterPinned. Please install Flutter 3.47.5 or update this script to use the correct SDK path."
}

# Scoped to this process only -- never touches the user/system PATH.
$env:Path = "$flutterPinned;$env:Path"

Set-Location $repoRoot

Write-Output "Building Windows release..."
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    throw "flutter build windows --release exited with code $LASTEXITCODE"
}

$installerDir = Join-Path $repoRoot "build\windows\x64\runner\Release"
if (-not (Test-Path $installerDir)) {
    throw "Build reported success but build\windows\x64\runner\Release was not found"
}

# Find the main executable
$exe = Get-ChildItem -Path $installerDir -Filter "*.exe" | Select-Object -First 1
if (-not $exe) {
    throw "No executable found in $installerDir"
}

Write-Output ""
Write-Output "Built: $($exe.FullName) ($([math]::Round($exe.Length / 1MB, 1)) MB, $($exe.LastWriteTime))"
Write-Output ""
