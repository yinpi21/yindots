#!/usr/bin/env bash

source "$HOME/afs/.confs/scripts/globals.sh"

LOCK_FILE="/tmp/note_${USER}.lock"
NOTE_FILE="$AFS/.note.txt"

(
    flock -n 9 || exit 0
    rm -f "${NOTE_FILE}.swp"
    vim "$NOTE_FILE" +startinsert
) 9>"$LOCK_FILE"
