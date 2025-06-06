# 🪟 qtile-setup

![Made for Debian](https://img.shields.io/badge/Made%20for-Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)

A complete Qtile setup script for Debian-based systems.  
Features dynamic tiling layouts, powerful keybindings, and a polished desktop experience — ready to roll out of the box.

> Part of the [JustAGuy Linux](https://github.com/drewgrif) window manager collection.

## Installation Method

This installer uses `pipx` to install Qtile. Here's why:

### Why pipx instead of apt?
- **Latest Version**: Qtile is not yet available in Debian stable repositories (coming in the next release)
- **Easy Updates**: With pipx, you can always update to the latest Qtile version using `pipx upgrade qtile`
- **Isolated Environment**: pipx automatically creates a virtual environment, preventing conflicts with system Python packages
- **Future-Proof**: Even when Qtile arrives in Debian repos, pipx will allow you to use newer versions if desired

### Alternative Methods (not used, but available)
- **apt install qtile**: Will be available in future Debian releases, but will lag behind in features
- **pip install --user**: Works but less isolated than pipx
- **Manual virtual environment**: More complex, essentially what pipx does automatically

The installer keeps things simple and reliable by using pipx, which handles all the Python dependency management automatically.

---

## 🚀 Quick Start

```bash
git clone https://github.com/drewgrif/qtile-setup.git
cd qtile-setup
chmod +x install.sh
./install.sh
```

## Installation Options

```bash
./install.sh [OPTIONS]

Options:
  --skip-packages      Skip apt package installation
  --skip-themes        Skip theme, icon, and font installations
  --skip-butterscripts Skip all external script installations
  --dry-run           Show what would be done without making changes
  --only-config       Only copy config files (skip all installations)
  --help              Show usage information
```

### Advanced Usage Examples

```bash
# Preview what will be installed
./install.sh --dry-run

# Update only configuration files
./install.sh --only-config

# Skip package installation if already installed
./install.sh --skip-packages

# Install without themes and fonts
./install.sh --skip-themes
```

---

## 📦 What It Installs

| Component           | Purpose                          |
|---------------------|----------------------------------|
| `qtile`             | Dynamic tiling window manager    |
| `python3-psutil`    | System monitoring for qtile      |
| `rofi`              | App launcher + power menu        |
| `dunst`             | Lightweight notifications        |
| `picom` `(FT-Labs)` | Compositor with transparency     |
| `thunar`            | File Manager (+plugins)          |
| `wezterm`           | Main terminal emulator           |
| `firefox-esr`       | Default web browser              |
| `flameshot`         | Screenshot tools                 |
| `pamixer`           | Audio control                    |
| `feh`               | Wallpaper manager                |
| `xfce4-power-manager` | Power management                |
| `network-manager-gnome` | Network management            |
| `micro`             | Terminal text editor             |
| `nala`              | Better apt frontend              |
| `qimgv`             | Lightweight image viewer         |

---

## 🎨 Appearance & Theming

- GTK Theme: [Orchis](https://github.com/vinceliuice/Orchis-theme)
- Icon Theme: [Colloid](https://github.com/vinceliuice/Colloid-icon-theme)
- Compositor: FT-Labs Picom with transparency and animations

> 💡 _Special thanks to [vinceliuice](https://github.com/vinceliuice) for the excellent GTK and icon themes._

---

## 🔑 Keybindings Overview

Main keybindings are configured in `~/.config/qtile/config.py`

Launch the keybind cheatsheet anytime with:

```bash
~/.config/qtile/scripts/help
```

| Shortcut             | Action                          |
|----------------------|---------------------------------|
| `Super + Enter`      | Launch terminal (WezTerm)       |
| `Super + Space`      | Launch rofi                     |
| `Super + H`          | Open keybind help via Rofi      |
| `Super + Q`          | Close focused window            |
| `Super + Ctrl + R`   | Restart Qtile                   |
| `Super + Tab`        | Cycle through layouts           |
| `Super + 1–9,0,-,=`  | Switch to workspace (1-12)      |
| `Super + Shift + 1–9,0,-,=` | Move window to workspace (1-12) |
| `Super + J/K`        | Move focus up/down              |
| `Super + Shift + J/K`| Move window up/down            |
| `Super + H/L`        | Shrink/expand window            |

---

## 🖥️ Layouts

Cycle layouts using:

```text
Super + Tab
```

<details>
<summary>Click to expand layout descriptions</summary>

Available layouts in this configuration (6 total):

- **`BSP`** — Binary space partitioning (default)
- **`Columns`** — Dynamic column layout (3 columns)
- **`MonadTall`** — Classic master-stack
- **`Max`** — Fullscreen stacked windows
- **`Floating`** — Free window placement
- **`Zoomy`** — Zoom-focused layout

</details>

---

## 📂 Configuration Files

```
~/.config/qtile/
├── config.py               # Main Qtile configuration
├── colors.py               # Color scheme definitions
└── scripts/
    ├── autostart.sh         # Startup script
    ├── changevolume         # Volume control script
    ├── help                 # Keybind help viewer
    └── power                # Power menu script

~/.config/dunst/
└── dunstrc                 # Notification settings

~/.config/picom/
└── picom.conf              # Compositor configuration

~/.config/rofi/
├── config.rasi             # Main rofi configuration
├── keybinds.rasi           # Keybind cheatsheet theme
└── power.rasi              # Power menu theme

~/.config/qtile/wallpaper/  # Collection of wallpapers
```

---

## 🪟 Qtile Features

This configuration includes:

- **Dynamic Layouts**: Multiple tiling algorithms with easy switching
- **Smart Borders**: Borders only when needed
- **System Tray**: Integrated system tray in the status bar
- **Workspace Management**: 12 workspaces with intuitive navigation
- **Auto-floating**: Certain windows automatically float (dialogs, etc.)
- **Status Bar**: Custom status bar with system information
- **Notifications**: Desktop notifications via dunst
- **Power Management**: Integrated power menu and battery monitoring

---

## 🖼️ Screenshots & Wallpapers

The configuration includes a curated collection of wallpapers in `~/.config/qtile/wallpaper/`:
- High-resolution ultrawide wallpapers (3440x1440)
- Gruvbox-themed backgrounds
- Debian-branded wallpapers
- Nature and abstract designs

---

## 📺 Watch on YouTube

Want to see how it looks and works?  
🎥 Check out [JustAGuy Linux on YouTube](https://www.youtube.com/@JustAGuyLinux)