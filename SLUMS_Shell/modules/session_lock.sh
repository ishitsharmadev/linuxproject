#!/bin/bash

# Ensure required tools are installed
if ! command -v dialog &>/dev/null; then
    echo "'dialog' is required. Install with: sudo apt install dialog"
    exit 1
fi

if ! command -v vlock &>/dev/null; then
    dialog --title "Missing vlock" --msgbox "'vlock' is required but not installed.\nInstall it with:\nsudo apt install vlock" 8 50
    exit 1
fi

# Ask user with a dialog menu
dialog --clear --title "SLUMS Session Lock" \
--menu "Choose a lock action:" 12 50 2 \
1 "Lock Session Now" \
2 "Cancel" 2>temp_lock_choice.txt

CHOICE=$(<temp_lock_choice.txt)
rm -f temp_lock_choice.txt

case "$CHOICE" in
    1)
        dialog --infobox "🔒 Locking your session..." 4 40
        sleep 1
        clear
        vlock
        ;;
    2)
        dialog --title "Cancelled" --msgbox "Session lock was cancelled." 6 40
        ;;
    *)
        dialog --title "Error" --msgbox "No valid option selected!" 6 40
        ;;
esac
