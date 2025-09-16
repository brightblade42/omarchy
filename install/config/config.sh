#!/bin/bash

# Copy over Omarchy configs
mkdir -p ~/.config

# FEDARCHY: Use rsync for robust config copying that handles dangling symlinks
# rsync is better than cp for this because it properly handles:
# - Dangling symlinks (overwrites them)
# - Existing files and directories
# - Preserves permissions and timestamps
if command -v rsync >/dev/null 2>&1; then
    echo "Deploying configuration files with rsync..."
    rsync -av --delete-during ~/.local/share/omarchy/config/ ~/.config/
else
    echo "Deploying configuration files with cp (removing dangling symlinks first)..."
    # Remove dangling symlinks in ~/.config to prevent cp failures
    find ~/.config -type l ! -exec test -e {} \; -delete 2>/dev/null || true
    cp -R ~/.local/share/omarchy/config/* ~/.config/
fi

# Use default bashrc from Omarchy
cp ~/.local/share/omarchy/default/bashrc ~/.bashrc
