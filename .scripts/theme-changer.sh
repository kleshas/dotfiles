#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
SCRIPTS_DIR="$DOTFILES_DIR/.scripts"
STOW_DIR="$DOTFILES_DIR/stow"

mkdir -p "$STOW_DIR"

# 1. Interactive Theme Selector Menu
PS3="👉 Choose your desktop theme (enter number): "
options=(
    "catppuccin-mocha"
    "catppuccin-macchiato"
    "catppuccin-frappe"
    "nord"
    "everforest"
    "dracula"
    "gruvbox-dark"
    "Quit"
)

echo "=========================================="
echo "      SWAY ARCH THEME ARCHITECT          "
echo "=========================================="

select THEME in "${options[@]}"; do
    if [[ "$THEME" == "Quit" ]]; then
        echo "Exiting without changes."
        exit 0
    elif [[ -n "$THEME" ]]; then
        echo "🔄 Applying global theme profile: $THEME"
        break
    else
        echo "❌ Invalid selection. Please pick a number from the list."
    fi
done

# 2. Configuration Mappings (Now updated for Mako!)
declare -A file_maps=(
    ["$SCRIPTS_DIR/sway/${THEME}.css"]="$STOW_DIR/sway/.config/sway/colors.css"
    ["$SCRIPTS_DIR/waybar/${THEME}.css"]="$STOW_DIR/waybar/.config/waybar/material.css"
    ["$SCRIPTS_DIR/wofi/${THEME}.css"]="$STOW_DIR/wofi/.config/wofi/style.css"
    ["$SCRIPTS_DIR/kitty/${THEME}.conf"]="$STOW_DIR/kitty/.config/kitty/colors.conf"
    ["$SCRIPTS_DIR/mako/${THEME}.conf"]="$STOW_DIR/mako/.config/mako/config"
    ["$SCRIPTS_DIR/geany/${THEME}.conf"]="$STOW_DIR/geany/.config/geany/colorschemes/custom.conf"
    ["$SCRIPTS_DIR/gtk-3.0/${THEME}.ini"]="$STOW_DIR/gtk-3.0/.config/gtk-3.0/settings.ini"
)

# 3. Clone Templates to GNU Stow Structure
echo "⚙️  Copying configuration templates into stow layouts..."
for src in "${!file_maps[@]}"; do
    dest="${file_maps[$src]}"
    if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
    else
        echo "⚠️  Warning: Template file missing, skipping: $src"
    fi
done

# 4. Sync configurations out to your $HOME via GNU Stow
if command -v stow &> /dev/null; then
    echo "📦 Synchronizing configurations via GNU Stow..."
    cd "$DOTFILES_DIR"
    stow -R -t "$HOME" sway waybar wofi kitty mako geany gtk-3.0 2>/dev/null || true
fi

# 5. Native GTK Interface Refresh
TARGET_GTK_INI="$HOME/.config/gtk-3.0/settings.ini"
if [[ -f "$TARGET_GTK_INI" ]] && command -v gsettings &> /dev/null; then
    echo "🎨 Updating GTK runtime schemas..."
    GTK_THEME_NAME=$(grep "gtk-theme-name" "$TARGET_GTK_INI" | cut -d'=' -f2 | tr -d ' ' || echo "Adwaita-dark")
    if pgrep -x sway &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME"
        gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    fi
fi

# 6. Wayland Hot Reload Sequence
echo "📡 Refreshing running active services..."

if command -v swaymsg &> /dev/null && pgrep -x sway &> /dev/null; then
    swaymsg reload &>/dev/null
fi

# Mako notification engine style reload
if command -v makoctl &> /dev/null && pgrep -x mako &> /dev/null; then
    makoctl reload
fi

if pgrep -x waybar &> /dev/null; then
    pkill -SIGUSR2 waybar
fi

if pgrep -x kitty &> /dev/null; then
    pkill -USR1 kitty
fi

echo "✅ Theme swap finalized!"
read -rp "Press [Enter] to dismiss..."
