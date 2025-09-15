#!/bin/bash

# Setup GPG configuration with multiple keyservers for better reliability
echo "Configuring GPG keyservers..."

# Create GPG directory and copy configuration
sudo mkdir -p /etc/gnupg
sudo cp ~/.local/share/omarchy/default/gpg/dirmngr.conf /etc/gnupg/
sudo chmod 644 /etc/gnupg/dirmngr.conf

# Restart dirmngr daemon (ignore errors as this is non-critical)
echo "Restarting GPG dirmngr daemon..."
if sudo gpgconf --kill dirmngr 2>/dev/null; then
    echo "  Killed existing dirmngr"
else
    echo "  No existing dirmngr found"
fi

if sudo gpgconf --launch dirmngr 2>/dev/null; then
    echo "  ✓ dirmngr started successfully"
else
    echo "  Warning: Failed to start dirmngr (this is non-critical)"
fi
