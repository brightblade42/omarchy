#!/bin/bash

# FEDARCHY: Modified installer for Fedora-based Omarchy port
# Exit immediately if a command exits with a non-zero status
set -eE

# Script directory (current git repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMARCHY_INSTALL="$SCRIPT_DIR/install"

# Installation target directory
OMARCHY_PATH="$HOME/.local/share/omarchy"
export PATH="$OMARCHY_PATH/bin:$PATH"

# Check for existing installation (not just git repo)
# Look for signs of actual installation: systemd service or container
if [[ -f "$HOME/.config/systemd/user/distrobox-arch-aur.service" ]] || distrobox list 2>/dev/null | grep -q "arch-aur"; then
    echo "🔍 Existing Omarchy installation detected!"
    echo ""
    read -p "Uninstall and reinstall fresh? (y/N): " reinstall

    if [[ "$reinstall" == "y" || "$reinstall" == "Y" ]]; then
        echo "🗑️  Running uninstall..."
        if [[ -f "$SCRIPT_DIR/uninstall.sh" ]]; then
            bash "$SCRIPT_DIR/uninstall.sh"
            echo "🔄 Continuing with fresh installation..."
        else
            echo "❌ Uninstall script not found at: $SCRIPT_DIR/uninstall.sh"
            echo "❌ Manual cleanup required."
            exit 1
        fi
    else
        echo "⚠️  Installing over existing installation..."
    fi
    echo ""
fi

# Preparation
source $OMARCHY_INSTALL/preflight/show-env.sh
source $OMARCHY_INSTALL/preflight/trap-errors.sh
source $OMARCHY_INSTALL/preflight/guard.sh
source $OMARCHY_INSTALL/preflight/chroot.sh
source $OMARCHY_INSTALL/preflight/fedora-repos.sh
source $OMARCHY_INSTALL/preflight/migrations.sh
source $OMARCHY_INSTALL/preflight/first-run-mode.sh

# Packaging
source $OMARCHY_INSTALL/packages.sh
source $OMARCHY_INSTALL/packaging/fonts.sh
source $OMARCHY_INSTALL/packaging/lazyvim.sh
#source $OMARCHY_INSTALL/packaging/doom-emacs.sh
source $OMARCHY_INSTALL/packaging/webapps.sh
source $OMARCHY_INSTALL/packaging/tuis.sh

# Configuration
source $OMARCHY_INSTALL/config/config.sh
source $OMARCHY_INSTALL/config/theme.sh
source $OMARCHY_INSTALL/config/branding.sh
source $OMARCHY_INSTALL/config/git.sh
source $OMARCHY_INSTALL/config/gpg.sh
source $OMARCHY_INSTALL/config/timezones.sh
source $OMARCHY_INSTALL/config/increase-sudo-tries.sh
source $OMARCHY_INSTALL/config/increase-lockout-limit.sh
source $OMARCHY_INSTALL/config/ssh-flakiness.sh
source $OMARCHY_INSTALL/config/detect-keyboard-layout.sh
source $OMARCHY_INSTALL/config/xcompose.sh
source $OMARCHY_INSTALL/config/mise-ruby.sh
source $OMARCHY_INSTALL/config/podman.sh
source $OMARCHY_INSTALL/config/mimetypes.sh
source $OMARCHY_INSTALL/config/localdb.sh
source $OMARCHY_INSTALL/config/sudoless-asdcontrol.sh
# FEDARCHY: Network configuration removed - Fedora uses NetworkManager by default
# FEDARCHY: Bluetooth configuration removed - enabled by default on Fedora
source $OMARCHY_INSTALL/config/hardware/set-wireless-regdom.sh
source $OMARCHY_INSTALL/config/hardware/fix-fkeys.sh
source $OMARCHY_INSTALL/config/hardware/printer.sh
source $OMARCHY_INSTALL/config/hardware/usb-autosuspend.sh
source $OMARCHY_INSTALL/config/hardware/ignore-power-button.sh
source $OMARCHY_INSTALL/config/hardware/nvidia.sh
source $OMARCHY_INSTALL/config/hardware/intel.sh
source $OMARCHY_INSTALL/config/hardware/fix-f13-amd-audio-input.sh

# Login - FEDARCHY: Removed Plymouth and bootloader customizations
# Users can configure these manually if desired

# Finishing
source $OMARCHY_INSTALL/reboot.sh
