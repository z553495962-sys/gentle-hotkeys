#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

ollama_ready() {
  curl -fsS "http://localhost:11434/api/tags" >/dev/null 2>&1
}

wait_ollama() {
  for _ in {1..30}; do
    if ollama_ready; then
      return 0
    fi
    sleep 1
  done
  echo "Ollama service did not become ready. Open Ollama once, then run this installer again."
  exit 1
}

ensure_ollama() {
  if command -v ollama >/dev/null 2>&1; then
    return 0
  fi

  if command -v brew >/dev/null 2>&1; then
    echo "Ollama not found. Trying Homebrew install..."
    brew install --cask ollama || brew install ollama
    if command -v ollama >/dev/null 2>&1; then
      return 0
    fi
  fi

  open "https://ollama.com/download"
  echo "Ollama was not found. Install Ollama from the opened page, then run this installer again."
  exit 1
}

start_ollama_if_needed() {
  if ollama_ready; then
    return 0
  fi

  echo "Starting Ollama service..."
  nohup ollama serve >> gentle_hotkeys.log 2>&1 &
  wait_ollama
}

echo "== Gentle Hotkeys macOS installer =="

./setup_venv.sh

if [ ! -f ".openrouter_key" ]; then
  read -r -s -p "OpenRouter API key (optional, press Enter to skip): " openrouter_key
  echo
  if [ -n "${openrouter_key// }" ]; then
    printf "%s\n" "$openrouter_key" > .openrouter_key
    chmod 600 .openrouter_key
    echo "Saved OpenRouter key to .openrouter_key"
  else
    echo "No OpenRouter key configured; Ollama fallback will be used."
  fi
else
  echo "Existing .openrouter_key found; keeping it."
fi

ensure_ollama
start_ollama_if_needed

model="$(
  .venv/bin/python - <<'PY'
import json
with open("config.json", "r", encoding="utf-8") as f:
    print(json.load(f)["ollama"]["model"])
PY
)"

echo "Pulling model: $model"
ollama pull "$model"

.venv/bin/python gentle_hotkeys.py --install-startup
nohup .venv/bin/python gentle_hotkeys.py >> gentle_hotkeys.log 2>&1 &

echo
echo "Installed and started."
echo "Polish: Command+Option+G"
echo "Translate: Command+Option+V"
echo "Summarize: Command+Option+S"
echo "Quit: Command+Option+Shift+Q"
echo
echo "macOS may ask for Accessibility permission."
echo "Open System Settings > Privacy & Security > Accessibility, then allow Terminal or Python."
