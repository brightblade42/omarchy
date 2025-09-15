#!/bin/bash

# FEDARCHY: Set wireless regulatory domain for Fedora Linux
# Fedora handles wireless regdom differently than Arch

echo "Configuring wireless regulatory domain..."

# Check if we already have a regulatory domain set
CURRENT_REGDOM=$(iw reg get 2>/dev/null | grep country | cut -d' ' -f2 | tr -d ':')

# If the region is already set and not 00 (world/unset), we're done
if [ -n "${CURRENT_REGDOM}" ] && [ "${CURRENT_REGDOM}" != "00" ]; then
  echo "Wireless regulatory domain already set to: ${CURRENT_REGDOM}"
  exit 0
fi

# Get the current timezone to determine country
if [ -e "/etc/localtime" ]; then
  TIMEZONE=$(readlink -f /etc/localtime)
  TIMEZONE=${TIMEZONE#/usr/share/zoneinfo/}

  # Some timezones are formatted with the two letter country code at the start
  COUNTRY="${TIMEZONE%%/*}"

  # If we don't have a two letter country, get it from the timezone table
  if [[ ! "$COUNTRY" =~ ^[A-Z]{2}$ ]] && [ -f "/usr/share/zoneinfo/zone.tab" ]; then
    COUNTRY=$(awk -v tz="$TIMEZONE" '$3 == tz {print $1; exit}' /usr/share/zoneinfo/zone.tab)
  fi

  # Check if we have a two letter country code
  if [[ "$COUNTRY" =~ ^[A-Z]{2}$ ]]; then
    echo "Setting wireless regulatory domain to: $COUNTRY"

    # Set it immediately with iw
    if command -v iw &> /dev/null; then
      sudo iw reg set ${COUNTRY}
    fi

    # For Fedora, create a systemd service to set regdom at boot
    # This is more reliable than the Arch conf.d approach
    sudo tee /etc/systemd/system/wireless-regdom.service > /dev/null << EOF
[Unit]
Description=Set wireless regulatory domain
Wants=network-pre.target
Before=network-pre.target
BindsTo=sys-subsystem-net-devices-wlan0.device
After=sys-subsystem-net-devices-wlan0.device

[Service]
Type=oneshot
ExecStart=/usr/sbin/iw reg set ${COUNTRY}
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    # Enable the service
    sudo systemctl enable wireless-regdom.service

    echo "Wireless regulatory domain configured for $COUNTRY"
  else
    echo "Could not determine country code from timezone: $TIMEZONE"
    echo "You may need to manually set wireless regulatory domain with: sudo iw reg set <COUNTRY>"
  fi
else
  echo "Could not determine timezone, skipping wireless regulatory domain setup"
fi
