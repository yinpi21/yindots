#!/usr/bin/env bash
# Ouvre un nouveau terminal alacritty dans le dossier courant de la fenêtre active

ID=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk '{print $5}')
if [ -z "$ID" ] || [ "$ID" = "0x0" ]; then
    alacritty
    exit 0
fi

PID=$(xprop -id "$ID" _NET_WM_PID 2>/dev/null | awk '{print $3}')
if [ -z "$PID" ]; then
    alacritty
    exit 0
fi

CHILD_PID=$(pgrep -P "$PID" | head -n 1)

if [ -n "$CHILD_PID" ]; then
    CWD=$(readlink -f "/proc/$CHILD_PID/cwd" 2>/dev/null)
else
    CWD=$(readlink -f "/proc/$PID/cwd" 2>/dev/null)
fi

alacritty --working-directory "${CWD:-$HOME}"
