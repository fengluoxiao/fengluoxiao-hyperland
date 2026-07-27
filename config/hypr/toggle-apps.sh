#!/usr/bin/env bash
set -euo pipefail

if pgrep -x wofi >/dev/null 2>&1; then
    pkill -x wofi
    exit 0
fi

wofi --show drun --allow-images --columns 4 --width 860 --height 620 --prompt 应用
