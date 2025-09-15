#!/bin/bash

# ==============================================================================
# Hyprland NVIDIA Setup Script for Fedora Linux (FEDARCHY)
# ==============================================================================
# This script automates the installation and configuration of NVIDIA drivers
# for use with Hyprland on Fedora Linux, using RPM Fusion repositories.
#
# IMPORTANT: Uses proprietary NVIDIA drivers for maximum stability and
# compatibility. Open-source drivers are experimental and may cause issues.
#
# Converted from Arch version for Fedarchy project
#
# ==============================================================================

# --- GPU Detection ---
if [ -n "$(lspci | grep -i 'nvidia')" ]; then
  echo "NVIDIA GPU detected, configuring drivers..."

  # --- Driver Selection ---
  # Always use proprietary NVIDIA drivers for maximum stability and compatibility
  # The open-source drivers are still experimental and may have issues
  NVIDIA_DRIVER_PACKAGE="akmod-nvidia"
  echo "Using proprietary NVIDIA kernel modules for maximum stability"

  # Check which kernel is installed and ensure appropriate headers
  KERNEL_HEADERS="kernel-devel kernel-headers" # Default Fedora kernel
  if rpm -q kernel-rt &>/dev/null; then
    KERNEL_HEADERS="kernel-rt-devel kernel-rt-headers"
    echo "Real-time kernel detected"
  fi

  # Ensure RPM Fusion is enabled (should already be done by fedora-repos.sh)
  if ! dnf repolist enabled | grep -q rpmfusion-nonfree; then
    echo "Enabling RPM Fusion repositories..."
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  fi

  # Update system packages
  sudo dnf update -y

  # Install NVIDIA packages
  PACKAGES_TO_INSTALL=(
    "${KERNEL_HEADERS}"
    "${NVIDIA_DRIVER_PACKAGE}"
    "xorg-x11-drv-nvidia-cuda"
    "nvidia-vaapi-driver"  # For VA-API hardware acceleration
    "libva-nvidia-driver"
    "egl-wayland"
    "qt5-qtwayland"
    "qt6-qtwayland"
  )

  echo "Installing NVIDIA packages: ${PACKAGES_TO_INSTALL[*]}"
  sudo dnf install -y "${PACKAGES_TO_INSTALL[@]}"

  # Configure modprobe for early KMS
  echo "Configuring NVIDIA kernel module options..."
  echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null

  # Configure dracut for early loading (Fedora uses dracut instead of mkinitcpio)
  DRACUT_CONF="/etc/dracut.conf.d/nvidia.conf"

  echo "Configuring dracut for early NVIDIA module loading..."
  cat > /tmp/nvidia-dracut.conf << 'EOF'
# NVIDIA driver modules for early loading
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
# Force early KMS
kernel_cmdline+=" rd.driver.pre=nvidia-drm "
EOF

  sudo cp /tmp/nvidia-dracut.conf "$DRACUT_CONF"

  # Rebuild initramfs
  echo "Rebuilding initramfs..."
  sudo dracut --force

  # Add NVIDIA environment variables to Hyprland config
  HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
  if [ -f "$HYPRLAND_CONF" ]; then
    echo "Adding NVIDIA environment variables to Hyprland config..."
    cat >>"$HYPRLAND_CONF" <<'EOF'

# NVIDIA environment variables for Hyprland
env = NVD_BACKEND,direct
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1
env = WLR_DRM_NO_ATOMIC,1
EOF
  fi

  # Configure Xorg if needed (though Hyprland uses Wayland)
  if [ ! -f /etc/X11/xorg.conf.d/20-nvidia.conf ]; then
    echo "Creating Xorg NVIDIA configuration..."
    sudo mkdir -p /etc/X11/xorg.conf.d/
    cat | sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf > /dev/null << 'EOF'
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    VendorName "NVIDIA Corporation"
    Option "NoLogo" "true"
    Option "UseEDID" "false"
    Option "UseDisplayDevice" "none"
EndSection
EOF
  fi

  echo "NVIDIA configuration complete!"
  echo "Please reboot for changes to take effect."

else
  echo "No NVIDIA GPU detected, skipping NVIDIA driver configuration."
fi
