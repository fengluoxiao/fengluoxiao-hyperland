#!/usr/bin/env bash
set -euo pipefail

current="__HOME__/.config/hypr/current-wallpaper"
default_dir="/usr/share/backgrounds"

pick="${1:-}"
if [[ -z "$pick" ]]; then
  pick=$(zenity --file-selection \
    --title="选择壁纸" \
    --filename="$default_dir/" \
    --file-filter='Images | *.png *.jpg *.jpeg *.webp' 2>/dev/null || true)
fi

if [[ -z "$pick" || ! -f "$pick" ]]; then
  exit 0
fi

ln -sf "$pick" "$current"
pkill -x swaybg >/dev/null 2>&1 || true
setsid -f swaybg -m fill -i "$current" >/tmp/swaybg-wallpaper.log 2>&1
