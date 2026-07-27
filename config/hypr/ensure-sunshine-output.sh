#!/usr/bin/env bash
set -euo pipefail

# Sunshine needs a real active Hyprland output before Wayland capture can stay
# smooth. If no physical output is active, create one predictable 1080p60 output.
has_active_physical_output() {
  hyprctl monitors -j 2>/dev/null \
    | jq -e '.[] | select(.disabled == false and (.name | test("^(HEADLESS|Virtual)-") | not))' >/dev/null
}

has_any_active_output() {
  hyprctl monitors -j 2>/dev/null \
    | jq -e '.[] | select(.disabled == false and .width > 0 and .height > 0)' >/dev/null
}

for _ in $(seq 1 30); do
  if has_active_physical_output || has_any_active_output; then
    exit 0
  fi

  hyprctl keyword monitor 'Virtual-1,1920x1080@60,0x0,1' >/dev/null 2>&1 || true
  sleep 0.5
done

for _ in $(seq 1 10); do
  if has_any_active_output; then
    exit 0
  fi

  hyprctl output create headless >/dev/null 2>&1 || true
  hyprctl keyword monitor 'HEADLESS-1,1920x1080@60,0x0,1' >/dev/null 2>&1 || true
  sleep 0.5
done

has_any_active_output
