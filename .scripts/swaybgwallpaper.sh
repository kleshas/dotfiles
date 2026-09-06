#!/bin/bash

# 1. Path to your wallpapers folder
WALLPAPER_DIR="/mnt/SN850/STANDALONES/Pictures"

# 2. Safely grab a random image file (handles spaces in filenames correctly)
CURRENT_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | shuf -n 1)

# 3. Halt script if your directory is empty
if [ -z "$CURRENT_WALLPAPER" ]; then
    echo "No images found in $WALLPAPER_DIR"
    exit 1
fi

# 4. Enforce cache directories exist
mkdir -p "$HOME/.cache/wal"

# 5. Overwrite the stable shortcut link with the new choice
ln -sf "$CURRENT_WALLPAPER" "$HOME/.cache/wal/bg_current.jpg"

# 6. Push the updated wallpaper directly onto the active displays
swaymsg "output * bg $HOME/.cache/wal/bg_current.jpg fill"

# 7. Fire up your localized HTTP sync helper server
bash /home/bhava/.dotfiles/.scripts/httpserver.sh
