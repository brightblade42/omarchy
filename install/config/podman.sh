#!/bin/bash

# FEDARCHY: Configure Podman (replacing Docker)
# Podman is better integrated with Fedora and provides rootless containers

# Configure Podman for better performance and logging
mkdir -p ~/.config/containers
tee ~/.config/containers/storage.conf >/dev/null <<'EOF'
[storage]
driver = "overlay"
runroot = "/run/user/1000/containers"
graphroot = "~/.local/share/containers/storage"

[storage.options]
# Optimize for performance
mount_program = "/usr/bin/fuse-overlayfs"

[storage.options.overlay]
# Limit log size to avoid running out of disk
mountopt = "nodev,metacopy=on"
EOF

# Configure Podman registries for better container access
tee ~/.config/containers/registries.conf >/dev/null <<'EOF'
[registries.search]
registries = ["docker.io", "registry.fedoraproject.org", "registry.access.redhat.com"]

[registries.block]
registries = []
EOF

# Configure container networking (Podman uses different networking than Docker)
mkdir -p ~/.config/systemd/user
tee ~/.config/systemd/user/podman-auto-update.timer >/dev/null <<'EOF'
[Unit]
Description=Podman auto-update timer
Requires=podman-auto-update.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable Podman socket for Docker compatibility (for tools that expect Docker)
systemctl --user enable --now podman.socket

# Configure DNS for containers (similar to Docker but for Podman)
sudo mkdir -p /etc/systemd/resolved.conf.d
echo -e '[Resolve]\nDNSStubListenerExtra=10.88.0.1' | sudo tee /etc/systemd/resolved.conf.d/20-podman-dns.conf >/dev/null
sudo systemctl restart systemd-resolved

# Set up Docker alias for compatibility (many tools expect 'docker' command)
if ! grep -q "alias docker=podman" ~/.bashrc 2>/dev/null; then
    echo "alias docker=podman" >> ~/.bashrc
    echo "alias docker-compose='podman-compose'" >> ~/.bashrc
fi

# Enable lingering for user containers to start at boot
sudo loginctl enable-linger ${USER}

echo "Podman configuration complete!"
echo "Note: Restart your shell or run 'source ~/.bashrc' to use docker aliases"
