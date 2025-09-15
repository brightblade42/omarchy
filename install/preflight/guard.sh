#!/bin/bash

# FEDARCHY: Guard checks for Fedora-based installation

abort() {
  echo -e "\e[31mFedarchy install requires: $1\e[0m"
  echo
  gum confirm "Proceed anyway on your own accord and without assistance?" || exit 1
}

# Must be a Fedora distro
[[ -f /etc/fedora-release ]] || abort "Fedora Linux"

# Must not be running as root
[ "$EUID" -eq 0 ] && abort "Running as root (not user)"

# Must be x86_64 only to fully work
[ "$(uname -m)" != "x86_64" ] && abort "x86_64 CPU"

# Must not have GNOME or KDE already installed (check for desktop environments)
# Note: Fedora Workstation comes with GNOME by default, so we only warn for KDE
if rpm -q plasma-desktop &>/dev/null; then
  abort "Fresh Fedora without KDE Plasma (use Fedora Workstation or Server)"
fi

# Check for minimum Fedora version (42+)
FEDORA_VERSION=$(rpm -E %fedora)
if [[ $FEDORA_VERSION -lt 42 ]]; then
  abort "Fedora 42 or newer (currently running Fedora $FEDORA_VERSION)"
fi

# Cleared all guards
echo "Guards: OK - Fedora $FEDORA_VERSION detected"
