#!/bin/bash

# FEDARCHY: Disable shutting system down on power button to bind it to power menu afterwards
echo "Configuring power button behavior..."

# Create logind configuration directory if it doesn't exist
sudo mkdir -p /etc/systemd/logind.conf.d

# Create a drop-in configuration file (Fedora best practice)
sudo tee /etc/systemd/logind.conf.d/99-ignore-power-key.conf >/dev/null <<'EOF'
[Login]
HandlePowerKey=ignore
EOF

echo "✓ Power button configured to be ignored (for power menu binding)"
