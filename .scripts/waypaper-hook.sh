#!/usr/bin/env bash

WALLPAPER_PATH="$1"

# Check if a wallpaper path was actually passed
if [ -z "$WALLPAPER_PATH" ]; then
    echo "Error: No wallpaper path provided by Waypaper."
    exit 1
fi

# Step 1: Run Matugen to extract colors from the wallpaper image
# We add '--source-color-index 0' so it automatically picks the primary color without asking questions
matugen image "$WALLPAPER_PATH" --source-color-index 0

# Step 2: Reload Sway to apply the new window border colors
swaymsg reload

# Step 3: Tell Waybar to reload its styling
pkill -SIGUSR2 waybar

echo "Matugen themes generated and desktop components reloaded successfully!"
