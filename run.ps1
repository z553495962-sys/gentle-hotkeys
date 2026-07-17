$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

$venvPython = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
$scriptPath = Join-Path $PSScriptRoot "gentle_hotkeys.py"

if (-not (Test-Path $venvPython)) {
    throw "Local venv not found. Run .\setup_venv.ps1 first."
}

& $venvPython $scriptPath @args
