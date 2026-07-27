#!/usr/bin/env bash
set -euo pipefail

# Give Hyprland enough time to bring up outputs. If a physical monitor is
# present, keep it as the capture target; otherwise create a predictable
# headless output before remote servers start.
sleep 2

if ! hyprctl monitors 2>/dev/null | grep -q '^Monitor .* (ID .*):'; then
  hyprctl output create headless >/dev/null 2>&1 || true
fi

if ! hyprctl monitors 2>/dev/null | grep -q '^Monitor HDMI-A-1'; then
  hyprctl keyword monitor 'HEADLESS-1,1920x1080@60,0x0,1' >/dev/null 2>&1 || true
fi

sleep 2

pgrep -x wayvnc >/dev/null 2>&1 || wayvnc >/tmp/wayvnc-hyprland.log 2>&1 &
systemctl --user start app-dev.lizardbyte.app.Sunshine.service >/dev/null 2>&1 || true
