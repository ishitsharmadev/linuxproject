#!/bin/bash

# Import logger
source ./modules/logger.sh

echo "---- Delete User ----"

read -p "Enter username to delete: " username

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "❌ User '$username' does not exist."
    exit 1
fi

# Confirm deletion
read -p "Are you sure you want to delete '$username'? (y/n): " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && { echo "❌ Deletion cancelled."; exit 0; }

# Lock the account first (safety)
usermod -L "$username"

# Ask whether to delete home directory
read -p "Delete home directory as well? (y/n): " delete_home

# Delete user accordingly
if [[ "$delete_home" == "y" || "$delete_home" == "Y" ]]; then
    userdel -r "$username"
else
    userdel "$username"
fi

if [ $? -eq 0 ]; then
    echo "✅ User '$username' deleted successfully."
    log_action "Deleted user: $username (Home deleted: $delete_home)"
else
    echo "❌ Failed to delete user."
fi
