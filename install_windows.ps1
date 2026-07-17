$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

function Test-OllamaServer {
    try {
        Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 2 | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Wait-OllamaServer {
    for ($i = 0; $i -lt 30; $i++) {
        if (Test-OllamaServer) {
            return
        }
        Start-Sleep -Seconds 1
    }
    throw "Ollama service did not become ready. Open Ollama once, then run this installer again."
}

function Ensure-Ollama {
    if (Get-Command ollama -ErrorAction SilentlyContinue) {
        return
    }

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Ollama not found. Trying winget install..."
        winget install --id Ollama.Ollama -e --silent --accept-source-agreements --accept-package-agreements
        if (Get-Command ollama -ErrorAction SilentlyContinue) {
            return
        }
    }

    Start-Process "https://ollama.com/download"
    throw "Ollama was not found. Install Ollama from the opened page, then run this installer again."
}

function Start-OllamaIfNeeded {
    if (Test-OllamaServer) {
        return
    }

    $ollama = (Get-Command ollama -ErrorAction Stop).Source
    Write-Host "Starting Ollama service..."
    Start-Process -FilePath $ollama -ArgumentList "serve" -WindowStyle Hidden
    Wait-OllamaServer
}

Write-Host "== Gentle Hotkeys Windows installer =="

powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup_venv.ps1"

if (-not (Test-Path ".\.openrouter_key")) {
    $openRouterKey = Read-Host "OpenRouter API key (optional, press Enter to skip)"
    if (-not [string]::IsNullOrWhiteSpace($openRouterKey)) {
        Set-Content -Path ".\.openrouter_key" -Value $openRouterKey.Trim() -Encoding ASCII
        Write-Host "Saved OpenRouter key to .openrouter_key"
    } else {
        Write-Host "No OpenRouter key configured; Ollama fallback will be used."
    }
} else {
    Write-Host "Existing .openrouter_key found; keeping it."
}

Ensure-Ollama
Start-OllamaIfNeeded

$venvPython = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
$model = & $venvPython -c "import json; print(json.load(open('config.json', encoding='utf-8'))['ollama']['model'])"
Write-Host "Pulling model: $model"
ollama pull $model

.\run.ps1 --install-startup

$pythonw = Join-Path $PSScriptRoot ".venv\Scripts\pythonw.exe"
$python = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
$runner = if (Test-Path $pythonw) { $pythonw } else { $python }
Start-Process -FilePath $runner -ArgumentList "`"$PSScriptRoot\gentle_hotkeys.py`"" -WorkingDirectory $PSScriptRoot -WindowStyle Hidden

Write-Host ""
Write-Host "Installed and started."
Write-Host "Polish: Ctrl+Alt+G"
Write-Host "Translate: Ctrl+Alt+V"
Write-Host "Summarize: Ctrl+Alt+S"
Write-Host "Quit: Ctrl+Alt+Shift+Q"
