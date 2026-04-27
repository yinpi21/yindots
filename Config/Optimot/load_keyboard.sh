#!/bin/sh
XKB_PATH="/run/current-system/sw/share/X11/xkb"
XKB_FILE="$HOME/afs/.confs/Config/Optimot/Optimot.xkb"

# Chemin absolu prioritaire (NixOS system), fallback nix-profile
if [ -x "/run/current-system/sw/bin/xkbcomp" ]; then
    XKBCOMP="/run/current-system/sw/bin/xkbcomp"
elif [ -x "$HOME/.nix-profile/bin/xkbcomp" ]; then
    XKBCOMP="$HOME/.nix-profile/bin/xkbcomp"
else
    echo "xkbcomp introuvable" >&2
    exit 1
fi

"$XKBCOMP" -I"$XKB_PATH" -w 0 "$XKB_FILE" "$DISPLAY"
