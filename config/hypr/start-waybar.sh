#!/usr/bin/env bash
set -euo pipefail

pgrep -af '^waybar( |$)' | grep -v 'ime-guard.jsonc' >/dev/null 2>&1 || waybar >/tmp/waybar.log 2>&1 &
systemctl --user start waybar-ime-guard.service >/dev/null 2>&1 || true
