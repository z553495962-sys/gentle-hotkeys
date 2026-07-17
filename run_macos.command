#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -x ".venv/bin/python" ]; then
  echo "Local venv not found. Run ./install_macos.command first."
  exit 1
fi

.venv/bin/python gentle_hotkeys.py "$@"
