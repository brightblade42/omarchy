#!/bin/bash

# FEDARCHY: Install and configure Doom Emacs inside AUR container
echo "Setting up Doom Emacs in AUR container..."

AUR_CONTAINER="arch-aur"

# Check if Doom Emacs is already configured in container
if distrobox enter "$AUR_CONTAINER" -- test -d ~/.config/emacs || \
   distrobox enter "$AUR_CONTAINER" -- test -d ~/.emacs.d; then
    echo "Emacs configuration already exists in container. Skipping Doom Emacs installation."
    echo "To install Doom Emacs manually:"
    echo "  1. distrobox enter $AUR_CONTAINER"
    echo "  2. mv ~/.emacs.d ~/.emacs.d.backup"
    echo "  3. git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs"
    echo "  4. ~/.config/emacs/bin/doom install"
    return 0
fi

# Install Doom Emacs dependencies in container (emacs already installed via AUR)
echo "Installing additional Doom Emacs dependencies in container..."
distrobox enter "$AUR_CONTAINER" -- yay -S --noconfirm --needed \
  fd \
  ripgrep \
  git \
  imagemagick

# Clone Doom Emacs inside container
echo "Cloning Doom Emacs in container..."
distrobox enter "$AUR_CONTAINER" -- git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

# Install Doom Emacs inside container (non-interactive)
echo "Installing Doom Emacs (this may take a few minutes)..."
# Set environment variables for non-interactive installation
distrobox enter "$AUR_CONTAINER" -- bash -c "
export DOOM_AUTOINSTALL=yes
export CI=true
~/.config/emacs/bin/doom install --no-env
"

# Add Doom bin to PATH inside container
distrobox enter "$AUR_CONTAINER" -- bash -c "
if ! grep -q 'doom' ~/.bashrc; then
    echo 'export PATH=\"\$HOME/.config/emacs/bin:\$PATH\"' >> ~/.bashrc
fi
"

# Export doom command to host system for easy access
echo "Exporting doom command to host system..."
if distrobox-export --bin ~/.config/emacs/bin/doom --container "$AUR_CONTAINER" 2>/dev/null; then
    echo "  ✓ doom command exported successfully"
else
    echo "  Warning: Failed to export doom command (you can run 'distrobox enter arch-aur -- doom' instead)"
fi

echo "✓ Doom Emacs installation complete!"
echo "  - Run 'doom sync' to sync your configuration"
echo "  - Run 'doom upgrade' to update Doom and packages"
echo "  - Edit ~/.config/doom/ (inside container) to customize"
echo "  - Emacs is now available as a native application"
