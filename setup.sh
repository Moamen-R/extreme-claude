#!/usr/bin/env bash
# Claude Code and AI Ecosystem Setup Launcher for Linux / macOS
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
exec bash "${SCRIPT_DIR}/install.sh" "$@"
