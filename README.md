# fengluoxiao Hyprland 配置

这是一套面向 Ubuntu 26.04 / Wayland / 远程桌面的 Hyprland 配置，目标是尽量接近 Windows 的日常操作习惯，同时保留 Hyprland 的平铺窗口效率。

主题规则：常态主色 `#3388bb`，hover 色 `#881144`。Waybar、Wofi、Fcitx5 候选框都按这个规则做了亮色胶囊风格。

## 包含内容

- Hyprland 主配置：`config/hypr/hyprland.conf`
- Waybar 顶栏：`config/waybar/config.jsonc`、`config/waybar/style.css`
- Wofi 应用菜单和电源菜单：`config/wofi/`
- Fcitx5 亮色输入法候选框主题：`config/fcitx5/`
- 远程/无头启动脚本：`config/hypr/headless-remote.sh`
- Windows 类快捷键脚本：显示桌面、Alt+Tab、壁纸切换、电源菜单
- IME fullscreen guard：`config/systemd/user/waybar-ime-guard.service`
- 安装脚本：`install.sh`

## 一键安装

```bash
git clone https://github.com/fengluoxiao/fengluoxiao-hyperland.git
cd fengluoxiao-hyperland
chmod +x install.sh
./install.sh all
```

只安装软件包：

```bash
./install.sh packages
```

只应用配置：

```bash
./install.sh configs
```

安装脚本会备份已有配置到 `~/.config/fengluoxiao-hyprland-backup-时间戳`。

## 需要的软件和插件

核心桌面：

- `hyprland`
- `waybar`
- `wofi`
- `kitty`
- `thunar`
- `dunst`
- `swaybg`
- `hypridle`
- `hyprlock`
- `xdg-desktop-portal-hyprland`，如果你的源里有这个包，建议安装

Wayland 工具：

- `grim`
- `slurp`
- `swappy`
- `wl-clipboard`
- `cliphist`
- `fuzzel`
- `jq`
- `zenity`

设置和系统托盘：

- `network-manager-gnome`
- `pavucontrol`
- `pipewire`
- `wireplumber`
- `brightnessctl`
- `policykit-1-gnome`
- `xfdesktop4`
- `nwg-look`
- `nwg-displays`

输入法：

- `fcitx5`
- `fcitx5-chinese-addons`
- `fcitx5-config-qt`
- `fcitx5-frontend-gtk3`
- `fcitx5-frontend-gtk4`
- `fcitx5-frontend-qt5`
- `fcitx5-frontend-qt6`

字体：

- `fonts-inter`
- `fonts-jetbrains-mono`
- `fonts-noto-cjk`

远程桌面：

- `wayvnc`
- `Sunshine`
- `Tailscale`
- Windows 端推荐安装 `Moonlight` 连接 Sunshine；VNC 客户端用于应急维护。

`Sunshine` 和 `Tailscale` 不一定在 Ubuntu 默认源里，建议按官方安装方式安装。`install.sh` 会安装当前 apt 源里能找到的包，找不到的会打印出来。

## 快捷键

- `Super+Q`：打开 Kitty
- `Super+E`：打开 Thunar 文件管理器
- `Super+R`：打开/关闭应用菜单
- `Super+C` 或 Waybar `关闭`：关闭当前窗口
- `Super+T`：当前窗口切换浮动/平铺
- `Alt+鼠标左键`：拖动窗口
- `Alt+鼠标右键`：缩放窗口
- `Alt+Tab`：切换到下一个窗口，并处理浮动窗口遮挡
- `Alt+Shift+Tab`：反向切换窗口
- `Alt+Enter`：最大化当前窗口
- `Super+F`：最大化当前窗口
- `Super+Shift+F`：真正独占全屏
- `Super+D` 或 Waybar `桌面`：显示桌面，再按一次恢复窗口
- `Super+W` 或 Waybar `壁纸`：手动选择壁纸
- `Super+Space` / `Ctrl+Space`：切换 Fcitx5 输入法
- `Super+I`：打开 Fcitx5 设置
- `Super+A` 或 Waybar `设置`：打开外观设置
- `Super+Shift+D`：打开显示器设置

## Waybar 设计

Waybar 是亮色 MD3 胶囊风格：

- 外层背景透明，让 Hyprland 对 Waybar layer 做 blur
- 胶囊底色使用半透明 `rgba(248, 251, 253, 0.32)`
- 常态按钮使用 `#3388bb` 或浅蓝容器
- hover 统一使用 `#881144`
- 左侧 `应用` 再点一次会关闭应用菜单
- 右侧 `电源` 打开下拉菜单，再点一次会关闭

## Fcitx5 输入法主题

主题名：`pure-white`

配置文件：

- `config/fcitx5/conf/classicui.conf`
- `config/fcitx5/themes/pure-white/theme.conf`
- `config/fcitx5/themes/pure-white/panel.svg`
- `config/fcitx5/themes/pure-white/highlight.svg`

效果：候选框外层是白色圆角胶囊，选中候选词是 `#3388bb` 胶囊，文字留白更宽。

## 远程和无头显示

`headless-remote.sh` 会在 Hyprland 启动后尝试确保 `HEADLESS-1` 可用，然后启动：

- `wayvnc`
- `sunshine`

当前 Hyprland 配置里固定了：

```ini
monitor = HDMI-A-1, 1920x1080@60, 0x0, 1
monitor = Virtual-1, disable
monitor = HEADLESS-1, 1920x1080@60, 0x0, 1
monitor = , preferred, auto, 1
```

如果机器没有物理显示器，优先用 Sunshine + Moonlight 连接；Tailscale 负责异地组网。

## GDM 自动登录 Hyprland

如果要无人值守开机自动进 Hyprland，需要另外配置 GDM。示例：

```ini
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=fengluoxiao
DefaultSession=hyprland.desktop
```

路径通常是 `/etc/gdm3/custom.conf`。这一步需要 root 权限，并且不同发行版会有细节差异，所以没有放进一键脚本里强制修改。

## 应用后刷新

已经在 Hyprland 里时，可以执行：

```bash
hyprctl reload
pkill -x waybar; ~/.config/hypr/start-waybar.sh
fcitx5-remote -r
```

不要在远程会话中随便重启 GDM，容易把当前连接踢掉。
