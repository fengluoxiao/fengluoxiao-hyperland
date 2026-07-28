# fengluoxiao Hyprland 配置

这是一套面向 Ubuntu 26.04 / Wayland / 远程桌面的 Hyprland 配置，目标是尽量接近 Windows 的日常操作习惯，同时保留 Hyprland 的平铺窗口效率。

主题规则：常态主色 `#3388bb`，hover 色 `#881144`。Waybar、Wofi、SwayNC、Fcitx5 候选框、GTK 侧边栏都按这个规则做了亮色胶囊风格。

## 包含内容

- Hyprland 主配置：`config/hypr/hyprland.conf`
- Sunshine 配置：`config/sunshine/sunshine.conf`
- Waybar 顶栏：`config/waybar/config.jsonc`、`config/waybar/style.css`
- SwayNC 通知和通知中心：`config/swaync/config.json`、`config/swaync/style.css`
- Wofi 应用菜单和电源菜单：`config/wofi/`
- Fcitx5 亮色输入法候选框主题：`config/fcitx5/`
- GTK3/GTK4 主题覆盖：`config/gtk-3.0/gtk.css`、`config/gtk-4.0/gtk.css`
- 远程/无头启动脚本：`config/hypr/headless-remote.sh`
- Sunshine 启动前无头输出保底：`config/hypr/ensure-sunshine-output.sh`
- 壁纸恢复脚本：`config/hypr/restore-wallpaper.sh`
- Windows 类快捷键脚本：显示桌面、Alt+Tab、壁纸切换、电源菜单、窗口标题最大化
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
- `paper-icon-theme`，Flat Remix 下载失败时的兜底图标主题

远程桌面：

- `wayvnc`
- `Sunshine`
- `Tailscale`
- Windows 端推荐安装 `Moonlight` 连接 Sunshine；VNC 客户端用于应急维护。

图标主题：

- 默认安装并启用 `Flat-Remix-Blue-Light`
- 下载地址使用国内可用加速：`https://gh-proxy.com/https://github.com/daniruiz/flat-remix/archive/refs/heads/master.tar.gz`
- 如果下载失败，回退到 Ubuntu 源里的 `Paper`

`Sunshine` 和 `Tailscale` 不一定在 Ubuntu 默认源里，建议按官方安装方式安装。`install.sh` 会安装当前 apt 源里能找到的包，找不到的会打印出来。

## 快捷键

- `Super+Q`：打开 Kitty
- `Super+E`：打开 Thunar 文件管理器
- `Super+R`：打开/关闭应用菜单
- `Super+C` 或 Waybar `关闭`：关闭当前窗口
- `Super+T`：当前窗口切换浮动/平铺
- `Alt+Shift+鼠标左键`：拖动窗口，避免 Moonlight/Windows 吃掉 Super 键
- `Alt+Shift+鼠标右键`：缩放窗口
- `Alt+Tab`：切换到下一个窗口，并处理浮动窗口遮挡
- `Alt+Shift+Tab`：反向切换窗口
- `Alt+Enter`：最大化当前窗口
- `Super+F`：最大化当前窗口
- `Super+Shift+F`：真正独占全屏
- `Alt+Shift+1` 到 `Alt+Shift+9`：把当前窗口移动到对应工作区
- `Alt+Shift+0`：把当前窗口移动到工作区 10
- `Super+D` 或 Waybar `桌面`：显示桌面，再按一次恢复窗口
- `Super+W` 或 Waybar `壁纸`：手动选择壁纸
- `Super+Space` / `Ctrl+Space`：切换 Fcitx5 输入法
- `Super+I`：打开 Fcitx5 设置
- `Super+A` 或 Waybar `设置`：打开外观设置
- `Super+Shift+D`：打开显示器设置

## Waybar 设计

Waybar 是亮色 MD3 胶囊风格：

- 外层背景透明，让 Hyprland 对 Waybar layer 做 blur
- 胶囊底色使用 `#f8fbfd` 系列浅色容器
- 常态按钮使用 `#3388bb` 或浅蓝容器
- hover 统一使用 `#881144`
- 左侧 `应用` 再点一次会关闭应用菜单
- 右侧 `电源` 打开下拉菜单，再点一次会关闭
- 右侧 `通知` 打开 SwayNC 通知中心，右键清空通知
- 最右侧当前窗口标题是自定义模块：左键最大化/还原当前窗口
- Hyprland 没有传统最小化任务栏模型，所以没有接管应用标题栏的 `-` 按钮；之前测试过监听最小化事件，容易导致窗口卡住，已移除

## Wofi 应用菜单

应用菜单使用四列网格、亮色浅蓝卡片和 `#3388bb` 选中态。搜索框已经收小，避免顶部输入框显得过重。

`应用` 按钮行为：

- 左键：打开/关闭应用菜单
- 右键：打开 Thunar

## GTK / Nautilus

GTK3/GTK4 覆盖文件负责统一选择色和 GNOME Files/Nautilus 侧边栏观感：

- 选择色：`#3388bb`
- hover：`#881144`
- Nautilus 侧边栏宽度、行高、圆角、选中态按当前 Hyprland 主题统一
- Hyprland 启动时会通过 `dbus-update-activation-environment --systemd` 把 `LANG/LC_ALL/LANGUAGE` 导入 DBus 和 systemd 用户环境，避免 Nautilus 被 DBus 拉起后显示英文

## Fcitx5 输入法主题

主题名：`pure-white`

配置文件：

- `config/fcitx5/conf/classicui.conf`
- `config/fcitx5/themes/pure-white/theme.conf`
- `config/fcitx5/themes/pure-white/panel.svg`
- `config/fcitx5/themes/pure-white/highlight.svg`

效果：候选框外层是白色圆角胶囊，选中候选词是 `#3388bb` 胶囊，文字留白更宽。

`config/fcitx5/config` 关闭了输入法切换信息弹窗，避免 Hyprland 下切换提示跑到屏幕角落。`waybar-ime-guard.service` 用于照顾部分 fullscreen/Wayland 场景的输入法状态。

## 远程和无头显示

`headless-remote.sh` 会在 Hyprland 启动后尝试确保远程输出可用，然后启动：

- `wayvnc`
- `app-dev.lizardbyte.app.Sunshine.service`

Sunshine 用户服务也带了 `ExecStartPre=~/.config/hypr/ensure-sunshine-output.sh` 保底检查。这样不插 HDMI/显示器时，Sunshine 启动前会先让 Hyprland 拿到可捕获输出，避免 `Unable to find display or encoder during startup`。

`restore-wallpaper.sh` 会在无显示器/Moonlight 回来时补铺壁纸：

- 使用 `~/.config/hypr/current-wallpaper` 作为稳定入口
- 自动同步 `swaybg` 和 `xfdesktop`
- 对当前活动输出，例如 `Virtual-1`，写入 xfdesktop 的 `last-image`
- 在启动后的 `0/1/2/4` 秒多次恢复，处理输出创建晚于壁纸服务的情况

当前 Hyprland 配置里固定了：

```ini
monitor = HDMI-A-1, 1920x1080@60, 0x0, 1
monitor = Virtual-1, disable
monitor = HEADLESS-1, 1920x1080@60, 0x0, 1
monitor = , preferred, auto, 1
```

如果机器没有物理显示器，优先用 Sunshine + Moonlight 连接；Tailscale 负责异地组网。Moonlight 远程时 Win/Super 可能被 Windows 本机拦截，所以窗口移动、缩放、移动到工作区都额外提供了 `Alt+Shift` 组合。

Sunshine 建议交给 systemd 用户服务托管：

```bash
systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service
```

如果 Moonlight 局域网发现不到这台电脑，先手动添加 `https://主机IP:47990` 对应的主机 IP，当前配置常用端口需要在防火墙放行：

```bash
sudo ufw allow 47984/tcp comment Sunshine
sudo ufw allow 47989/tcp comment Sunshine
sudo ufw allow 47990/tcp comment Sunshine
sudo ufw allow 48010/tcp comment Sunshine
sudo ufw allow 5353/udp comment mDNS
sudo ufw reload
```

如果机器上有类似 `Meta` 这样的代理/虚拟网卡，mDNS 多播可能会走错网卡。可以用脚本把 Moonlight/Sunshine 发现用到的多播路由固定到当前 Wi-Fi：

```bash
./scripts/fix-moonlight-discovery.sh
```

脚本会确认 `224.0.0.251` 和 `239.255.255.250` 走 Wi-Fi 网卡。

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
