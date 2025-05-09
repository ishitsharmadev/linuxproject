#!/bin/bash

# Import logger
source ./modules/logger.sh

# Temporary file for input
TMP_INPUT=$(mktemp)

# Function to show error
show_error() {
    dialog --title "Error" --msgbox "$1" 8 40
}

# Function to show success
show_success() {
    dialog --title "Success" --msgbox "$1" 8 40
}

# Ask for username to delete
dialog --inputbox "Enter username to delete:" 8 40 2> "$TMP_INPUT"
username=$(<"$TMP_INPUT")

# Check if user exists
if ! id "$username" &>/dev/null; then
    show_error "User '$username' does not exist!"
    exit 1
fi

# Confirm deletion
dialog --yesno "Are you sure you want to delete user '$username'?\nThis will remove their home directory as well." 8 50
response=$?

if [ $response -ne 0 ]; then
    show_error "User deletion cancelled."
    exit 0
fi

# Delete the user and their home directory
userdel -r "$username" 2> "$TMP_INPUT"
if [ $? -ne 0 ]; then
    show_error "Failed to delete user: $(<"$TMP_INPUT")"
    rm -f "$TMP_INPUT"
    exit 1
fi

# Success
show_success "✅ User '$username' deleted successfully."

# Log the action
log_action "Deleted user: $username"

# Cleanup
rm -f "$TMP_INPUT"
