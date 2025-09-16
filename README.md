# Fedarchy

Turn a fresh Fedora installation into a fully-configured, beautiful, and modern web development system based on Hyprland by running a single command. Fedarchy is a **Fedora port of Omarchy** that preserves 100% of Omarchy's functionality while running on stable Fedora with enhanced security via containerized AUR access.

Fedarchy maintains Omarchy's beautiful aesthetic and workflow while offering better stability and package management through:

- **Stable Fedora base** instead of rolling Arch
- **Enhanced security** with AUR packages running in Podman containers
- **Multiple package sources**: DNF + Flatpak + AUR via Distrobox + Podman
- **Native performance** with auto-exported AUR applications
- **Same user experience** - all `omarchy-*` commands work identically

Read more about the original Omarchy at [omarchy.org](https://omarchy.org).

## Installation

Run this command on a fresh Fedora 42+ installation:

```bash
bash <(curl -s https://raw.githubusercontent.com/brightblade42/omarchy/master/boot.sh)
```

## What You Get

- **Hyprland** - Modern tiling window manager
- **Beautiful themes** - Multiple pre-configured color schemes
- **Development tools** - Complete development environment including:
  - **Editors**: Neovim (LazyVim), Zed, Doom Emacs
  - **Terminal**: Alacritty, WezTerm terminals + Zellij multiplexer
  - **Version Control**: Git, Fossil distributed VCS
  - **Database**: SQLite embedded database
  - **Modern CLI tools**: ripgrep, fd, bat, eza, zoxide
- **AUR access** - Full AUR compatibility via containerized Arch Linux
- **Enhanced package management** - Smart multi-source package installation

## Key Features

### AUR-First Strategy
Fedarchy prioritizes AUR packages for maximum Omarchy compatibility:
- AUR packages installed via Distrobox containers
- Applications automatically exported as native Fedora apps
- No performance penalty - exported apps run at native speed

### Multi-Source Package Management
```bash
aur install walker-bin        # Installs from AUR with auto-export
sudo dnf install systemd     # System packages via DNF
flatpak install com.spotify.Client  # Fallback via Flatpak
```

### Enhanced Security & Simplicity
- AUR packages run in isolated Podman containers
- Native Hyprland window manager for optimal performance
- Host system remains clean and stable
- Fedora's security model preserved
- No complex boot/login customizations - uses standard Fedora login

## Differences from Omarchy

| Aspect | Omarchy | Fedarchy |
|--------|---------|----------|
| Base OS | Arch Linux (rolling) | Fedora (stable) |
| Package Manager | pacman/yay | DNF + AUR via Podman |
| Security | Native packages | Containerized AUR (Podman) |
| Stability | Rolling updates | Point releases |
| AUR Access | Direct | Via Distrobox |
| User Experience | Original | **Identical** |

## License

Fedarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
