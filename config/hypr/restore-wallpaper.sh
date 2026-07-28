#!/usr/bin/env bash
set -euo pipefail

current="__HOME__/.config/hypr/current-wallpaper"
wallpaper_dir="__HOME__/.config/hypr/wallpapers"
default_dir="/usr/share/backgrounds"

resolve_wallpaper() {
  if [[ -e "$current" ]]; then
    readlink -f "$current"
    return 0
  fi

  find "$wallpaper_dir" -maxdepth 1 -type f \
    \( -iname 'current.png' -o -iname 'current.jpg' -o -iname 'current.jpeg' -o -iname 'current.webp' \) \
    -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n 1 | cut -d' ' -f2-
}

fallback_wallpaper() {
  find "$default_dir" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
    | head -n 1
}

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

restore_once() {
  local image
  image="$(resolve_wallpaper)"
  if [[ -z "$image" || ! -f "$image" ]]; then
    image="$(fallback_wallpaper)"
  fi
  [[ -n "$image" && -f "$image" ]] || return 0

  mkdir -p "$wallpaper_dir"
  ln -sf "$image" "$current"
  sync_xfdesktop_wallpaper "$image"

  pkill -x swaybg >/dev/null 2>&1 || true
  setsid -f swaybg -m fill -i "$current" >/tmp/swaybg-wallpaper.log 2>&1
}

for delay in 0 1 2 4; do
  sleep "$delay"
  restore_once
done
