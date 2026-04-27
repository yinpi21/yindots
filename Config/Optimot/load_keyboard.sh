#!/bin/sh
XKB_FILE="$HOME/afs/.confs/Config/Optimot/Optimot.xkb"

# Trouve xkbcomp : système → nix-profile → nix shell
if [ -x "/run/current-system/sw/bin/xkbcomp" ]; then
    XKBCOMP="/run/current-system/sw/bin/xkbcomp"
elif [ -x "$HOME/.nix-profile/bin/xkbcomp" ]; then
    XKBCOMP="$HOME/.nix-profile/bin/xkbcomp"
else
    XKBCOMP=""
fi

# Trouve le répertoire XKB de base
for candidate in \
    "/run/current-system/sw/share/X11/xkb" \
    "/usr/share/X11/xkb" \
    "$HOME/.nix-profile/share/X11/xkb"
do
    [ -d "$candidate" ] && XKB_PATH="$candidate" && break
done

if [ -n "$XKBCOMP" ] && [ -n "$XKB_PATH" ]; then
    "$XKBCOMP" -I"$XKB_PATH" -w 0 "$XKB_FILE" "$DISPLAY"
else
    # Fallback : nix shell (lent mais fiable)
    nix shell nixpkgs#xorg.xkbcomp nixpkgs#xkeyboard_config --command sh -c "
        XKB_ROOT=\$(nix build nixpkgs#xkeyboard_config --no-link --print-out-paths 2>/dev/null)/etc/X11/xkb
        xkbcomp -I\"\$XKB_ROOT\" -w 0 \"$XKB_FILE\" \"$DISPLAY\"
    "
fi
