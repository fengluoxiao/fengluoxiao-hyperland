#!/usr/bin/env bash
set -euo pipefail

direction="${1:-next}"
signature="${HYPRLAND_INSTANCE_SIGNATURE:-default}"
state_file="/tmp/hypr-alt-tab-hidden-${UID}-${signature}.json"
lock_file="/tmp/hypr-alt-tab-hidden-${UID}-${signature}.lock"

exec 9>"$lock_file"
flock -n 9 || exit 0

restore_hidden_floaters() {
    [ -s "$state_file" ] || return 0

    jq -r '.windows[] | [.workspace, .address] | @tsv' "$state_file" | while IFS=$'\t' read -r workspace address; do
        [ -n "$workspace" ] || continue
        [ -n "$address" ] || continue
        hyprctl dispatch movetoworkspacesilent "${workspace},address:${address}" >/dev/null 2>&1 || true
    done

    rm -f "$state_file"
}

hide_floaters_on_workspace() {
    local workspace_id="$1"
    local active_address="$2"
    local window_count

    hyprctl -j clients | jq --arg active "$active_address" --argjson ws "$workspace_id" '
      {
        windows: [
          .[]
          | select(.workspace.id == $ws)
          | select(.address != $active)
          | select(.floating == true)
          | select((.pinned // false) | not)
          | { workspace: (.workspace.id | tostring), address }
        ]
      }
    ' >"$state_file"

    window_count="$(jq '.windows | length' "$state_file")"
    if [ "$window_count" -eq 0 ]; then
        rm -f "$state_file"
        return 0
    fi

    jq -r '.windows[] | .address' "$state_file" | while read -r address; do
        [ -n "$address" ] || continue
        hyprctl dispatch movetoworkspacesilent "special:alttab-hidden,address:${address}" >/dev/null 2>&1 || true
    done
}

restore_hidden_floaters

if [ "$direction" = "prev" ]; then
    hyprctl dispatch cyclenext prev >/dev/null
else
    hyprctl dispatch cyclenext >/dev/null
fi

sleep 0.04

active_json="$(hyprctl -j activewindow)"
active_address="$(jq -r '.address' <<<"$active_json")"
workspace_id="$(jq -r '.workspace.id' <<<"$active_json")"
is_floating="$(jq -r '.floating' <<<"$active_json")"

if [ -z "$active_address" ] || [ "$active_address" = "null" ]; then
    exit 0
fi

if [ "$is_floating" = "true" ]; then
    hyprctl dispatch alterzorder "top,address:${active_address}" >/dev/null 2>&1 || true
else
    hide_floaters_on_workspace "$workspace_id" "$active_address"
fi

hyprctl dispatch focuswindow "address:${active_address}" >/dev/null 2>&1 || true
