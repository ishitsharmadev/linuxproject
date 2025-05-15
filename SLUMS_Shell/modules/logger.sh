#!/bin/bash

# ---------- CONFIG ----------
LOG_FILE="./logs/slums.log"

# ---------- FUNCTION ----------
log_action() {
    local ACTION="$1"
    local USER=$(whoami)
    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    # Check and create log file if needed
    if [ ! -f "$LOG_FILE" ]; then
        mkdir -p "$(dirname "$LOG_FILE")"
        touch "$LOG_FILE"
        chmod 666 "$LOG_FILE"
    fi

    echo "[$TIMESTAMP] $ACTION by $USER" | tee -a "$LOG_FILE" > /dev/null
}

# ---------- USAGE EXAMPLE ----------
# log_action "Added user 'john'"
