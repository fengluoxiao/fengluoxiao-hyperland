#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="${HOME}/.config/fengluoxiao-hyprland-backup-$(date +%Y%m%d-%H%M%S)"

apt_packages=(
  hyprland
  waybar
  wofi
  kitty
  thunar
  dunst
  sway-notification-center
  swaybg
  hypridle
  hyprlock
  grim
  slurp
  swappy
  wl-clipboard
  cliphist
  fuzzel
  jq
  zenity
  network-manager-gnome
  pavucontrol
  pipewire
  wireplumber
  brightnessctl
  policykit-1-gnome
  xfdesktop4
  nwg-look
  nwg-displays
  fcitx5
  fcitx5-chinese-addons
  fcitx5-config-qt
  fcitx5-frontend-gtk3
  fcitx5-frontend-gtk4
  fcitx5-frontend-qt5
  fcitx5-frontend-qt6
  fonts-inter
  fonts-jetbrains-mono
  fonts-noto-cjk
  wayvnc
  xdg-desktop-portal-hyprland
  gnome-control-center
)

install_packages() {
  if ! command -v apt >/dev/null 2>&1; then
    echo "未检测到 apt，跳过系统包安装。"
    return 0
  fi

  sudo apt update
  local available=()
  local missing=()
  for package in "${apt_packages[@]}"; do
    if apt-cache show "$package" >/dev/null 2>&1; then
      available+=("$package")
    else
      missing+=("$package")
    fi
  done

  if [ "${#available[@]}" -gt 0 ]; then
    sudo apt install -y "${available[@]}"
  fi

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "以下包在当前软件源里没有找到，请按 README 手动安装或换源：${missing[*]}"
  fi
}

backup_path() {
  local path="$1"
  if [ -e "$path" ] || [ -L "$path" ]; then
    mkdir -p "$backup_dir$(dirname "$path" | sed "s#^${HOME}##")"
    mv "$path" "$backup_dir$(dirname "$path" | sed "s#^${HOME}##")/"
  fi
}

render_tree() {
  local src="$1"
  local dest="$2"
  mkdir -p "$dest"
  find "$src" -type d -printf '%P\n' | while read -r dir; do
    mkdir -p "$dest/$dir"
  done
  find "$src" -type f -printf '%P\n' | while read -r file; do
    case "$file" in
      *.png|*.jpg|*.jpeg|*.webp)
        cp "$src/$file" "$dest/$file"
        ;;
      *)
        sed "s#__HOME__#${HOME}#g" "$src/$file" >"$dest/$file"
        ;;
    esac
  done
}

copy_binary_assets() {
  cp "$repo_dir/config/fcitx5/themes/pure-white/arrow.png" "${HOME}/.local/share/fcitx5/themes/pure-white/"
  cp "$repo_dir/config/fcitx5/themes/pure-white/radio.png" "${HOME}/.local/share/fcitx5/themes/pure-white/"
}

apply_configs() {
  mkdir -p "${HOME}/.config" "${HOME}/.local/share/fcitx5/themes"

  backup_path "${HOME}/.config/hypr"
  backup_path "${HOME}/.config/waybar"
  backup_path "${HOME}/.config/wofi"
  backup_path "${HOME}/.config/dunst"
  backup_path "${HOME}/.config/swaync"
  backup_path "${HOME}/.config/sunshine/sunshine.conf"
  backup_path "${HOME}/.config/fcitx5/config"
  backup_path "${HOME}/.config/fcitx5/conf/classicui.conf"
  backup_path "${HOME}/.local/share/fcitx5/themes/pure-white"
  backup_path "${HOME}/.config/systemd/user/waybar-ime-guard.service"

  render_tree "$repo_dir/config/hypr" "${HOME}/.config/hypr"
  render_tree "$repo_dir/config/waybar" "${HOME}/.config/waybar"
  render_tree "$repo_dir/config/wofi" "${HOME}/.config/wofi"
  render_tree "$repo_dir/config/dunst" "${HOME}/.config/dunst"
  render_tree "$repo_dir/config/swaync" "${HOME}/.config/swaync"
  render_tree "$repo_dir/config/sunshine" "${HOME}/.config/sunshine"
  if [ -f "$repo_dir/config/fcitx5/config" ]; then
    sed "s#__HOME__#${HOME}#g" "$repo_dir/config/fcitx5/config" >"${HOME}/.config/fcitx5/config"
  fi
  render_tree "$repo_dir/config/fcitx5/conf" "${HOME}/.config/fcitx5/conf"
  render_tree "$repo_dir/config/fcitx5/themes/pure-white" "${HOME}/.local/share/fcitx5/themes/pure-white"
  render_tree "$repo_dir/config/systemd/user" "${HOME}/.config/systemd/user"
  if [ -d "$repo_dir/config/systemd/system" ]; then
    sudo mkdir -p /etc/systemd/system
    sudo cp -R "$repo_dir/config/systemd/system/." /etc/systemd/system/
  fi
  copy_binary_assets

  chmod +x "${HOME}/.config/hypr"/*.sh

  if [ ! -e "${HOME}/.config/hypr/current-wallpaper" ]; then
    local wallpaper
    wallpaper="$(find /usr/share/backgrounds -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | head -n 1 || true)"
    [ -n "$wallpaper" ] && ln -s "$wallpaper" "${HOME}/.config/hypr/current-wallpaper"
  fi

  systemctl --user daemon-reload || true
  sudo systemctl daemon-reload || true
  sudo systemctl enable --now tailscaled.service || true
  systemctl --user enable --now waybar-ime-guard.service || true
  systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service || true
}

case "${1:-all}" in
  packages)
    install_packages
    ;;
  configs)
    apply_configs
    ;;
  all)
    install_packages
    apply_configs
    ;;
  *)
    echo "用法: $0 [all|packages|configs]"
    exit 2
    ;;
esac

echo "完成。原配置备份目录: $backup_dir"
