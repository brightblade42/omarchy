#!/bin/bash

omarchy-refresh-applications
update-desktop-database ~/.local/share/applications

# Open all images with imv
xdg-mime default imv.desktop image/png
xdg-mime default imv.desktop image/jpeg
xdg-mime default imv.desktop image/gif
xdg-mime default imv.desktop image/webp
xdg-mime default imv.desktop image/bmp
xdg-mime default imv.desktop image/tiff

# Open PDFs with the Document Viewer
xdg-mime default org.gnome.Evince.desktop application/pdf

# Use Chromium as the default browser (if available)
CHROMIUM_DESKTOP="chromium.desktop"
CHROMIUM_PATHS=(
    "/usr/share/applications/$CHROMIUM_DESKTOP"
    "$HOME/.local/share/applications/$CHROMIUM_DESKTOP"
)

CHROMIUM_FOUND=false
for path in "${CHROMIUM_PATHS[@]}"; do
    if [ -f "$path" ]; then
        CHROMIUM_FOUND=true
        break
    fi
done

if [ "$CHROMIUM_FOUND" = true ]; then
    echo "Setting Chromium as default browser..."
    if xdg-settings set default-web-browser chromium.desktop 2>/dev/null; then
        xdg-mime default chromium.desktop x-scheme-handler/http
        xdg-mime default chromium.desktop x-scheme-handler/https
        echo "  ✓ Chromium set as default browser"
    else
        echo "  Warning: Failed to set Chromium as default browser"
    fi
else
    echo "Chromium not found, skipping browser configuration"
    echo "Available desktop files:"
    find /usr/share/applications ~/.local/share/applications -name "*chrom*" -o -name "*browser*" 2>/dev/null | head -5 || true
fi

# Open video files with mpv
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-msvideo
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/x-flv
xdg-mime default mpv.desktop video/x-ms-wmv
xdg-mime default mpv.desktop video/mpeg
xdg-mime default mpv.desktop video/ogg
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/quicktime
xdg-mime default mpv.desktop video/3gpp
xdg-mime default mpv.desktop video/3gpp2
xdg-mime default mpv.desktop video/x-ms-asf
xdg-mime default mpv.desktop video/x-ogm+ogg
xdg-mime default mpv.desktop video/x-theora+ogg
xdg-mime default mpv.desktop application/ogg
