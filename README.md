# qtile-setup

Automated installation script for Qtile window manager on Debian-based systems.

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

## Quick Start

```bash
git clone https://github.com/drewgrif/qtile-setup
cd qtile-setup
chmod +x install.sh
./install.sh
```

## Installation Options

- `--skip-packages` - Skip apt package installation
- `--skip-themes` - Skip theme, icon, and font installations  
- `--skip-butterscripts` - Skip external tool installations
- `--only-config` - Only copy configuration files
- `--dry-run` - Preview what would be installed
- `--help` - Show all options