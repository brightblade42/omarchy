#!/bin/bash

clear

# Show fancy logo if tte is available (optional)
if command -v tte >/dev/null 2>&1; then
    tte -i "$OMARCHY_PATH/logo.txt" --frame-rate 920 laseretch 2>/dev/null || cat "$OMARCHY_PATH/logo.txt" 2>/dev/null || echo "Fedarchy installation complete!"
    echo
    echo "You're done! So we're ready to reboot now..." | tte --frame-rate 640 wipe 2>/dev/null || echo "You're done! So we're ready to reboot now..."
else
    # Fallback to simple text display
    cat "$OMARCHY_PATH/logo.txt"
    echo
    echo "You're done! So we're ready to reboot now..."
fi

if sudo test -f /etc/sudoers.d/99-omarchy-installer; then
  sudo rm -f /etc/sudoers.d/99-omarchy-installer &>/dev/null
  echo -e "\nRemember to remove USB installer!\n\n"
fi

sleep 5
reboot
