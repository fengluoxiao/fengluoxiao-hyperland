#!/usr/bin/env bash
set -euo pipefail

# Sunshine needs at least one active Hyprland output before it can initialize
# Wayland capture. Create a predictable headless output when no physical output
# is ready yet.
for _ in $(seq 1 20); do
  if hyprctl monitors 2>/dev/null | grep -q '^Monitor '; then
    exit 0
  fi

  hyprctl output create headless >/dev/null 2>&1 || true
  hyprctl keyword monitor 'HEADLESS-1,1920x1080@60,0x0,1' >/dev/null 2>&1 || true
  sleep 0.5
done

hyprctl monitors 2>/dev/null | grep -q '^Monitor '
