#!/usr/bin/env bash
set -euo pipefail

current="__HOME__/.config/hypr/current-wallpaper"
wallpaper_dir="__HOME__/.config/hypr/wallpapers"
default_dir="/usr/share/backgrounds"

sync_xfdesktop_wallpaper() {
  local image="$1"
  command -v xfconf-query >/dev/null 2>&1 || return 0

  local monitors=(monitor0)
  if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    while IFS= read -r monitor; do
      [[ -n "$monitor" ]] && monitors+=("monitor${monitor}")
    done < <(hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.disabled == false) | .name' 2>/dev/null || true)
  fi

  local monitor path
  for monitor in "${monitors[@]}"; do
    path="/backdrop/screen0/${monitor}/workspace0"
    xfconf-query -c xfce4-desktop -p "${path}/last-image" -n -t string -s "$image" >/dev/null 2>&1 || true
    xfconf-query -c xfce4-desktop -p "${path}/image-style" -n -t int -s 5 >/dev/null 2>&1 || true
    xfconf-query -c xfce4-desktop -p "${path}/color-style" -n -t int -s 0 >/dev/null 2>&1 || true
  done

  xfdesktop --reload >/dev/null 2>&1 || true
}

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

mkdir -p "$wallpaper_dir"
ext="${pick##*.}"
case "${ext,,}" in
  png|jpg|jpeg|webp) ;;
  *) ext="png" ;;
esac
stable="${wallpaper_dir}/current.${ext}"
cp "$pick" "$stable"
ln -sf "$stable" "$current"
sync_xfdesktop_wallpaper "$stable"
pkill -x swaybg >/dev/null 2>&1 || true
setsid -f swaybg -m fill -i "$current" >/tmp/swaybg-wallpaper.log 2>&1
