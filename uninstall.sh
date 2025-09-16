#!/bin/bash

# FEDARCHY: Simple Uninstall Script
# Removes containers, exports, and Omarchy scripts

echo "🗑️  Fedarchy Simple Uninstall"
echo "============================="
echo ""
echo "This will:"
echo "• Remove AUR container and images"
echo "• Clean up exported applications/binaries"
echo "• Remove Omarchy scripts (requires git redownload)"
echo "• Optionally remove Hyprland DNF packages"
echo ""

read -p "Continue? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ Cancelled."
    exit 0
fi

echo ""
echo "🚀 Starting cleanup..."

# 1. Remove containers and images
echo ""
echo "📦 Removing containers and images..."

if command -v distrobox >/dev/null 2>&1; then
    # Stop and remove arch-aur container
    distrobox stop arch-aur 2>/dev/null || true
    distrobox rm arch-aur --force 2>/dev/null || true
    echo "   ✅ Container removed"
fi

if command -v podman >/dev/null 2>&1; then
    # Remove backup images
    podman rmi fedarchy-aur-backup:latest 2>/dev/null || true
    podman rmi archlinux:latest 2>/dev/null || true
    echo "   ✅ Images cleaned"
fi

# 2. Clean up exported applications and binaries
echo ""
echo "🧹 Cleaning up exports..."

# Remove distrobox exported binaries (they contain distrobox commands)
find "$HOME/.local/bin" -type f -exec grep -l "distrobox enter" {} \; 2>/dev/null | xargs rm -f 2>/dev/null || true

# Remove exported desktop applications (they contain distrobox commands)
find "$HOME/.local/share/applications" -name "*.desktop" -exec grep -l "distrobox enter" {} \; 2>/dev/null | xargs rm -f 2>/dev/null || true

# Remove aur wrapper
rm -f "$HOME/.local/bin/aur"

echo "   ✅ Exports cleaned"

# 3. Remove Omarchy scripts and installation
echo ""
echo "🗂️  Removing Omarchy installation..."

rm -rf "$HOME/.local/share/omarchy"
find "$HOME/.local/bin" -name "omarchy-*" -type f -delete 2>/dev/null || true

echo "   ✅ Omarchy scripts removed (redownload required)"

# 4. Optional: Remove Hyprland packages
echo ""
echo "❓ Remove Hyprland DNF packages?"
echo "   (Only do this if you don't plan to use Hyprland anymore)"
read -p "Remove Hyprland packages? (y/N): " remove_hyprland

if [[ "$remove_hyprland" == "y" || "$remove_hyprland" == "Y" ]]; then
    echo "🗑️  Removing Hyprland packages..."

    hyprland_packages=(
        "hyprland" "waybar" "mako" "xdg-desktop-portal-hyprland"
        "hyprcursor" "hyprlang" "hyprutils" "hyprqt6engine"
        "hypridle" "hyprlock" "hyprpicker" "hyprshot" "hyprsunset"
        "uwsm" "hyprpaper" "swaybg" "slurp" "grim"
    )

    for pkg in "${hyprland_packages[@]}"; do
        sudo dnf remove -y "$pkg" 2>/dev/null || true
    done

    # Remove COPR repo
    sudo dnf copr remove -y solopasha/hyprland 2>/dev/null || true

    echo "   ✅ Hyprland packages removed"
else
    echo "   ⏭️  Keeping Hyprland packages"
fi

# 5. Clean up systemd service
echo ""
echo "🔧 Removing systemd service..."

systemctl --user stop distrobox-arch-aur.service 2>/dev/null || true
systemctl --user disable distrobox-arch-aur.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/distrobox-arch-aur.service"

echo "   ✅ Service removed"

echo ""
echo "✨ Cleanup complete!"
echo ""
echo "📋 What was removed:"
echo "• AUR container and images"
echo "• Exported applications and binaries"
echo "• Omarchy scripts and installation"
if [[ "$remove_hyprland" == "y" || "$remove_hyprland" == "Y" ]]; then
    echo "• Hyprland packages"
fi
echo ""
echo "📌 To reinstall: git clone and run install.sh"
echo ""
