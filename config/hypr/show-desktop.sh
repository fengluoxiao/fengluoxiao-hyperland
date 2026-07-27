#!/usr/bin/env bash
set -euo pipefail

signature="${HYPRLAND_INSTANCE_SIGNATURE:-default}"
state_file="/tmp/hypr-show-desktop-${UID}-${signature}.json"
lock_file="/tmp/hypr-show-desktop-${UID}-${signature}.lock"

exec 9>"$lock_file"
flock -n 9 || exit 0

restore_windows() {
    local workspace
    workspace="$(jq -r '.workspace' "$state_file")"

    jq -r '.windows[]' "$state_file" | while read -r address; do
        [ -n "$address" ] || continue
        hyprctl dispatch movetoworkspacesilent "${workspace},address:${address}" >/dev/null 2>&1 || true
    done

    rm -f "$state_file"
}

hide_windows() {
    local active_workspace active_id window_count
    active_workspace="$(hyprctl -j activeworkspace)"
    active_id="$(jq -r '.id' <<<"$active_workspace")"

    if [ -z "$active_id" ] || [ "$active_id" = "null" ] || [ "$active_id" -lt 0 ]; then
        exit 0
    fi

    hyprctl -j clients | jq --argjson workspace_id "$active_id" '
      {
        workspace: ($workspace_id | tostring),
        windows: [
          .[]
          | select(.workspace.id == $workspace_id)
          | select((.pinned // false) | not)
          | .address
        ]
      }
    ' >"$state_file"

    window_count="$(jq '.windows | length' "$state_file")"
    if [ "$window_count" -eq 0 ]; then
        rm -f "$state_file"
        exit 0
    fi

    jq -r '.windows[]' "$state_file" | while read -r address; do
        [ -n "$address" ] || continue
        hyprctl dispatch movetoworkspacesilent "special:desktop,address:${address}" >/dev/null 2>&1 || true
    done
}

if [ -s "$state_file" ]; then
    restore_windows
else
    hide_windows
fi
