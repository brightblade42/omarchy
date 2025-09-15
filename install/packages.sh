#!/bin/bash

# FEDARCHY: AUR-first package installation strategy
# Maintains Omarchy compatibility by using AUR packages via distrobox

# DNF packages - Essential system integration + core window manager
echo "Installing essential system packages via DNF..."
sudo dnf install -y \
  avahi \
  bash-completion \
  cups \
  cups-browsed \
  cups-filters \
  cups-pdf \
  fontconfig \
  gnome-keyring \
  gvfs-mtp \
  gvfs-smb \
  hyprland \
  nautilus \
  NetworkManager-wifi \
  pipewire \
  pipewire-pulseaudio \
  pipewire-jack-audio-connection-kit \
  podman \
  podman-compose \
  system-config-printer \
  wireplumber \
  polkit \
  lxpolkit \
  qt5-qtwayland \
  systemd \
  unzip \
  wireless-regdb \
  xmlstarlet

# Flatpak fallbacks for packages not available via AUR
echo "Installing Flatpak applications..."
flatpak install -y flathub \
  org.gnome.Calculator \
  org.gnome.Evince \
  org.libreoffice.LibreOffice \
  org.kde.kdenlive \
  com.obsproject.Studio \
  md.obsidian.Obsidian \
  com.github.PintaProject.Pinta \
  org.signal.Signal \
  com.spotify.Client \
  org.gnome.FileRoller

# AUR packages - PRIMARY source for Omarchy compatibility
echo "Installing AUR packages with auto-export..."

# Development tools
aur install \
  1password-beta \
  1password-cli \
  asdcontrol-git \
  github-cli \
  cargo \
  clang \
  gcc14 \
  llvm \
  mise \
  nvim \
  python-poetry-core \
  tree-sitter-cli \
  zed \
  emacs \
  fossil \
  sqlite

# Terminal utilities
aur install \
  alacritty \
  bat \
  btop \
  dust \
  eza \
  fastfetch \
  fd \
  fzf \
  gum \
  jq \
  lazydocker \
  lazygit \
  less \
  plocate \
  ripgrep \
  starship \
  tldr \
  wezterm \
  zellij \
  zoxide

# Hyprland utilities (core hyprland installed via DNF)
# These utilities benefit from latest AUR versions
aur install \
  hypridle \
  hyprland-qtutils \
  hyprlock \
  hyprpicker \
  hyprshot \
  hyprsunset \
  mako \
  waybar \
  walker-bin \
  uwsm

# Media and graphics
aur install \
  brightnessctl \
  imagemagick \
  imv \
  mpv \
  pamixer \
  playerctl \
  satty \
  slurp \
  swaybg \
  swayosd \
  wf-recorder \
  wl-clip-persist \
  wl-clipboard \
  wl-screenrec

# Input methods and internationalization
aur install \
  fcitx5 \
  fcitx5-gtk \
  fcitx5-qt

# Fonts
aur install \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  noto-fonts-extra \
  ttf-cascadia-mono-nerd \
  ttf-ia-writer \
  ttf-jetbrains-mono-nerd \
  woff2-font-awesome

# System utilities
aur install \
  blueberry \
  ffmpegthumbnailer \
  kvantum-qt5 \
  libqalculate \
  localsend \
  luarocks \
  mariadb-libs \
  nss-mdns \
  omarchy-chromium \
  postgresql-libs \
  python-gobject \
  python-terminaltexteffects \
  sushi \
  typora \
  tzupdate \
  ufw \
  whois \
  wiremix \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-hyprland \
  xournalpp \
  yaru-icon-theme

# Special packages
aur install \
  impala \
  iwd \
  yay

echo "Package installation complete!"
echo "AUR packages have been automatically exported as native applications"
