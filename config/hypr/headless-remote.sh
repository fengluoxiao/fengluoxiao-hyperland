#!/usr/bin/env bash
set -euo pipefail

~/.config/hypr/ensure-sunshine-output.sh || true

sleep 2

pgrep -x wayvnc >/dev/null 2>&1 || wayvnc >/tmp/wayvnc-hyprland.log 2>&1 &
systemctl --user start app-dev.lizardbyte.app.Sunshine.service >/dev/null 2>&1 || true
