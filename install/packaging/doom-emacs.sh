#!/bin/bash

# FEDARCHY: Install and configure Doom Emacs
echo "Setting up Doom Emacs..."

# Check if Doom Emacs is already installed
if [ -d "$HOME/.config/emacs" ] || [ -d "$HOME/.emacs.d" ]; then
    echo "Emacs configuration already exists. Skipping Doom Emacs installation."
    echo "To install Doom Emacs manually:"
    echo "  1. Backup existing config: mv ~/.emacs.d ~/.emacs.d.backup"
    echo "  2. Run: git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs"
    echo "  3. Run: ~/.config/emacs/bin/doom install"
    return 0
fi

# Install Doom Emacs dependencies that aren't already covered
echo "Installing additional Doom Emacs dependencies..."
aur install \
  fd \
  ripgrep \
  git \
  imagemagick

# Clone Doom Emacs
echo "Cloning Doom Emacs..."
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

# Add Doom bin to PATH for current session
export PATH="$HOME/.config/emacs/bin:$PATH"

# Install Doom Emacs
echo "Installing Doom Emacs (this may take a few minutes)..."
~/.config/emacs/bin/doom install --no-fonts

# Add Doom bin to PATH permanently
if ! grep -q "doom" ~/.bashrc; then
    echo 'export PATH="$HOME/.config/emacs/bin:$PATH"' >> ~/.bashrc
fi

# Create desktop entry for better integration
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/doom-emacs.desktop << 'EOF'
[Desktop Entry]
Name=Doom Emacs
Comment=An Emacs framework for the stubborn martian hacker
GenericName=Text Editor
Exec=emacs %F
Icon=emacs
Type=Application
Terminal=false
Categories=Development;TextEditor;
StartupWMClass=Emacs
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
EOF

echo "✓ Doom Emacs installation complete!"
echo "  - Run 'doom sync' to sync your configuration"
echo "  - Run 'doom upgrade' to update Doom and packages"
echo "  - Edit ~/.config/doom/ to customize your configuration"
echo "  - Restart your shell or run 'source ~/.bashrc' to use doom commands"
