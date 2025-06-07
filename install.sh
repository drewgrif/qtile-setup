#!/bin/bash

# ============================================
# JustAGuy Linux - Qtile Automated Setup Script
# https://github.com/drewgrif/qtile-setup
# ============================================

LOG_FILE="$HOME/justaguylinux-install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Make script location-independent
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLONED_DIR="$SCRIPT_DIR"
CONFIG_DIR="$HOME/.config"
QTILE_CONFIG_DIR="$HOME/.config/qtile"
BUTTERSCRIPTS_REPO="https://github.com/drewgrif/butterscripts"

# Installation options
SKIP_PACKAGES=false
SKIP_THEMES=false
SKIP_BUTTERSCRIPTS=false
DRY_RUN=false
ONLY_CONFIG=false

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-packages)
            SKIP_PACKAGES=true
            shift
            ;;
        --skip-themes)
            SKIP_THEMES=true
            shift
            ;;
        --skip-butterscripts)
            SKIP_BUTTERSCRIPTS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --only-config)
            ONLY_CONFIG=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --skip-packages      Skip apt package installation"
            echo "  --skip-themes        Skip theme, icon, and font installations"
            echo "  --skip-butterscripts Skip all butterscript installations"
            echo "  --dry-run           Show what would be done without making changes"
            echo "  --only-config       Only copy config files (skip all installations)"
            echo "  --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Create a unique base temporary directory for this run
MAIN_TEMP_DIR="/tmp/justaguylinux_qtile_$(date +%s)_$$"
mkdir -p "$MAIN_TEMP_DIR"

command_exists() {
    command -v "$1" &>/dev/null
}

# ============================================
# Error Handling
# ============================================
die() {
    echo "ERROR: $*" >&2
    exit 1
}

# ============================================
# Temporary Directory Management
# ============================================
create_temp_dir() {
    local name="$1"
    local temp_dir="$MAIN_TEMP_DIR/$name"
    mkdir -p "$temp_dir"
    echo "$temp_dir"
}

# Clean up all temporary directories on exit (success or failure)
cleanup() {
    echo "Cleaning up temporary files..."
    rm -rf "$MAIN_TEMP_DIR"
    echo "Cleanup completed."
}
trap cleanup EXIT

# ============================================
# Script Fetching Functions
# ============================================
get_butterscript() {
    local script_path="$1"
    local script_name=$(basename "$script_path")
    local temp_script="$MAIN_TEMP_DIR/scripts/$script_name"
    
    # Create directory for downloaded scripts
    mkdir -p "$MAIN_TEMP_DIR/scripts"
    
    echo "Fetching script: $script_path from butterscripts repository..."
    
    # Quietly download the script
    wget -q -O "$temp_script" "https://raw.githubusercontent.com/drewgrif/butterscripts/main/$script_path"
    local wget_status=$?
    
    # Check if the download was successful
    if [ $wget_status -ne 0 ] || [ ! -f "$temp_script" ] || [ ! -s "$temp_script" ]; then
        echo "ERROR: Failed to download script: $script_path (wget status: $wget_status)"
        return 1
    fi
    
    # Fix line endings
    sed -i 's/\r$//' "$temp_script" 2>/dev/null
    
    # Make executable
    chmod +x "$temp_script"
    
    # Success - return 0 instead of the path
    return 0
}

run_butterscript() {
    local script_path="$1"
    local script_name=$(basename "$script_path" .sh)
    local script_file="$MAIN_TEMP_DIR/scripts/$(basename "$script_path")"
    
    echo "Preparing to run: $script_path"
    
    # Download the script
    get_butterscript "$script_path"
    local get_status=$?
    
    if [ $get_status -ne 0 ]; then
        echo "ERROR: Failed to download script: $script_path"
        return 1
    fi
    
    # Check that the file exists directly
    if [ ! -f "$script_file" ]; then
        echo "ERROR: Script file does not exist: $script_file"
        return 1
    fi
    
    # Create a temporary directory for the script to use
    local script_temp_dir="$MAIN_TEMP_DIR/${script_name}_workdir"
    mkdir -p "$script_temp_dir"
    
    echo "Running script: $script_path"
    echo "Script file: $script_file"
    echo "Work directory: $script_temp_dir"
    
    # Run the script
    SCRIPT_TEMP_DIR="$script_temp_dir" bash "$script_file"
    local run_status=$?
    
    if [ $run_status -ne 0 ]; then
        echo "ERROR: Script execution failed with status: $run_status"
        return 1
    fi
    
    echo "Script execution completed successfully."
    return 0
}

# ============================================
# Color definitions
# ============================================
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================
# Confirm User Intention
# ============================================
clear
echo -e "${CYAN}
 +-+-+-+-+-+-+-+-+-+-+-+-+-+ 
 |j|u|s|t|a|g|u|y|l|i|n|u|x| 
 +-+-+-+-+-+-+-+-+-+-+-+-+-+ 
 |q|t|i|l|e| |s|e|t|u|p|  |  
 +-+-+-+-+-+-+-+-+-+-+-+-+-+                                                                            
${NC}"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

if [ "$ONLY_CONFIG" = true ]; then
    echo -e "${YELLOW}⚡ Configuration Mode:${NC} Will copy Qtile configuration files only"
else
    echo -e "${GREEN}📦 Full Installation:${NC} Will install packages and configure Qtile"
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE:${NC} No changes will be made to your system"
fi

# Show active options
if [ "$SKIP_PACKAGES" = true ] || [ "$SKIP_THEMES" = true ] || [ "$SKIP_BUTTERSCRIPTS" = true ]; then
    echo
    echo -e "${CYAN}Options enabled:${NC}"
    [ "$SKIP_PACKAGES" = true ] && echo -e "  • Skipping package installation"
    [ "$SKIP_THEMES" = true ] && echo -e "  • Skipping themes and fonts"
    [ "$SKIP_BUTTERSCRIPTS" = true ] && echo -e "  • Skipping external scripts"
fi

echo
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

read -p "$(echo -e "${YELLOW}▶ Do you want to continue? (y/n) ${NC}")" confirm
[[ ! "$confirm" =~ ^[Yy]$ ]] && die "Installation aborted."

if [ "$ONLY_CONFIG" = false ] && [ "$SKIP_PACKAGES" = false ]; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would run: sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get clean"
    else
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get clean
    fi
fi

# ============================================
# Install Required Packages
# ============================================
install_core_packages() {
    echo "Installing core X11 and Python packages..."
    sudo apt-get install -y \
        xorg \
        xorg-dev \
        xbacklight \
        xbindkeys \
        xvkbd \
        xinput \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        python3-setuptools \
        python3-wheel \
        python3-xcffib \
        python3-cairocffi \
        libpangocairo-1.0-0 \
        libcairo-gobject2 \
        libgtk-3-dev \
        libgirepository1.0-dev \
        gir1.2-gtk-3.0 \
        libdbus-1-dev \
        libdbus-glib-1-dev \
        libnotify-bin \
        libnotify-dev \
        python3-dbus \
        pipx \
        || { echo "ERROR: Core package installation failed."; return 1; }
}

install_qtile_dependencies() {
    echo "Installing system libraries for Qtile..."
    sudo apt-get install -y \
        libpangocairo-1.0-0 \
        libxkbcommon-dev \
        libxkbcommon-x11-dev \
        || { echo "ERROR: Qtile system dependencies failed."; return 1; }
}

install_ui_packages() {
    echo "Installing UI components..."
    sudo apt-get install -y \
        rofi \
        dunst \
        feh \
        lxappearance \
        network-manager-gnome \
        || { echo "ERROR: UI package installation failed."; return 1; }
}

install_file_manager_packages() {
    echo "Installing file management packages..."
    sudo apt-get install -y \
        thunar \
        thunar-archive-plugin \
        thunar-volman \
        gvfs-backends \
        dialog \
        mtools \
        smbclient \
        cifs-utils \
        unzip \
        || { echo "ERROR: File manager package installation failed."; return 1; }
}

install_audio_packages() {
    echo "Installing audio packages..."
    sudo apt-get install -y \
        pavucontrol \
        pulsemixer \
        pamixer \
        pipewire-audio \
        || { echo "ERROR: Audio package installation failed."; return 1; }
}

install_utility_packages() {
    echo "Installing utility packages..."
    sudo apt-get install -y \
        avahi-daemon \
        acpi \
        acpid \
        xfce4-power-manager \
        flameshot \
        qimgv \
        firefox-esr \
        nala \
        micro \
        xdg-user-dirs-gtk \
        || { echo "ERROR: Utility package installation failed."; return 1; }
}

install_terminal_packages() {
    echo "Installing terminal and shell utilities..."
    sudo apt-get install -y \
        suckless-tools \
        exa \
        || { echo "ERROR: Terminal package installation failed."; return 1; }
}

install_font_packages() {
    echo "Installing font packages..."
    sudo apt-get install -y \
        fonts-recommended \
        fonts-font-awesome \
        fonts-terminus \
        fonts-dejavu \
        || { echo "ERROR: Font package installation failed."; return 1; }
}

install_python_packages() {
    echo "Ensuring pipx is configured..."
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would ensure pipx path"
        return
    fi
    
    # Ensure pipx is in PATH and configured
    pipx ensurepath
}

install_packages() {
    if [ "$SKIP_PACKAGES" = true ] || [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping package installation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install packages in groups: core, qtile, ui, file manager, audio, utilities, terminal, fonts, python"
        return
    fi
    
    echo "Installing required packages..."
    
    # Install each group, but continue if one fails
    install_core_packages || echo "Warning: Some core packages failed to install"
    install_qtile_dependencies || echo "Warning: Some Qtile dependencies failed to install"
    install_ui_packages || echo "Warning: Some UI packages failed to install"
    install_file_manager_packages || echo "Warning: Some file manager packages failed to install"
    install_audio_packages || echo "Warning: Some audio packages failed to install"
    install_utility_packages || echo "Warning: Some utility packages failed to install"
    install_terminal_packages || echo "Warning: Some terminal packages failed to install"
    install_font_packages || echo "Warning: Some font packages failed to install"
    install_python_packages || echo "Warning: Some Python packages failed to install"
    
    echo "Package installation completed."
}

install_reqs() {
    if [ "$SKIP_PACKAGES" = true ] || [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping build dependencies installation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install build dependencies: cmake, meson, ninja-build, curl, pkg-config, build-essential"
        return
    fi
    
    echo "Updating package lists and installing required dependencies..."
    sudo apt-get install -y cmake meson ninja-build curl pkg-config build-essential || { echo "Package installation failed."; exit 1; }
}

# ============================================
# Enable System Services
# ============================================
enable_services() {
    if [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping service configuration..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would enable services: avahi-daemon, acpid"
        return
    fi
    
    echo "Enabling required services..."
    sudo systemctl enable avahi-daemon || echo "Warning: Failed to enable avahi-daemon."
    sudo systemctl enable acpid || echo "Warning: Failed to enable acpid."
}

# ============================================
# Set Up User Directories
# ============================================
setup_user_dirs() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would update user directories and create Screenshots folder"
        return
    fi
    
    xdg-user-dirs-update
    mkdir -p ~/Screenshots/
    mkdir -p ~/Pictures/Wallpapers/
}

# ============================================
# Check for Existing Qtile Config
# ============================================
check_qtile() {
    if [ -d "$QTILE_CONFIG_DIR" ]; then
        echo "An existing ~/.config/qtile directory was found."
        read -p "Backup existing configuration? (y/n) " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            backup_dir="$HOME/.config/qtile_backup_$(date +%Y-%m-%d_%H-%M-%S)"
            mv "$QTILE_CONFIG_DIR" "$backup_dir" || die "Failed to backup existing config."
            echo "Backup saved to $backup_dir"
        fi
    fi
}

create_qtile_desktop() {
    if [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping qtile.desktop file creation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would create /usr/share/xsessions/qtile.desktop"
        return
    fi
    
    # Ensure /usr/share/xsessions directory exists
    if [ ! -d /usr/share/xsessions ]; then
        sudo mkdir -p /usr/share/xsessions
        if [ $? -ne 0 ]; then
            echo "Failed to create /usr/share/xsessions directory. Exiting."
            exit 1
        fi
    fi

    # Adding qtile.desktop to Lightdm xsessions directory
    cat > ./temp << "EOF"
[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Type=Application
Keywords=wm;tiling
EOF
    sudo cp ./temp /usr/share/xsessions/qtile.desktop
    rm ./temp
    
    u=$USER
    sudo echo "Exec=/home/$u/.local/bin/qtile start" | sudo tee -a /usr/share/xsessions/qtile.desktop
}

# ============================================
# Move Config Files
# ============================================
setup_qtile_config() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would copy Qtile configuration files to $CONFIG_DIR"
        return
    fi
    
    mkdir -p "$CONFIG_DIR"
    
    # Copy qtile-specific configurations
    for dir in qtile dunst picom rofi scripts sxhkd wallpaper; do
        if [ -d "$CLONED_DIR/$dir" ]; then
            cp -r "$CLONED_DIR/$dir" "$CONFIG_DIR/" || echo "Warning: Failed to copy $dir."
        fi
    done

    # Set proper permissions for scripts
    if [ -d "$CONFIG_DIR/qtile/scripts" ]; then
        chmod +x "$CONFIG_DIR/qtile/scripts/"*.sh 2>/dev/null || true
        chmod +x "$CONFIG_DIR/qtile/scripts/"* 2>/dev/null || true
    fi
    
    echo "Qtile configuration files have been copied successfully."
}

# ============================================
# Install ft-picom
# ============================================
install_ftlabs_picom() {
    if [ "$SKIP_BUTTERSCRIPTS" = true ] || [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping picom installation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install ftlabs picom from butterscripts"
        return
    fi
    
    run_butterscript "setup/install_picom.sh"
}

# ============================================
# Install Wezterm
# ============================================
install_wezterm() {
    if [ "$SKIP_BUTTERSCRIPTS" = true ] || [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping wezterm installation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install wezterm from butterscripts"
        return
    fi
    
    run_butterscript "wezterm/install_wezterm.sh"
}

# ============================================
# Install st
# ============================================
install_st() {
    if [ "$SKIP_BUTTERSCRIPTS" = true ] || [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping st terminal installation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install st terminal from butterscripts"
        return
    fi
    
    run_butterscript "st/install_st.sh"
}

# ============================================
# Install Fonts
# ============================================
install_fonts() {
    if [ "$SKIP_THEMES" = true ] || [ "$SKIP_BUTTERSCRIPTS" = true ] || [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping font installation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install nerd fonts from butterscripts"
        return
    fi
    
    echo "Installing fonts..."
    run_butterscript "theming/install_nerdfonts.sh"
}

# ============================================
# Install GTK Theme & Icons
# ============================================
install_theming() {
    if [ "$SKIP_THEMES" = true ] || [ "$SKIP_BUTTERSCRIPTS" = true ] || [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping theme installation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install GTK themes and icons from butterscripts"
        return
    fi
    
    run_butterscript "theming/install_theme.sh"
}

# ============================================
# Install Login Manager
# ============================================
install_displaymanager() {
    if [ "$SKIP_BUTTERSCRIPTS" = true ] || [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping display manager installation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install LightDM from butterscripts"
        return
    fi
    
    run_butterscript "system/install_lightdm.sh"
}

# ============================================
# Replace .bashrc
# ============================================
replace_bashrc() {
    if [ "$SKIP_BUTTERSCRIPTS" = true ] || [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping bashrc configuration..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would update bashrc from butterscripts"
        return
    fi
    
    run_butterscript "system/add_bashrc.sh"
}

# ============================================
# Install Optional Packages
# ============================================
install_optionals() {
    if [ "$SKIP_BUTTERSCRIPTS" = true ] || [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping optional tools installation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install optional tools from butterscripts"
        return
    fi
    
    run_butterscript "setup/optional_tools.sh"
}

# ============================================
# Install Qtile using pipx
# ============================================
install_qtile() {
    if [ "$ONLY_CONFIG" = true ]; then
        echo "Skipping Qtile installation..."
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install Qtile using pipx"
        return
    fi
    
    echo "Installing Qtile using pipx..."
    
    # Ensure pipx path is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Install qtile with pipx
    pipx install qtile
    
    echo "Installing psutil in qtile environment..."
    # Inject psutil into qtile's virtual environment
    pipx inject qtile psutil
    
    echo "Qtile installation completed successfully."
}

# ============================================
# Main Execution
# ============================================
install_packages
install_reqs
install_qtile
enable_services
setup_user_dirs
check_qtile
setup_qtile_config
create_qtile_desktop
install_ftlabs_picom
install_wezterm
install_st
install_fonts
install_theming
install_displaymanager
replace_bashrc
install_optionals

echo "All installations completed successfully!"
