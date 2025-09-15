echo "Symlink files needed for Nautilus navigation icons"

# FEDARCHY: Check if paths exist before creating symlinks
if [ -f "/usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg" ] && [ -d "/usr/share/icons/Yaru/scalable/actions" ]; then
    sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
    sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg
    sudo gtk-update-icon-cache /usr/share/icons/Yaru
    pkill -x nautilus || true
    echo "Nautilus icon fixes applied"
else
    echo "Skipping Nautilus icon fixes - Yaru icons not found on this system"
fi
