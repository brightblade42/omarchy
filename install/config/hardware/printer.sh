#!/bin/bash

# FEDARCHY: Printer configuration for Fedora Linux
# Configures CUPS printing and network printer discovery

echo "Configuring printer support..."

# Enable CUPS printing service
chrootable_systemctl_enable cups.service

# Disable multicast DNS in systemd-resolved to avoid conflicts with Avahi
# Avahi provides better network printer discovery
sudo mkdir -p /etc/systemd/resolved.conf.d
echo -e "[Resolve]\nMulticastDNS=no" | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf >/dev/null

# Enable Avahi daemon for network service discovery (printers, etc.)
chrootable_systemctl_enable avahi-daemon.service

# Configure NSSwitch to use mDNS for .local domain resolution
# This enables automatic discovery of network printers via Bonjour/Zeroconf
if ! grep -q 'mdns_minimal' /etc/nsswitch.conf; then
  echo "Configuring mDNS resolution for .local domains..."
  sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns/' /etc/nsswitch.conf
fi

# Configure CUPS to automatically add discovered network printers
if ! grep -q '^CreateRemotePrinters Yes' /etc/cups/cups-browsed.conf 2>/dev/null; then
  echo "Enabling automatic network printer discovery..."
  echo 'CreateRemotePrinters Yes' | sudo tee -a /etc/cups/cups-browsed.conf >/dev/null
fi

# Enable CUPS browsing service for network printer discovery
chrootable_systemctl_enable cups-browsed.service

# Add user to lp group for printer access (Fedora-specific)
if ! groups $USER | grep -q '\blp\b'; then
  echo "Adding user to lp group for printer access..."
  sudo usermod -a -G lp $USER
fi

echo "Printer configuration complete!"
echo "Network printers should be automatically discovered and available."
