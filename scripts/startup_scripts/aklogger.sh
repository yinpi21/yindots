#!/usr/bin/env bash

(
    trap 'exit 0' TERM INT
    while true; do
        sleep 28800
        if kinit -R > /dev/null 2>&1 && aklog > /dev/null 2>&1; then
            dunstify "aklogger:" "AFS token refreshed"
        else
            dunstify -u critical "aklogger:" "Failed to refresh AFS token"
        fi
    done
) > /dev/null 2>&1 &
