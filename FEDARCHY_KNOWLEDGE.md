# Fedarchy Knowledge Base for Omarchy Migration

## Core Innovations to Implement

### 1. Enhanced Package Management Strategy

#### Triple Package Hierarchy
```bash
# Fedarchy package priority (implement this logic in all package scripts):
1. DNF (Fedora native) - for core system packages
2. Flatpak - for cross-platform applications  
3. AUR via Distrobox - for Arch-specific packages

# Example decision tree:
if dnf_has_package; then
    use_dnf
elif flatpak_has_package; then
    use_flatpak
else
    use_aur_with_export
fi
```

#### Enhanced AUR Wrapper Pattern
```bash
# Replace any AUR management with this pattern:
aur_install() {
    package="$1"
    # Install in container
    distrobox enter arch-aur -- yay -S "$package"
    # Auto-export for native integration
    distrobox-export --app "$package" 2>/dev/null || {
        echo "Package installed but could not export - use: distrobox enter arch-aur -- $package"
    }
}
```

### 2. Container Management Integration

#### Container Lifecycle Management
```bash
# Add to any script that uses AUR packages:
ensure_container_running() {
    if ! podman ps --format "{{.Names}}" | grep -q "distrobox-arch-aur"; then
        echo "🚀 Starting Arch container..."
        distrobox enter arch-aur -- /bin/true >/dev/null 2>&1
    fi
}
```

#### Smart Container Startup
```bash
# For performance optimization in launchers:
smart_container_start() {
    local cache_file="/tmp/fedarchy-container-arch-aur"
    local current_time=$(date +%s)
    
    if [ -f "$cache_file" ]; then
        local last_start=$(cat "$cache_file")
        local time_diff=$((current_time - last_start))
        
        if [ $time_diff -lt 30 ] && container_running; then
            return 0
        fi
    fi
    
    start_container
    echo "$current_time" > "$cache_file"
}
```

### 3. Fedora-Specific Adaptations

#### Package Name Mappings
```bash
# Common Arch → Fedora package mappings to implement:
declare -A FEDORA_PACKAGE_MAP=(
    ["base-devel"]="@development-tools"
    ["xorg-server"]="xorg-x11-server-Xorg"
    ["pipewire-pulse"]="pipewire-pulseaudio"
    ["networkmanager"]="NetworkManager"
    ["bluez"]="bluez"
    ["bluez-utils"]="bluez-tools"
)
```

#### Repository Setup Pattern
```bash
# Replace any pacman repo setup with:
setup_fedora_repos() {
    # Enable RPM Fusion
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    
    # Setup Flatpak
    sudo dnf install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}
```

### 4. Configuration File Adaptations

#### Hyprland Config Differences
```bash
# Fedora-specific paths in Hyprland config:
# Polkit authentication agent (Fedora 41+ compatible)
exec-once = lxpolkit  # Lightweight, works with any desktop
# OR based on detection:
# exec-once = /usr/libexec/polkit-kde-authentication-agent-1      # If KDE present
# exec-once = /usr/libexec/polkit-mate-authentication-agent-1     # If MATE present

# Other Fedora startup applications:
exec-once = blueman-applet  
exec-once = nm-applet
exec-once = fedarchy-warm-containers  # Our addition
```

#### Fish Shell Fedora Paths
```fish
# Fedora-specific paths to add:
fish_add_path /usr/local/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin

# Fedora environment variables:
set -gx EDITOR nvim
set -gx BROWSER firefox
```

### 5. Application Installation Patterns

#### Core Applications Strategy
```bash
# Implement this decision matrix:

# Keep on Fedora DNF (system integration):
FEDORA_APPS=(
    "firefox" "chromium" "nautilus" "evince" "eog"
    "gnome-calculator" "gnome-system-monitor"
    "keepassxc" "thunderbird" "libreoffice"
)

# Install via Flatpak (cross-platform):
FLATPAK_APPS=(
    "com.spotify.Client" "com.discordapp.Discord" 
    "com.slack.Slack" "org.telegram.desktop"
    "com.obsidian.Obsidian" "com.visualstudio.code"
    "org.blender.Blender" "org.gimp.GIMP"
)

# Install via AUR (Arch-specific or latest versions):
AUR_APPS=(
    "walker-bin" "hyprpicker-git" "fastfetch-git"
    "brave-bin" "discord-canary" "vscodium-bin"
)
```

#### Auto-Export Integration
```bash
# Add this to any AUR installation:
install_and_export() {
    local package="$1"
    
    echo "Installing $package via AUR..."
    if distrobox enter arch-aur -- yay -S --noconfirm "$package"; then
        echo "Exporting $package as native app..."
        if distrobox-export --app "$package" 2>/dev/null; then
            echo "✅ $package available as native Fedora app"
        else
            echo "⚠️  $package installed but not exported (no desktop entry)"
        fi
    fi
}
```

### 6. Error Handling Patterns

#### Container Error Handling
```bash
# Add robust container checks:
check_container_health() {
    if ! command -v distrobox >/dev/null; then
        echo "❌ Distrobox not installed"
        return 1
    fi
    
    if ! distrobox list | grep -q "arch-aur"; then
        echo "❌ Arch container not found"
        return 1
    fi
    
    if ! podman ps >/dev/null 2>&1; then
        echo "❌ Podman not running"
        return 1
    fi
    
    return 0
}
```

### 7. Performance Optimizations

#### Container Preloading
```bash
# Add container warming to startup:
fedarchy_warm_containers() {
    # Start container in background if not running
    if distrobox list | grep -q "arch-aur"; then
        if ! podman ps --format "{{.Names}}" | grep -q "distrobox-arch-aur"; then
            nohup distrobox enter arch-aur -- /bin/true >/dev/null 2>&1 &
        fi
    fi
}
```

### 8. Migration Transformation Rules

#### Script Transformation Patterns
```bash
# Replace these patterns throughout Omarchy scripts:

# OLD (Arch):                    # NEW (Fedarchy):
pacman -S package                → aur install package  # PREFERRED
yay -S package                   → aur install package  # Direct replacement
makepkg -si                      → (handled by aur wrapper)
pacman -Syu                      → fedarchy update (DNF + AUR)
systemctl --user enable         → (same)
cp config ~/.config/             → (same, but check paths)

# EXCEPTION - Only for system essentials:
pacman -S systemd                → sudo dnf install systemd
pacman -S podman                 → sudo dnf install podman
pacman -S @development-tools     → sudo dnf groupinstall "Development Tools"
```

## Implementation Strategy

### Phase 1: Infrastructure Scripts
1. Replace package installation functions
2. Add container management 
3. Implement triple package hierarchy
4. Add error handling and health checks

### Phase 2: Application Scripts  
1. Migrate application installation lists
2. Implement auto-export for AUR apps
3. Add Flatpak alternatives
4. Update configuration deployment

### Phase 3: Configuration Scripts
1. Update file paths for Fedora
2. Add container startup integration
3. Implement Fedora-specific settings
4. Preserve Omarchy aesthetics and behavior

### Phase 4: Testing and Optimization
1. Container performance tuning
2. Error handling refinement  
3. User experience optimization
4. Documentation updates

## Success Metrics
- All Omarchy functionality preserved
- Enhanced security via containerization
- Better package management options
- Faster application startup (auto-export)
- Fedora stability with Arch software access
