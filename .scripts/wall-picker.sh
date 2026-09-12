#!/usr/bin/env bash

WALL_DIR="/mnt/SN850/STANDALONES/Pictures/wallpapers"

if [ ! -d "$WALL_DIR" ]; then
    echo "Directory $WALL_DIR does not exist."
    exit 1
fi

# Fuzzel format: DisplayName\0icon\x1f/absolute/path/to/image.jpg
CHOICE=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | while read -r img; do
    basename="${img##*/}"
    echo -en "$basename\0icon\x1f$img\n"
done | fuzzel --dmenu --prompt="Select Wallpaper: " --width=80 --lines=6)


if [ -n "$CHOICE" ]; then
    SELECTED_WALL="$WALL_DIR/$CHOICE"
    
    if [ -f "$SELECTED_WALL" ]; then
        OLD_PID=$(pidof swaybg)
        swaybg -i "$SELECTED_WALL" -m fill &
        sleep 0.3
        if [ -n "$OLD_PID" ]; then
            kill $OLD_PID
        fi
    fi
fi
