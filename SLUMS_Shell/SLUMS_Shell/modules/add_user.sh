#!/bin/bash

# Import logger
source ./modules/logger.sh

# Temporary file for dialog input
TMP_INPUT=$(mktemp)

# Function to show error
show_error() {
    dialog --title "Error" --msgbox "$1" 8 40
}

# Function to show success
show_success() {
    dialog --title "Success" --msgbox "$1" 8 50
}

# 1. Username
dialog --inputbox "Enter new username:" 8 40 2> "$TMP_INPUT"
username=$(<"$TMP_INPUT")

if id "$username" &>/dev/null; then
    show_error "User already exists!"
    exit 1
fi

# 2. Full name
dialog --inputbox "Enter full name (optional):" 8 40 2> "$TMP_INPUT"
fullname=$(<"$TMP_INPUT")

# 3. Password and confirmation
dialog --insecure --passwordbox "Enter password:" 8 40 2> "$TMP_INPUT"
password=$(<"$TMP_INPUT")
dialog --insecure --passwordbox "Confirm password:" 8 40 2> "$TMP_INPUT"
confirm_password=$(<"$TMP_INPUT")

if [ "$password" != "$confirm_password" ]; then
    show_error "Passwords do not match."
    exit 1
fi

# 4. Account expiry date
dialog --inputbox "Enter account expiry date (YYYY-MM-DD or leave blank):" 8 50 2> "$TMP_INPUT"
expiry=$(<"$TMP_INPUT")

# 5. Password expiry days
dialog --inputbox "Enter number of days before password expires (e.g., 30):" 8 50 2> "$TMP_INPUT"
pass_expire_days=$(<"$TMP_INPUT")

# 6. Lock account choice
dialog --yesno "Lock the account after creation?" 7 40
lock_choice=$?

# 7. Primary group
dialog --inputbox "Enter primary group (must exist):" 8 40 2> "$TMP_INPUT"
primary_group=$(<"$TMP_INPUT")

if ! getent group "$primary_group" > /dev/null; then
    show_error "Primary group does not exist."
    exit 1
fi

# 8. Secondary groups
dialog --inputbox "Enter secondary groups (comma-separated, optional):" 8 50 2> "$TMP_INPUT"
secondary_groups=$(<"$TMP_INPUT")

# Build useradd command
cmd="useradd -m -c \"$fullname\" -g $primary_group"
[ -n "$expiry" ] && cmd="$cmd -e $expiry"
[ -n "$secondary_groups" ] && cmd="$cmd -G $secondary_groups"
cmd="$cmd $username"

# Run useradd
eval "$cmd"
if [ $? -ne 0 ]; then
    show_error "Failed to create user."
    exit 1
fi

# Set password
echo "$username:$password" | chpasswd

# Set password expiry
chage -M "$pass_expire_days" "$username"

# Force password change on first login
chage -d 0 "$username"

# Lock if chosen
if [ $lock_choice -eq 0 ]; then
    usermod -L "$username"
    lock_status="🔒 (Locked)"
else
    lock_status="🔓 (Active)"
fi

# Show success dialog
show_success "✅ User '$username' created successfully.\n$lock_status"

# Log
log_action "Created user: $username, Expiry: $expiry, Groups: primary=$primary_group, secondary=$secondary_groups"

# Clean up
rm -f "$TMP_INPUT"
