#!/usr/bin/env bash
set -euo pipefail

if pgrep -x wofi >/dev/null 2>&1; then
    pkill -x wofi
    exit 0
fi

menu_width=220
menu_height=210
cursor_pos="$(hyprctl cursorpos 2>/dev/null || printf '1700, 32')"
cursor_x="${cursor_pos%%,*}"
cursor_y="${cursor_pos##*, }"

monitor_json="$(hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused == true) | [.x, .y, .width, .height] | @tsv' | head -n 1)"
if [ -n "$monitor_json" ]; then
    read -r monitor_x monitor_y monitor_width monitor_height <<<"$monitor_json"
else
    monitor_x=0
    monitor_y=0
    monitor_width=1920
    monitor_height=1080
fi

xoffset=$((cursor_x - menu_width / 2))
yoffset=$((cursor_y + 26))
bar_bottom=$((monitor_y + 66))
min_x=$((monitor_x + 12))
max_x=$((monitor_x + monitor_width - menu_width - 12))
max_y=$((monitor_y + monitor_height - menu_height - 12))

if [ "$xoffset" -lt "$min_x" ]; then
    xoffset="$min_x"
elif [ "$xoffset" -gt "$max_x" ]; then
    xoffset="$max_x"
fi

if [ "$yoffset" -gt "$max_y" ]; then
    yoffset="$max_y"
fi

if [ "$yoffset" -lt "$bar_bottom" ]; then
    yoffset="$bar_bottom"
fi

hyprctl dispatch exec "[float; size ${menu_width} ${menu_height}; move ${xoffset} ${yoffset}; no_anim; border_size 0; no_shadow] __HOME__/.config/hypr/power-menu-runner.sh" >/dev/null
