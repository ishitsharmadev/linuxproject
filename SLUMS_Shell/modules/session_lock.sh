#!/bin/bash

# ------ CONFIGURATION ------
IDLE_TIMEOUT=120  # in seconds
LOCK_SCREEN_MSG="🔒 Session locked due to inactivity. Press any key to continue..."

# ------ FUNCTION TO LOCK ------
lock_session() {
    clear
    echo "=========================================="
    echo "$LOCK_SCREEN_MSG"
    echo "=========================================="
    read -n 1 -s -r -p ""
    clear
}

# ------ PARSE IDLE TIME ------
get_idle_seconds() {
    idle=$(w -h "$USER" | awk '{print $5}' | head -n 1)

    # Convert formats
    if [[ "$idle" == "?" || "$idle" == "-" ]]; then
        echo 0
    elif [[ "$idle" == *"s" ]]; then
        echo 0
    elif [[ "$idle" == *"min" ]]; then
        mins=$(echo "$idle" | grep -o '[0-9]\+')
        echo $((mins * 60))
    elif [[ "$idle" == *"days" ]]; then
        days=$(echo "$idle" | grep -o '[0-9]\+')
        echo $((days * 86400))
    elif [[ "$idle" =~ ^[0-9]+:[0-9]+$ ]]; then
        IFS=: read -r m s <<< "$idle"
        echo $((m * 60 + s))
    else
        echo 0
    fi
}

# ------ MAIN LOOP ------
while true; do
    sleep 5
    idle_time=$(get_idle_seconds)

    if [ "$idle_time" -ge "$IDLE_TIMEOUT" ]; then
        lock_session
    fi
done
