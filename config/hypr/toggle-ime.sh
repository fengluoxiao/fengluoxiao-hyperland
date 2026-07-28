#!/usr/bin/env bash
set -euo pipefail

state="$(fcitx5-remote 2>/dev/null || echo 0)"

case "$state" in
  2)
    fcitx5-remote -c >/dev/null 2>&1
    ;;
  *)
    fcitx5-remote -o >/dev/null 2>&1
    ;;
esac
