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
  rsync \
  systemd \
  unzip \
  wireless-regdb \
  xmlstarlet \
  waybar \
  mako \
  xdg-desktop-portal-hyprland \
  hyprcursor \
  hyprlang \
  hyprutils \
  hypridle \
  hyprlock \
  hyprpicker \
  hyprshot \
  hyprsunset \
  uwsm \
  hyprpaper \
  hyprqt6engine \
  hyprland-qtutils \
  fcitx5 \
  fcitx5-gtk \
  fcitx5-qt \
  swaybg \
  slurp \
  grim \
  wl-clipboard \
  mpv \
  ImageMagick \
  google-noto-fonts-common \
  google-noto-fonts-all \
  xdg-desktop-portal-gtk

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

# Hyprland utilities (ecosystem via COPR, critical components via DNF)
# FEDARCHY: Complete Hyprland ecosystem moved to host via COPR for optimal integration
aur install \
  walker-bin

# Media and graphics
# FEDARCHY: Moved to DNF - swaybg, slurp, grim, wl-clipboard, mpv, imagemagick
aur install \
  brightnessctl \
  imv \
  pamixer \
  playerctl \
  satty \
  swayosd \
  wf-recorder \
  wl-clip-persist \
  wl-screenrec

# Input methods and internationalization
# FEDARCHY: fcitx5 moved to DNF (available in Fedora repos)
echo "Input method framework installed via DNF"

# Fonts
# FEDARCHY: Moved to DNF - noto-fonts variants
aur install \
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
  xournalpp \
  yaru-icon-theme

# Special packages
aur install \
  impala \
  iwd \
  yay

echo "Package installation complete!"
echo "AUR packages have been automatically exported as native applications"
