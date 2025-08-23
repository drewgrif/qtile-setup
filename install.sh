#!/bin/bash

# JustAGuy Linux - Qtile Setup
# https://github.com/drewgrif/qtile-setup

set -e

# Command line options
ONLY_CONFIG=false
EXPORT_PACKAGES=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --only-config)
            ONLY_CONFIG=true
            shift
            ;;
        --export-packages)
            EXPORT_PACKAGES=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "  --only-config      Only copy config files (skip packages and external tools)"
            echo "  --export-packages  Export package lists for different distros and exit"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
QTILE_CONFIG_DIR="$HOME/.config/qtile"
TEMP_DIR="/tmp/qtile_$$"
LOG_FILE="$HOME/qtile-install.log"

# Logging and cleanup
exec > >(tee -a "$LOG_FILE") 2>&1
trap "rm -rf $TEMP_DIR" EXIT

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

die() { echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }
msg() { echo -e "${CYAN}$*${NC}"; }

# Export package lists for different distros
export_packages() {
    echo "=== Qtile Setup - Package Lists for Different Distributions ==="
    echo
    
    # Combine all packages
    local all_packages=(
        "${PACKAGES_CORE[@]}"
        "${PACKAGES_QTILE[@]}"
        "${PACKAGES_UI[@]}"
        "${PACKAGES_FILE_MANAGER[@]}"
        "${PACKAGES_AUDIO[@]}"
        "${PACKAGES_UTILITIES[@]}"
        "${PACKAGES_TERMINAL[@]}"
        "${PACKAGES_FONTS[@]}"
        "${PACKAGES_BUILD[@]}"
    )
    
    echo "DEBIAN 12/UBUNTU:"
    echo "sudo apt install ${all_packages[*]}"
    echo "Note: After packages, run: pipx install qtile==0.31.0 && pipx inject qtile psutil"
    echo "IMPORTANT: Qtile 0.33+ has compatibility issues with Debian 12 - use version 0.31.0"
    echo
    
    echo "DEBIAN 13+ (Trixie and newer):"
    echo "sudo apt install qtile python3-psutil ${all_packages[*]}"
    echo "Note: Qtile is available as a system package, python3-psutil needed for CPU/memory widgets"
    echo
    
    # Arch equivalents
    local arch_packages=(
        "xorg-server xorg-xinit xorg-xbacklight xbindkeys xvkbd xorg-xinput"
        "python python-pip python-xcffib python-cairocffi python-dbus python-pipx"
        "libxkbcommon pango cairo gtk3 gobject-introspection libnotify"
        "rofi dunst feh lxappearance network-manager-applet"
        "thunar thunar-archive-plugin thunar-volman"
        "gvfs dialog mtools smbclient cifs-utils unzip"
        "pavucontrol pulsemixer pamixer pipewire-pulse"
        "avahi acpi acpid xfce4-power-manager flameshot"
        "qimgv firefox micro xdg-user-dirs-gtk"
        "suckless-tools eza"
        "ttf-font-awesome terminus-font ttf-dejavu"
        "cmake meson ninja curl pkgconf base-devel"
    )
    
    echo "ARCH LINUX:"
    echo "sudo pacman -S ${arch_packages[*]}"
    echo
    
    # Fedora equivalents  
    local fedora_packages=(
        "xorg-x11-server-Xorg xorg-x11-xinit xbacklight xbindkeys xvkbd xinput"
        "python3 python3-pip python3-xcffib python3-cairocffi python3-dbus pipx"
        "libxkbcommon-devel pango cairo gtk3-devel gobject-introspection-devel libnotify"
        "rofi dunst feh lxappearance NetworkManager-gnome"
        "thunar thunar-archive-plugin thunar-volman"
        "gvfs dialog mtools samba-client cifs-utils unzip"
        "pavucontrol pulsemixer pamixer pipewire-pulseaudio"
        "avahi acpi acpid xfce4-power-manager flameshot"
        "qimgv firefox micro xdg-user-dirs-gtk"
        "eza"
        "fontawesome-fonts terminus-fonts dejavu-fonts-all"
        "cmake meson ninja-build curl pkgconfig gcc make git"
    )
    
    echo "FEDORA:"
    echo "sudo dnf install ${fedora_packages[*]}"
    echo
    
    echo "NOTE: Some packages may have different names or may not be available"
    echo "in all distributions. You may need to:"
    echo "  - Find equivalent packages in your distro's repositories"
    echo "  - Install some tools from source"
    echo "  - Use alternative package managers (AUR for Arch, Flatpak, etc.)"
    echo
    echo "After installing packages, you can use:"
    echo "  $0 --only-config    # To copy just the Qtile configuration files"
}

# Check if we should export packages and exit
if [ "$EXPORT_PACKAGES" = true ]; then
    export_packages
    exit 0
fi

# Banner
clear
echo -e "${CYAN}"
echo " +-+-+-+-+-+-+-+-+-+-+-+-+-+ "
echo " |j|u|s|t|a|g|u|y|l|i|n|u|x| "
echo " +-+-+-+-+-+-+-+-+-+-+-+-+-+ "
echo " |q|t|i|l|e| |s|e|t|u|p|    | "
echo " +-+-+-+-+-+-+-+-+-+-+-+-+-+ "
echo -e "${NC}\n"

read -p "Install Qtile? (y/n) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

# Detect Debian version
DEBIAN_VERSION=$(lsb_release -rs 2>/dev/null || echo "0")
DEBIAN_MAJOR_VERSION=$(echo "$DEBIAN_VERSION" | cut -d. -f1)
IS_DEBIAN_13_OR_NEWER=false

if [ "$DEBIAN_MAJOR_VERSION" -ge 13 ] 2>/dev/null; then
    IS_DEBIAN_13_OR_NEWER=true
    msg "Detected Debian $DEBIAN_VERSION - will use system qtile package"
else
    msg "Detected Debian $DEBIAN_VERSION - will install qtile via pipx"
fi

# Update system
if [ "$ONLY_CONFIG" = false ]; then
    msg "Updating system..."
    sudo apt-get update && sudo apt-get upgrade -y
else
    msg "Skipping system update (--only-config mode)"
fi

# Package groups for better organization
PACKAGES_CORE=(
    xorg xorg-dev xbacklight xbindkeys xvkbd xinput
    build-essential xdotool
    libnotify-bin libnotify-dev
)

# For Debian 13+, qtile package handles most Python dependencies but needs psutil for CPU/memory widgets
if [ "$IS_DEBIAN_13_OR_NEWER" = true ]; then
    PACKAGES_QTILE=(
        python3-psutil  # Required for CPU and memory monitoring in qtile bar
    )
else
    PACKAGES_QTILE=(
        python3 python3-pip python3-venv python3-dev python3-setuptools
        python3-wheel python3-xcffib python3-cairocffi libpangocairo-1.0-0
        libcairo-gobject2 libgtk-3-dev libgirepository1.0-dev gir1.2-gtk-3.0
        libdbus-1-dev libdbus-glib-1-dev python3-dbus pipx
        libxkbcommon-dev libxkbcommon-x11-dev
    )
fi

PACKAGES_UI=(
    rofi dunst feh lxappearance network-manager-gnome
)

PACKAGES_FILE_MANAGER=(
    thunar thunar-archive-plugin thunar-volman
    gvfs-backends dialog mtools smbclient cifs-utils ripgrep fd-find unzip
)

PACKAGES_AUDIO=(
    pavucontrol pulsemixer pamixer pipewire-audio
)

PACKAGES_UTILITIES=(
    avahi-daemon acpi acpid xfce4-power-manager
    flameshot qimgv nala micro xdg-user-dirs-gtk
)

PACKAGES_TERMINAL=(
    suckless-tools
)

PACKAGES_FONTS=(
    fonts-recommended fonts-font-awesome fonts-terminus fonts-dejavu
)

PACKAGES_BUILD=(
    cmake meson ninja-build curl pkg-config
)


# Install packages by group
if [ "$ONLY_CONFIG" = false ]; then
    msg "Installing core packages..."
    sudo apt-get install -y "${PACKAGES_CORE[@]}" || die "Failed to install core packages"

    msg "Installing Qtile dependencies..."
    sudo apt-get install -y "${PACKAGES_QTILE[@]}" || die "Failed to install Qtile dependencies"

    msg "Installing UI components..."
    sudo apt-get install -y "${PACKAGES_UI[@]}" || die "Failed to install UI packages"

    msg "Installing file manager..."
    sudo apt-get install -y "${PACKAGES_FILE_MANAGER[@]}" || die "Failed to install file manager"

    msg "Installing audio support..."
    sudo apt-get install -y "${PACKAGES_AUDIO[@]}" || die "Failed to install audio packages"

    msg "Installing system utilities..."
    sudo apt-get install -y "${PACKAGES_UTILITIES[@]}" || die "Failed to install utilities"
    
    # Try firefox-esr first (Debian), then firefox (Ubuntu)
    sudo apt-get install -y firefox-esr 2>/dev/null || sudo apt-get install -y firefox 2>/dev/null || msg "Note: firefox not available, skipping..."

    msg "Installing terminal tools..."
    sudo apt-get install -y "${PACKAGES_TERMINAL[@]}" || die "Failed to install terminal tools"
    
    # Try exa first (Debian 12), then eza (newer Ubuntu)
    sudo apt-get install -y exa 2>/dev/null || sudo apt-get install -y eza 2>/dev/null || msg "Note: exa/eza not available, skipping..."

    msg "Installing fonts..."
    sudo apt-get install -y "${PACKAGES_FONTS[@]}" || die "Failed to install fonts"

    msg "Installing build dependencies..."
    sudo apt-get install -y "${PACKAGES_BUILD[@]}" || die "Failed to install build tools"

    # Enable services
    sudo systemctl enable avahi-daemon acpid

    # Install Qtile - use system package for Debian 13+, pipx for older versions
    if [ "$IS_DEBIAN_13_OR_NEWER" = true ]; then
        msg "Installing Qtile from Debian packages (with python3-psutil for widgets)..."
        sudo apt-get install -y qtile || die "Failed to install qtile package"
        msg "Qtile installation from system packages completed successfully"
    else
        msg "Installing Qtile 0.31.0 using pipx (0.33+ has compatibility issues with Debian 12)..."
        export PATH="$HOME/.local/bin:$PATH"
        pipx ensurepath
        # Install specific version that works with Debian 12
        pipx install qtile==0.31.0
        pipx inject qtile psutil
        
        # Verify installation and version
        if command -v qtile >/dev/null 2>&1; then
            QTILE_VERSION=$(qtile --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
            msg "Qtile $QTILE_VERSION installation via pipx completed successfully"
            if [[ "$QTILE_VERSION" != "0.31.0" ]]; then
                msg "WARNING: Expected Qtile 0.31.0 but got $QTILE_VERSION - there may be compatibility issues"
            fi
        else
            die "Qtile installation failed - qtile command not found"
        fi
    fi
else
    msg "Skipping package installation (--only-config mode)"
fi

# Setup directories
xdg-user-dirs-update
mkdir -p ~/Screenshots

# Handle existing config
if [ -d "$QTILE_CONFIG_DIR" ]; then
    clear
    read -p "Found existing qtile config. Backup? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv "$QTILE_CONFIG_DIR" "$QTILE_CONFIG_DIR.bak.$(date +%s)"
        msg "Backed up existing config"
    else
        clear
        read -p "Overwrite without backup? (y/n) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || die "Installation cancelled"
        rm -rf "$QTILE_CONFIG_DIR"
    fi
fi

# Copy configs
msg "Setting up configuration..."
mkdir -p "$CONFIG_DIR"

# Copy qtile configuration directory
if [ -d "$SCRIPT_DIR/qtile" ]; then
    cp -r "$SCRIPT_DIR/qtile" "$CONFIG_DIR/" || die "Failed to copy qtile configuration"
else
    die "qtile directory not found"
fi

# Make scripts executable
if [ -d "$CONFIG_DIR/qtile/scripts" ]; then
    chmod +x "$CONFIG_DIR/qtile/scripts/"* 2>/dev/null || true
fi

# Create desktop entry for Qtile
if [ "$ONLY_CONFIG" = false ]; then
    # For Debian 13+, the system package should create its own desktop entry
    # Only create one for pipx installations
    if [ "$IS_DEBIAN_13_OR_NEWER" = false ]; then
        sudo mkdir -p /usr/share/xsessions
        cat <<EOF | sudo tee /usr/share/xsessions/qtile.desktop >/dev/null
[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Exec=$HOME/.local/bin/qtile start
Type=Application
Keywords=wm;tiling
EOF
    else
        msg "Using system-provided qtile desktop entry"
    fi
fi

# Butterscript helper
get_script() {
    wget -qO- "https://raw.githubusercontent.com/drewgrif/butterscripts/main/$1" | bash
}

# Install essential components
if [ "$ONLY_CONFIG" = false ]; then
    mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"

    msg "Installing picom..."
    get_script "setup/install_picom.sh"

    msg "Installing wezterm..."
    get_script "wezterm/install_wezterm.sh"

    msg "Installing st terminal..."
    wget -O "$TEMP_DIR/install_st.sh" "https://raw.githubusercontent.com/drewgrif/butterscripts/main/st/install_st.sh"
    chmod +x "$TEMP_DIR/install_st.sh"
    # Run in current terminal session to preserve interactivity
    bash "$TEMP_DIR/install_st.sh"

    msg "Installing fonts..."
    get_script "theming/install_nerdfonts.sh"

    msg "Installing themes..."
    get_script "theming/install_theme.sh"

    msg "Downloading wallpaper directory..."
    cd "$QTILE_CONFIG_DIR"
    git clone --depth 1 --filter=blob:none --sparse https://github.com/drewgrif/butterscripts.git "$TEMP_DIR/butterscripts-wallpaper" || die "Failed to clone butterscripts"
    cd "$TEMP_DIR/butterscripts-wallpaper"
    git sparse-checkout set wallpaper || die "Failed to set sparse-checkout"
    cp -r wallpaper "$QTILE_CONFIG_DIR/" || die "Failed to copy wallpaper directory"

    msg "Downloading display manager installer..."
    wget -O "$TEMP_DIR/install_lightdm.sh" "https://raw.githubusercontent.com/drewgrif/butterscripts/main/system/install_lightdm.sh"
    chmod +x "$TEMP_DIR/install_lightdm.sh"
    msg "Running display manager installer..."
    # Run in current terminal session to preserve interactivity
    bash "$TEMP_DIR/install_lightdm.sh"

    # Optional tools
    clear
    read -p "Install optional tools (browsers, editors, etc)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        msg "Downloading optional tools installer..."
        wget -O "$TEMP_DIR/optional_tools.sh" "https://raw.githubusercontent.com/drewgrif/butterscripts/main/setup/optional_tools.sh"
        chmod +x "$TEMP_DIR/optional_tools.sh"
        msg "Running optional tools installer..."
        # Run in current terminal session to preserve interactivity
        if bash "$TEMP_DIR/optional_tools.sh"; then
            msg "Optional tools completed successfully"
        else
            msg "Optional tools exited (this is normal if cancelled by user)"
        fi
    fi
else
    msg "Skipping external tool installation (--only-config mode)"
fi

# Done
echo -e "\n${GREEN}Installation complete!${NC}"
echo "1. Log out and select 'Qtile' from your display manager"
echo "2. Press Super+Return to open terminal"
echo "3. Press Super+spacebar to open rofi"
