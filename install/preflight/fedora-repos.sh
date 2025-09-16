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

# Enable COPR repository for Hyprland ecosystem packages
echo "Enabling solopasha/hyprland COPR for Hyprland ecosystem..."
sudo dnf install -y dnf-plugins-core
sudo dnf copr enable -y solopasha/hyprland

# Setup Flatpak for fallback packages
sudo dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install container infrastructure for AUR access (Podman-based)
echo "Installing container infrastructure (podman, distrobox)..."
if ! sudo dnf install -y podman podman-compose distrobox; then
    echo "ERROR: Failed to install container infrastructure"
    echo "Please run manually: sudo dnf install -y podman podman-compose distrobox"
    exit 1
fi

# Verify distrobox is available
if ! command -v distrobox >/dev/null 2>&1; then
    echo "ERROR: distrobox not found after installation"
    echo "Try: hash -r && which distrobox"
    exit 1
fi

echo "✓ Container infrastructure installed successfully"

# Enable and start podman socket for better integration
systemctl --user enable --now podman.socket

# Setup AUR container
setup_aur_container() {
    echo "Setting up Arch Linux container for AUR access..."

    # Create Arch container if it doesn't exist
    if ! distrobox list | grep -q "arch-aur"; then
        # Comprehensive cleanup before container creation
        echo "Cleaning up any stale container artifacts..."

        # Clean volumes and containers
        podman volume prune -f 2>/dev/null || true
        podman container prune -f 2>/dev/null || true

        # Remove any distrobox-specific artifacts that might persist
        rm -rf ~/.local/share/applications/distrobox-*.desktop 2>/dev/null || true
        rm -rf ~/.config/systemd/user/distrobox-*.service 2>/dev/null || true

        # Reload systemd to clear any stale service references
        systemctl --user daemon-reload 2>/dev/null || true

        # Create container with proper cleanup
        echo "Creating container..."
        if ! distrobox create --name arch-aur --image archlinux:latest --yes; then
            echo "ERROR: Failed to create container. Trying with alternative approach..."
            # Fallback: try with explicit volume cleanup and different flags
            podman system prune -f 2>/dev/null || true
            sleep 2
            distrobox create --name arch-aur --image archlinux:latest --yes --additional-flags "--pull=always"
        fi

        # Wait for container to be fully ready
        echo "Waiting for container to initialize..."
        sleep 3

        # Initialize container and install yay
        distrobox enter arch-aur -- bash -c "
            # Update system first
            sudo pacman -Syu --noconfirm

            # Install git if not already present (base-devel should have most tools)
            sudo pacman -S --needed --noconfirm git

            # Install yay
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

            # Handle common conflicts (git versions vs stable)
            case "$package" in
                fastfetch)
                    distrobox enter "$AUR_CONTAINER" -- yay -Rns --noconfirm fastfetch-git 2>/dev/null || true
                    ;;
                localsend)
                    # localsend depends on rustup, which conflicts with rust package
                    distrobox enter "$AUR_CONTAINER" -- yay -Rns --noconfirm rust 2>/dev/null || true
                    ;;
            esac

            if distrobox enter "$AUR_CONTAINER" -- yay -S --noconfirm --removemake --cleanafter --overwrite "*" "$package"; then
                # Try to export as both GUI app and CLI binary
                app_exported=false
                bin_exported=false

                echo "Attempting to export $package..."

                # Export GUI app - find actual desktop files first
                desktop_files=$(distrobox enter "$AUR_CONTAINER" -- find /usr/share/applications/ -name "*$package*.desktop" -o -name "*${package%-bin}*.desktop" 2>/dev/null | head -3)
                if [ -n "$desktop_files" ]; then
                    echo "Found desktop files: $desktop_files"
                    for desktop_file in $desktop_files; do
                        app_name=$(basename "$desktop_file" .desktop)
                        echo "Trying to export app: $app_name"
                        if distrobox enter "$AUR_CONTAINER" -- distrobox-export --app "$app_name"; then
                            echo "✓ $app_name GUI app exported"
                            app_exported=true
                            break
                        else
                            echo "! Failed to export $app_name"
                        fi
                    done
                else
                    # Try package name directly as fallback
                    echo "No desktop files found, trying package name..."
                    if distrobox enter "$AUR_CONTAINER" -- distrobox-export --app "$package"; then
                        echo "✓ $package GUI app exported"
                        app_exported=true
                    fi
                fi

                # Export CLI binary - check if binary exists first
                for bin_path in "/usr/bin/$package" "/usr/local/bin/$package" "/usr/bin/${package%-bin}" "/usr/bin/${package%-git}"; do
                    if distrobox enter "$AUR_CONTAINER" -- test -x "$bin_path" 2>/dev/null; then
                        echo "Found binary at $bin_path, attempting export..."
                        if distrobox enter "$AUR_CONTAINER" -- distrobox-export --bin "$bin_path"; then
                            echo "✓ Binary exported: $(basename "$bin_path")"
                            bin_exported=true
                            break
                        else
                            echo "! Failed to export binary $bin_path"
                        fi
                    fi
                done

                # Summary message
                if [ "$app_exported" = true ] && [ "$bin_exported" = true ]; then
                    echo "✓ $package installed with GUI and CLI access"
                elif [ "$app_exported" = true ]; then
                    echo "✓ $package installed as GUI application"
                elif [ "$bin_exported" = true ]; then
                    echo "✓ $package installed as CLI tool"
                else
                    echo "✓ $package installed (no exportable apps/binaries found)"
                    echo "  Use 'distrobox enter $AUR_CONTAINER -- $package' to run"
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
            # Clean up exported apps and binaries
            distrobox enter "$AUR_CONTAINER" -- distrobox-export --delete --app "$package" 2>/dev/null || true
            distrobox enter "$AUR_CONTAINER" -- distrobox-export --delete --bin "$package" 2>/dev/null || true
            distrobox enter "$AUR_CONTAINER" -- distrobox-export --delete --bin "${package%-bin}" 2>/dev/null || true
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
    commit-container)
        echo "Committing AUR container to backup image..."
        if distrobox list | grep -q "$AUR_CONTAINER"; then
            distrobox stop "$AUR_CONTAINER" 2>/dev/null || true
            podman commit "distrobox_$AUR_CONTAINER" fedarchy-aur-backup:latest
            distrobox start "$AUR_CONTAINER" 2>/dev/null || true
            echo "✓ Container committed as 'fedarchy-aur-backup:latest'"
            echo "Use 'aur restore-container' to restore from this backup"
        else
            echo "✗ AUR container not found"
            exit 1
        fi
        ;;
    restore-container)
        echo "Restoring AUR container from backup image..."
        if podman image exists fedarchy-aur-backup:latest; then
            # Remove existing container if present
            distrobox rm "$AUR_CONTAINER" --force 2>/dev/null || true

            # Create from backup image
            distrobox create --name "$AUR_CONTAINER" --image fedarchy-aur-backup:latest

            echo "✓ Container restored from backup"
            echo "Testing container..."
            if distrobox enter "$AUR_CONTAINER" -- echo "Container working"; then
                echo "✓ Container is functional"
            else
                echo "✗ Container may have issues"
            fi
        else
            echo "✗ No backup image found (fedarchy-aur-backup:latest)"
            echo "Create a backup first with 'aur commit-container'"
            exit 1
        fi
        ;;
    *)
        echo "Usage: aur {install|remove|update|search|commit-container|restore-container} [packages...]"
        echo "Examples:"
        echo "  aur install walker-bin discord"
        echo "  aur commit-container    # Save current container state"
        echo "  aur restore-container   # Restore from saved state"
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

# Setup container auto-start service
setup_container_autostart() {
    echo "Setting up container auto-start on boot..."
    mkdir -p ~/.config/systemd/user

    cat > ~/.config/systemd/user/distrobox-arch-aur.service << 'EOF'
[Unit]
Description=Distrobox arch-aur container auto-start
Documentation=https://github.com/89luca89/distrobox
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/distrobox enter arch-aur -- sleep infinity
ExecStop=/usr/bin/distrobox stop arch-aur
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

    # Enable and start the service
    systemctl --user daemon-reload
    systemctl --user enable distrobox-arch-aur.service
    systemctl --user start distrobox-arch-aur.service

    echo "✓ Container auto-start configured"
}

# Execute setup
setup_aur_container
create_aur_wrapper
setup_container_autostart

# Update system packages
sudo dnf update -y

echo "Fedora repository setup complete!"
echo "AUR wrapper created: Use 'aur install package' for AUR packages"
echo "Container will auto-start on boot"
