#!/bin/bash

# FEDARCHY: Firewall configuration for Podman (replacing Docker)

# Allow nothing in, everything out
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow ports for LocalSend
sudo ufw allow 53317/udp
sudo ufw allow 53317/tcp

# Allow SSH in
sudo ufw allow 22/tcp

# Allow Podman containers to use DNS on host (different network range than Docker)
sudo ufw allow in proto udp from 10.88.0.0/16 to 10.88.0.1 port 53 comment 'allow-podman-dns'

# Turn on the firewall
sudo ufw --force enable

# Enable UFW systemd service to start on boot
sudo systemctl enable ufw

# Note: Podman doesn't need special UFW integration like Docker
# Podman uses different networking that's more secure by default
echo "Firewall configured for Podman networking"
