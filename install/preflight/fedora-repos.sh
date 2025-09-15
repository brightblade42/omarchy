#!/bin/bash

# FEDARCHY: Setup Fedora repositories and container infrastructure
# Replaces pacman.sh for Fedora-based system

# Install only essential system tools for Fedora host
# (AUR compilation happens inside distrobox, not on host)
sudo dnf install -y git

# Enable RPM Fusion repositories for additional packages
sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Setup Flatpak for fallback packages
sudo dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install container infrastructure for AUR access (Podman-based)
sudo dnf install -y podman podman-compose distrobox

# Enable and start podman socket for better integration
systemctl --user enable --now podman.socket

# Setup AUR container
setup_aur_container() {
    echo "Setting up Arch Linux container for AUR access..."

    # Create Arch container if it doesn't exist
    if ! distrobox list | grep -q "arch-aur"; then
        distrobox create --name arch-aur --image archlinux:latest

        # Initialize container and install yay
        distrobox enter arch-aur -- bash -c "
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm base-devel git
            cd /tmp
            git clone https://aur.archlinux.org/yay.git
            cd yay
            makepkg -si --noconfirm
            cd ~
            rm -rf /tmp/yay
        "

        echo "AUR container setup complete!"
    else
        echo "AUR container already exists, updating..."
        distrobox enter arch-aur -- yay -Syu --noconfirm
    fi
}

# Create AUR wrapper function
create_aur_wrapper() {
    mkdir -p ~/.local/bin

    cat > ~/.local/bin/aur << 'EOF'
#!/bin/bash
# FEDARCHY: AUR wrapper with auto-export functionality

AUR_CONTAINER="arch-aur"

case "$1" in
    install)
        shift
        for package in "$@"; do
            echo "Installing $package from AUR..."
            if distrobox enter "$AUR_CONTAINER" -- yay -S --noconfirm "$package"; then
                # Auto-export if package has desktop entry
                if distrobox-export --app "$package" 2>/dev/null; then
                    echo "✓ $package installed and exported as native app"
                else
                    echo "✓ $package installed (no desktop entry to export)"
                fi
            else
                echo "✗ Failed to install $package"
                exit 1
            fi
        done
        ;;
    remove)
        shift
        for package in "$@"; do
            echo "Removing $package..."
            distrobox enter "$AUR_CONTAINER" -- yay -Rs --noconfirm "$package"
            # Clean up exported apps
            ~/.local/bin/distrobox-export --delete --app "$package" 2>/dev/null || true
        done
        ;;
    update)
        echo "Updating AUR packages..."
        distrobox enter "$AUR_CONTAINER" -- yay -Syu --noconfirm
        ;;
    search)
        shift
        distrobox enter "$AUR_CONTAINER" -- yay -Ss "$@"
        ;;
    *)
        echo "Usage: aur {install|remove|update|search} [packages...]"
        echo "Example: aur install walker-bin discord"
        exit 1
        ;;
esac
EOF

    chmod +x ~/.local/bin/aur

    # Add to PATH if not already there
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# Execute setup
setup_aur_container
create_aur_wrapper

# Update system packages
sudo dnf update -y

echo "Fedora repository setup complete!"
echo "AUR wrapper created: Use 'aur install package' for AUR packages"
