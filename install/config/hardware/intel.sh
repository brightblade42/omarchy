#!/bin/bash

# FEDARCHY: Intel GPU hardware video acceleration for Fedora Linux
# Installs appropriate VA-API drivers for Intel integrated graphics

echo "Checking for Intel GPU hardware acceleration support..."

# Check if we have an Intel GPU at all
if INTEL_GPU=$(lspci | grep -iE 'vga|3d|display' | grep -i 'intel'); then
  echo "Intel GPU detected: $INTEL_GPU"

  # HD Graphics and newer (2014+) use intel-media-driver
  if [[ "${INTEL_GPU,,}" =~ "hd graphics"|"xe"|"iris"|"uhd" ]]; then
    echo "Installing modern Intel media driver for newer GPU..."
    sudo dnf install -y intel-media-driver libva-intel-driver
  elif [[ "${INTEL_GPU,,}" =~ "gma"|"graphics media accelerator" ]]; then
    echo "Installing legacy Intel driver for older GPU..."
    # Older generations from 2008 to ~2014 use libva-intel-driver
    sudo dnf install -y libva-intel-driver
  else
    echo "Installing both drivers for maximum compatibility..."
    # Install both for unknown Intel GPU variants
    sudo dnf install -y intel-media-driver libva-intel-driver
  fi

  # Install additional VA-API utilities for verification
  sudo dnf install -y libva-utils

  echo "Intel GPU hardware acceleration configured!"
  echo "You can test with: vainfo"

else
  echo "No Intel GPU detected, skipping Intel driver installation."
fi
