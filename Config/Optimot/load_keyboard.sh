#!/bin/sh
# Charge le layout Optimot via xkbcomp système (sans nix shell)
XKB_PATH="/run/current-system/sw/share/X11/xkb"
XKB_FILE="$HOME/afs/.confs/Config/Optimot/Optimot.xkb"

xkbcomp -I"$XKB_PATH" -w 0 "$XKB_FILE" "$DISPLAY"
