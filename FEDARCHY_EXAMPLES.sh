#!/bin/bash
# Fedarchy Implementation Examples
# These are reference implementations to guide Omarchy script migration

# =============================================================================
# EXAMPLE 1: Enhanced Package Installation Function
# =============================================================================

fedarchy_install_package() {
    local package="$1"
    local force_aur="$2"  # Optional: force AUR installation
    
    # Skip if already installed via any method
    if command -v "$package" >/dev/null 2>&1; then
        echo "✅ $package already available"
        return 0
    fi
    
    # Force AUR if requested
    if [[ "$force_aur" == "aur" ]]; then
        echo "🔄 Installing $package via AUR (forced)..."
        aur install "$package"
        return $?
    fi
    
    # Try Fedora first
    if dnf search "$package" >/dev/null 2>&1; then
        echo "🔄 Installing $package via DNF..."
        sudo dnf install -y "$package"
        return $?
    fi
    
    # Try Flatpak second
    local flatpak_name=$(get_flatpak_name "$package")
    if [[ -n "$flatpak_name" ]] && flatpak search "$flatpak_name" >/dev/null 2>&1; then
        echo "🔄 Installing $package via Flatpak..."
        flatpak install -y flathub "$flatpak_name"
        return $?
    fi
    
    # Fall back to AUR
    echo "🔄 Installing $package via AUR..."
    aur install "$package"
}

# =============================================================================
# EXAMPLE 2: AUR Wrapper with Auto-Export
# =============================================================================

aur() {
    local CONTAINER="arch-aur"
    
    # Ensure container exists and is running
    if ! distrobox list | grep -q "$CONTAINER"; then
        echo "❌ Arch container not found. Run setup first."
        return 1
    fi
    
    ensure_container_running
    
    case "$1" in
        "install"|"i")
            shift
            for package in "$@"; do
                echo "🔄 Installing $package via AUR..."
                if distrobox enter $CONTAINER -- yay -S --noconfirm "$package"; then
                    # Try to export the package
                    if distrobox-export --app "$package" 2>/dev/null; then
                        echo "✅ $package exported as native Fedora app"
                    else
                        echo "⚠️  $package installed but not exported"
                        echo "💡 Run manually: distrobox enter $CONTAINER -- $package"
                    fi
                else
                    echo "❌ Failed to install $package"
                    return 1
                fi
            done
            ;;
        "remove"|"r")
            shift
            for package in "$@"; do
                distrobox enter $CONTAINER -- yay -Rns "$package"
                # Try to unexport
                distrobox-export --delete --app "$package" 2>/dev/null || true
            done
            ;;
        "update"|"u")
            distrobox enter $CONTAINER -- yay -Syu
            ;;
        "search"|"s")
            shift
            distrobox enter $CONTAINER -- yay -Ss "$@"
            ;;
        *)
            echo "Usage: aur [install|remove|update|search] [package]"
            ;;
    esac
}

# =============================================================================
# EXAMPLE 3: Container Management Functions
# =============================================================================

ensure_container_running() {
    local CONTAINER="arch-aur"
    
    if ! podman ps --format "{{.Names}}" | grep -q "distrobox-$CONTAINER"; then
        echo "🚀 Starting Arch container..."
        distrobox enter $CONTAINER -- /bin/true >/dev/null 2>&1 &
        
        # Wait for container to be ready
        for i in {1..10}; do
            if podman ps --format "{{.Names}}" | grep -q "distrobox-$CONTAINER"; then
                return 0
            fi
            sleep 1
        done
        
        echo "❌ Failed to start container"
        return 1
    fi
}

setup_distrobox_container() {
    echo "🏗️  Setting up Arch Linux container for AUR access..."
    
    # Create container
    distrobox create --name arch-aur --image archlinux:latest --yes
    
    # Setup container
    distrobox enter arch-aur -- bash -c '
        # Update system
        sudo pacman -Syu --noconfirm
        
        # Install base development tools
        sudo pacman -S --noconfirm base-devel git
        
        # Install yay AUR helper
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        
        echo "✅ Arch container ready!"
    '
    
    # Enable auto-start
    setup_container_autostart
}

setup_container_autostart() {
    mkdir -p ~/.config/systemd/user
    
    cat > ~/.config/systemd/user/distrobox-arch-aur.service << 'EOF'
[Unit]
Description=Start Distrobox Arch AUR container
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/usr/bin/distrobox enter arch-aur -- /bin/true
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable distrobox-arch-aur.service
}

# =============================================================================
# EXAMPLE 4: Fedora Repository Setup
# =============================================================================

setup_fedora_repositories() {
    echo "🔧 Setting up Fedora repositories..."
    
    # Enable RPM Fusion
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    
    # Setup Flatpak
    sudo dnf install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    echo "✅ Repositories configured"
}

# =============================================================================
# EXAMPLE 5: Application Installation Lists
# =============================================================================

install_core_applications() {
    echo "📦 Installing core applications..."
    
    # Fedora native packages (best integration)
    local fedora_apps=(
        "firefox" "chromium" "nautilus" "evince" "eog"
        "gnome-calculator" "gnome-system-monitor" "keepassxc"
        "git" "neovim" "fish" "btop" "ripgrep" "fd-find"
    )
    
    for app in "${fedora_apps[@]}"; do
        sudo dnf install -y "$app"
    done
    
    # Flatpak applications (cross-platform)
    local flatpak_apps=(
        "com.spotify.Client"
        "com.discordapp.Discord" 
        "com.visualstudio.code"
        "org.blender.Blender"
        "org.gimp.GIMP"
    )
    
    for app in "${flatpak_apps[@]}"; do
        flatpak install -y flathub "$app"
    done
    
    # AUR applications (Arch-specific or latest)
    local aur_apps=(
        "walker-bin"
        "hyprpicker-git"
        "fastfetch-git"
    )
    
    for app in "${aur_apps[@]}"; do
        aur install "$app"
    done
}

# =============================================================================
# EXAMPLE 6: Configuration Deployment
# =============================================================================

deploy_hyprland_config() {
    echo "⚙️  Deploying Hyprland configuration..."
    
    mkdir -p ~/.config/hypr
    
    # Detect and setup appropriate polkit agent
    setup_polkit_auth
    
    # Use Fedora-specific paths and settings
    cat > ~/.config/hypr/hyprland.conf << EOF
# Fedarchy Hyprland Configuration

# Startup applications
exec-once = waybar
exec-once = dunst
exec-once = $POLKIT_AGENT  # Fedora 41+ compatible polkit agent
exec-once = blueman-applet
exec-once = nm-applet
exec-once = fedarchy-warm-containers  # Our container warming

# Environment variables
env = QT_QPA_PLATFORM,wayland
env = GDK_BACKEND,wayland,x11
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = MOZ_ENABLE_WAYLAND,1

# Rest of Omarchy config preserved...
EOF
}

# Setup appropriate polkit authentication agent for Fedora 41+
setup_polkit_auth() {
    if command -v kde-session >/dev/null 2>&1; then
        echo "🔧 Setting up KDE polkit agent..."
        sudo dnf install -y polkit-kde
        POLKIT_AGENT="/usr/libexec/polkit-kde-authentication-agent-1"
    elif command -v mate-session >/dev/null 2>&1; then
        echo "🔧 Setting up MATE polkit agent..."
        sudo dnf install -y mate-polkit
        POLKIT_AGENT="/usr/libexec/polkit-mate-authentication-agent-1"
    else
        # Default lightweight option for Hyprland
        echo "🔧 Setting up lightweight polkit agent..."
        sudo dnf install -y lxpolkit
        POLKIT_AGENT="lxpolkit"
    fi
}

# =============================================================================
# EXAMPLE 7: Update Function
# =============================================================================

fedarchy_update() {
    echo "🔄 Updating Fedarchy system..."
    
    # Update AUR packages first (primary package source)
    echo "🏗️  Updating AUR packages..."
    aur update
    
    # Update system essentials via DNF
    echo "🔧 Updating system essentials..."
    sudo dnf update -y
    
    # Update Flatpak fallbacks
    echo "📱 Updating Flatpak applications..."
    flatpak update -y
    
    # Clean up
    echo "🧹 Cleaning up..."
    sudo dnf autoremove -y
    flatpak uninstall --unused -y
    aur clean
    
    echo "✅ System updated!"
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

get_flatpak_name() {
    local package="$1"
    
    # Common package name mappings
    case "$package" in
        "discord") echo "com.discordapp.Discord" ;;
        "spotify") echo "com.spotify.Client" ;;
        "code"|"vscode") echo "com.visualstudio.code" ;;
        "blender") echo "org.blender.Blender" ;;
        "gimp") echo "org.gimp.GIMP" ;;
        *) echo "" ;;
    esac
}

check_fedora_version() {
    local version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | tr -d '"')
    if [[ "$version" -lt 40 ]]; then
        echo "⚠️  Fedora $version detected. Fedarchy requires Fedora 40+."
        return 1
    fi
    echo "✅ Fedora $version detected"
}

# =============================================================================
# ERROR HANDLING
# =============================================================================

handle_error() {
    local exit_code=$1
    local line_number=$2
    echo "❌ Error occurred at line $line_number (exit code: $exit_code)"
    echo "💡 Check logs and try again"
    exit $exit_code
}

trap 'handle_error $? $LINENO' ERR
