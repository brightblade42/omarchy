# Fedarchy: Omarchy for Fedora

> **Bringing DHH's exceptional Omarchy desktop environment to Fedora with 100% compatibility**

Fedarchy is a complete port of [Omarchy](https://github.com/dhh/omarchy) from Arch Linux to Fedora, maintaining perfect compatibility while leveraging Fedora's stability and enterprise-grade foundation.

## 🎯 Project Goals

- **100% Omarchy Compatibility**: All functionality, configurations, and workflows preserved
- **Enhanced Stability**: Fedora's tested package base with predictable releases  
- **Security Benefits**: Container isolation for experimental packages
- **Broader Accessibility**: Enterprise users can access Omarchy's excellence

## 🏗️ Architecture Overview

### Hybrid Package Strategy

Fedarchy uses a sophisticated three-tier package distribution:

| **Host System (DNF + COPR)** | **Containerized (AUR)** | **Fallback (Flatpak)** |
|-------------------------------|--------------------------|-------------------------|
| Core Hyprland ecosystem | Development tools | Standard applications |
| Display server integration | Terminal utilities | Office/productivity |
| System libraries | Specialized apps | Media tools |
| Critical utilities | Latest versions | Cross-platform apps |

### Why This Approach?

**Host Installation** for components requiring:
- Direct hardware access (graphics, input)
- Display server integration (Wayland protocols)  
- System service integration (session management)
- IPC socket communication (Hyprland utilities)

**Container Installation** for:
- Independent applications
- Development environments
- Cutting-edge tools from AUR
- Non-critical utilities

## 🚀 Key Features

### Seamless AUR Access
```bash
aur install walker-bin      # Install with automatic export
aur commit-container        # Backup container state
aur restore-container       # Instant recovery
```

### Automatic Application Export
- GUI applications appear in application menu
- CLI tools available in host PATH
- Native performance, no container overhead

### Container Persistence  
- SystemD service ensures container auto-start
- Backup/restore functionality for quick recovery
- No more lost containers after reboots

### Perfect Omarchy Compatibility
- Identical configurations and workflows
- Same keybindings and visual appearance
- Complete AUR ecosystem access
- Seamless migration from Arch-based Omarchy

## 📦 Package Distribution

### Host System Packages (DNF/COPR)
- **Hyprland Core**: `hyprland`, `waybar`, `mako`, `xdg-desktop-portal-hyprland`
- **Utilities**: `hypridle`, `hyprlock`, `hyprpicker`, `hyprshot`, `hyprsunset`
- **System Tools**: `swaybg`, `slurp`, `grim`, `wl-clipboard`, `mpv`
- **Input**: `fcitx5`, `fcitx5-gtk`, `fcitx5-qt`
- **Fonts**: `google-noto-fonts-all`

### Containerized Packages (AUR)
- **Development**: `zed`, `github-cli`, `cargo`, `mise`, `nvim`
- **Terminal**: `bat`, `eza`, `ripgrep`, `fd`, `fzf`, `starship`, `zellij`
- **Apps**: `walker-bin`, `discord`, `1password-beta`, `swayosd`

## 🔧 Installation

```bash
# Clone the repository
git clone https://github.com/your-repo/fedarchy
cd fedarchy

# Run the installer
bash install.sh
```

The installer will:
1. Setup Fedora repositories (RPM Fusion, COPR)
2. Install host system packages
3. Create and configure AUR container
4. Install containerized packages with auto-export
5. Deploy Omarchy configurations

## 🛠️ Technical Highlights

### Advanced Export System
Intelligent discovery and export of both GUI applications and CLI binaries:
- Searches multiple binary locations
- Handles package name variations (`walker-bin` → `/usr/bin/walker`)
- Automatic desktop file detection
- Proper error handling and user feedback

### Container Lifecycle Management
- Automatic startup via SystemD user services
- Backup and restore functionality
- Health monitoring and restart capabilities
- Clean removal and export cleanup

### Repository Integration
- **Fedora repos**: Core system components
- **RPM Fusion**: Multimedia and drivers
- **solopasha/hyprland COPR**: Latest Hyprland ecosystem
- **Flatpak**: Cross-platform applications
- **AUR via Distrobox**: Arch ecosystem access

## 🔄 Migration from Omarchy

Fedarchy provides seamless migration:

1. **Configurations**: Copy existing `~/.config` directly
2. **Applications**: Same packages available via AUR
3. **Workflow**: Identical keybindings and behavior
4. **Data**: Standard home directory compatibility

## 🎨 What You Get

- **Visual Perfection**: Identical to original Omarchy appearance
- **Workflow Preservation**: Same keyboard shortcuts and behaviors  
- **Application Ecosystem**: Full AUR access plus Fedora stability
- **Enhanced Security**: Container isolation for experimental packages
- **Better Stability**: Fedora's tested foundation
- **Enterprise Ready**: SELinux, systematic updates, professional support

## 🚧 Current Status

**✅ Complete Features:**
- Core Hyprland environment working perfectly
- Automatic AUR package export
- Container backup/restore system
- All major applications and utilities
- Perfect visual and functional compatibility

**🔄 Active Development:**
- Performance optimizations
- Additional COPR repository integration
- Enhanced error handling and recovery

## 🤝 Contributing

Fedarchy welcomes contributions! Areas of focus:

- **Package optimization**: Better DNF/AUR distribution
- **Performance tuning**: Container and export improvements  
- **Documentation**: User guides and technical docs
- **Testing**: Multi-hardware compatibility
- **Integration**: Additional repository sources

## 📖 Documentation

- **[Complete Technical Overview](FEDARCHY.md)**: Comprehensive architecture explanation
- **[Installation Guide](INSTALL.md)**: Detailed setup instructions
- **[Migration Guide](MIGRATION.md)**: Moving from Arch-based Omarchy
- **[Troubleshooting](TROUBLESHOOTING.md)**: Common issues and solutions

## 🙏 Acknowledgments

- **DHH (David Heinemeier Hansson)**: Creator of the original Omarchy
- **Omarchy Community**: Inspiration and design excellence
- **Distrobox Project**: Container technology enabling this approach
- **solopasha**: Hyprland COPR repository maintenance
- **Fedora Project**: Stable foundation and excellent tooling

## 📜 License

Fedarchy maintains compatibility with Omarchy's licensing while adding new components under appropriate open-source licenses.

---

**Fedarchy: Bringing the best of Omarchy to the stability and security of Fedora.**