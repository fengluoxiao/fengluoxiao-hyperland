#!/usr/bin/env bash
set -euo pipefail

choice="$(printf '锁屏\n注销\n重启\n关机\n' | wofi --dmenu \
    --conf __HOME__/.config/wofi/power-config \
    --style __HOME__/.config/wofi/power-style.css 2>/dev/null || true)"

case "$choice" in
    '锁屏')
        hyprlock
        ;;
    '注销')
        hyprctl dispatch exit
        ;;
    '重启')
        systemctl reboot
        ;;
    '关机')
        systemctl poweroff
        ;;
esac
