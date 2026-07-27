#!/usr/bin/env bash
set -euo pipefail

connection="${1:-}"
device="${2:-}"

if [ -z "$connection" ] || [ -z "$device" ]; then
  active_wifi="$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | awk -F: '$2 == "802-11-wireless" { print $1 ":" $3; exit }')"
  connection="${active_wifi%%:*}"
  device="${active_wifi##*:}"
fi

if [ -z "$connection" ] || [ -z "$device" ] || [ "$connection" = "$device" ]; then
  echo "没有找到活动 Wi-Fi 连接。用法: $0 <connection-name> <device>"
  exit 2
fi

nmcli connection modify "$connection" +ipv4.routes "224.0.0.251/32 0.0.0.0 1 table=2022, 239.255.255.250/32 0.0.0.0 1 table=2022"
nmcli device reapply "$device"

ip route get 224.0.0.251
ip route get 239.255.255.250
