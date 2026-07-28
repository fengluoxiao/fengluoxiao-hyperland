#!/usr/bin/env bash
set -euo pipefail

title="$(hyprctl -j activewindow 2>/dev/null | jq -r '.title // ""' 2>/dev/null || true)"
if [ -z "$title" ] || [ "$title" = "null" ]; then
  printf '\n'
  exit 0
fi

printf '%s\n' "$title"
