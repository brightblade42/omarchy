# Fedarchy Uninstall

Simple uninstall script that removes:
- AUR container and images
- Exported applications/binaries  
- Omarchy scripts (requires git redownload)
- Optionally Hyprland DNF packages

## Usage

```bash
bash uninstall.sh
```

## What Gets Removed

- ✅ **Container**: arch-aur distrobox container
- ✅ **Images**: Container images and backups  
- ✅ **Exports**: Exported apps and binaries from container
- ✅ **Scripts**: All omarchy-* utilities and main installation
- ✅ **Service**: SystemD auto-start service
- ⚠️ **Hyprland packages**: Optional (rarely needed)

## After Uninstall

To reinstall, you'll need to:
```bash
git clone <repository>
cd omarchy
bash install.sh
```

The script forces you to redownload from git, ensuring you get the latest version.