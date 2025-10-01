# 🪟 qtile-setup

> **🚨 REPOSITORY MIGRATION NOTICE**
>
> This repository has moved to **[Codeberg](https://codeberg.org/justaguylinux/qtile-setup)**
>
> - **Primary repository**: https://codeberg.org/justaguylinux/qtile-setup
> - **This GitHub repository**: Mirror only (read-only)
> - **Migration deadline**: December 15, 2025 - GitHub mirror will be archived
>
> Please update your bookmarks and git remotes:
> ```bash
> git remote set-url origin https://codeberg.org/justaguylinux/qtile-setup.git
> ```

![Made for Debian](https://img.shields.io/badge/Made%20for-Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)

![2025-06-06_11-10_2](https://github.com/user-attachments/assets/b0c5e6e5-066a-43c4-aded-d912328792c2)

A complete Qtile setup script for Debian-based systems.
Features dynamic tiling layouts, powerful keybindings, and a polished desktop experience — ready to roll out of the box.

> Part of the [JustAGuy Linux](https://codeberg.org/justaguylinux) window manager collection.

## 📦 System Requirements

- **Debian 12 (Bookworm)** - Uses pipx installation method
- **Debian 13 (Trixie)** - Uses native qtile package from repository
- **Ubuntu** and other Debian-based systems - Uses pipx installation method

The installer automatically detects your system version and chooses the appropriate installation method.

## Installation Method

The installer automatically chooses the best method based on your system:

### Debian 13 (Trixie) and newer ✅ Recommended
- Uses the native `qtile` package from Debian repositories (v0.31.0)
- Simple and clean: `sudo apt install qtile python3-psutil`
- **Stable and tested** - Debian's rigorous testing ensures reliability
- All dependencies handled automatically by the package manager
- Integrates seamlessly with the system
- Better system integration than pipx installation
- **Note:** `python3-psutil` is required for CPU and memory monitoring widgets in the qtile bar

### Debian 12 (Bookworm) and older
- Uses `pipx` to install Qtile 0.31.0 in an isolated environment
- **Why pipx?**
  - Qtile is not available in Debian 12 repositories
  - Provides access to qtile when system packages aren't available
  - Isolated environment prevents Python package conflicts
- **Version Note:** Installs Qtile 0.31.0 specifically as version 0.33+ has compatibility issues with Debian 12

### Manual Installation Options
If you prefer to handle Qtile installation yourself:
```bash
# Debian 13+ (recommended - stable and well-tested)
sudo apt install qtile python3-psutil

# Debian 12 or if system package unavailable (use version 0.31.0)
pipx install qtile==0.31.0 && pipx inject qtile psutil

# Then run the installer with config-only mode
./install.sh --only-config
```

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

```bash![2025-06-06_11-10_2](https://github.com/user-attachments/assets/4305ba92-56e3-43f0-9777-2b2f478b0abc)

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

## ☕ Support

If this setup has been helpful, consider buying me a coffee:

<a href="https://www.buymeacoffee.com/justaguylinux" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy me a coffee" /></a>

## 📺 Watch on YouTube

Want to see how it looks and works?  
🎥 Check out [JustAGuy Linux on YouTube](https://www.youtube.com/@JustAGuyLinux)
