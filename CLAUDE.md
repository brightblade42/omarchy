# CLAUDE.md
This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is Fedarchy
Fedarchy is a **Fedora port of Omarchy** that preserves 100% of Omarchy's functionality while running on stable Fedora with enhanced security via containerized AUR access. It maintains Omarchy's beautiful aesthetic and workflow while offering better stability and package management.

**STATUS: Migration Complete** - Core infrastructure, package management, and configuration scripts have been successfully migrated to Fedora.

**Latest Additions**: Enhanced development toolkit with Zed editor, Doom Emacs, WezTerm/Alacritty terminals, Zellij multiplexer, Fossil VCS, and SQLite database.

## Migration Goal
**Transform this Omarchy codebase to run on Fedora 42+ with Distrobox for AUR packages, while preserving all functionality and user experience.**

## Core Architecture Changes

### Package Management Strategy (CRITICAL)
**AUR-First Approach for Maximum Omarchy Compatibility:**
```bash
# Priority order for package installation:
1. AUR via Distrobox (PREFERRED) - maintains Omarchy compatibility
2. DNF (Fedora native) - ONLY for essential system integration
3. Flatpak - fallback for unavailable packages

# Transform all package installations:
pacman -S package    →    aur install package     # PREFERRED
yay -S package       →    aur install package     # Direct replacement
```

### System Integration Requirements
**DNF ONLY for these essential packages:**
- System components: `systemd`, `dbus`, `polkit`, `NetworkManager`, `bluez`
- Polkit agents: `lxpolkit` (recommended), `polkit-kde`, `mate-polkit` (NO polkit-gnome - removed in Fedora 41+)
- Wayland stack: `wayland`, `xwayland`, `pipewire`, `wireplumber`
- Window manager: `hyprland` (MUST be native for proper display server integration)
- Container infrastructure: `podman`, `podman-compose`, `distrobox` (Podman preferred over Docker)
- Development tools: `gcc`, `make`, `cmake`, `git`
- Graphics drivers: `akmod-nvidia` (proprietary) for NVIDIA GPUs - open drivers not used due to stability concerns

**Everything else uses AUR for Omarchy compatibility.**

### Enhanced AUR Integration
```bash
# All AUR packages automatically exported via distrobox-export
aur install walker-bin    # Installs AND exports as native Fedora app
aur install discord       # Available immediately in application menu
```

### Container Management
- Arch Linux container (`arch-aur`) for AUR package access
- Auto-start container on login for performance
- Automatic export of installed AUR applications
- Native performance with no container overhead for apps

## Key Migration Transformations

### Script Transformation Patterns
```bash
# IN EVERY SCRIPT, replace these patterns:

# Package Management:
pacman -S package         →  aur install package
yay -S package           →  aur install package
pacman -Syu              →  fedarchy update
makepkg -si              →  (handled by aur wrapper)
docker/docker-compose    →  podman/podman-compose

# System Packages (exceptions):
pacman -S systemd        →  sudo dnf install systemd
pacman -S hyprland       →  sudo dnf install hyprland (MUST be native)
pacman -S podman         →  sudo dnf install podman

# Configuration Paths (check for Fedora differences):
/usr/lib/polkit-gnome/   →  lxpolkit (or appropriate agent)
```

### Repository Setup
```bash
# Replace Arch repository setup with:
setup_fedora_repos() {
    # Enable RPM Fusion
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # Setup Flatpak
    sudo dnf install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    # Setup Distrobox for AUR access
    setup_distrobox_container
}
```

## Implementation Strategy

### Phase 1: Core Infrastructure
**Priority scripts to migrate first:**
1. `install.sh` - Main installer (replace package management)
2. `install/packages.sh` - Core package installation logic
3. `bin/omarchy-pkg-install` - Package installer utility
4. `bin/omarchy-pkg-aur-install` - AUR installer (enhance with auto-export)
5. `install/preflight/pacman.sh` - Replace with Fedora repo setup

### Phase 2: Package Management Utilities
**Transform these `bin/omarchy-pkg-*` scripts:**
- `omarchy-pkg-add` - Add AUR auto-export logic
- `omarchy-pkg-install` - Use AUR-first strategy
- `omarchy-pkg-remove` - Handle exported app cleanup
- `omarchy-update` - Update DNF + Flatpak + AUR

### Phase 3: Configuration Scripts
**Update for Fedora paths and services:**
- `install/config/` - Check all paths for Fedora compatibility
- `config/hypr/` - Update polkit agent references
- `bin/omarchy-refresh-*` - Verify configuration deployment

### Phase 4: Rename and Rebrand
**After functionality is working:**
- Rename `omarchy-*` commands to `fedarchy-*`
- Update all references and documentation
- Preserve command-line interface compatibility

## Development Guidelines

### Critical Migration Rules
1. **Preserve User Experience**: All `omarchy-*` commands must work identically
2. **AUR-First**: Use AUR for maximum compatibility unless system integration requires DNF
3. **Auto-Export**: All AUR installations must be automatically exported
4. **Error Handling**: Add robust container health checks
5. **Performance**: Optimize container startup and app launch times
6. **Simplicity**: Removed Plymouth/bootloader customizations - use standard Fedora login
7. **Cleanup**: Removed `install/login/` directory and related Plymouth utilities for simplified installation
8. **Hardware**: Always use proprietary NVIDIA drivers - open-source drivers are experimental and unreliable
9. **Hardware Cleanup**: Removed unnecessary/harmful scripts - bluetooth.sh (auto-enabled), network.sh (conflicts with NetworkManager)
10. **Package Versions**: Use stable versions (matching original Omarchy) - Future: add `--stable` flag for user choice between stable/git versions

### Testing Requirements
- Test on clean Fedora 42 installation
- Verify all AUR packages export correctly
- Ensure container auto-starts on boot
- Validate identical functionality to Omarchy

### File Naming Convention
- Keep original script names during migration
- Add `# FEDARCHY:` comments for significant changes
- Preserve original error handling patterns
- Maintain modular architecture

## Fedarchy-Specific Components

### Enhanced AUR Wrapper
Location: `bin/omarchy-pkg-aur-install` (to be enhanced)
```bash
# Automatically export AUR packages after installation:
install_and_export() {
    distrobox enter arch-aur -- yay -S --noconfirm "$package"
    distrobox-export --app "$package" 2>/dev/null || \
        echo "Package installed but not exported (no desktop entry)"
}
```

### Container Management
New utilities to add:
- `bin/fedarchy-container-status` - Check container health
- `bin/fedarchy-container-start` - Smart container startup
- `bin/fedarchy-warm-containers` - Background container warming

### System Integration
- Systemd user services for container auto-start
- Polkit agent detection and setup
- Fedora-specific hardware configuration

## Key Differences from Omarchy

### Advantages
- **More stable base** (Fedora vs rolling Arch)
- **Enhanced security** (AUR packages containerized)
- **Multiple package sources** (DNF + Flatpak + AUR)
- **Native app performance** (auto-exported AUR apps)

### Maintained Compatibility
- **Same applications** (via AUR)
- **Same configurations** (Hyprland, Waybar, themes)
- **Same user interface** (all commands work identically)
- **Same aesthetic** (themes, styling preserved)

## Environment Variables
- `OMARCHY_PATH`: Installation directory (`$HOME/.local/share/omarchy`) - **Keep unchanged**
- `OMARCHY_REPO`: Source repository (your Fedarchy fork)
- `OMARCHY_REF`: Git branch/ref (default: `main`)
- `AUR_CONTAINER`: Container name (`arch-aur`) - **New addition**

## Migration State Tracking
- Preserve existing migration system
- Add Fedarchy-specific migrations for container setup
- Track container and export status in state files

---

**Remember**: The goal is to make Fedarchy feel identical to Omarchy while providing better stability and security through the Fedora base and containerized AUR access.
