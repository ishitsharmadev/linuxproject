#!/bin/bash

# Import logger
source ./modules/logger.sh

TMP_INPUT=$(mktemp)

# Function to show error
show_error() {
    dialog --title "Error" --msgbox "$1" 8 50
}

# Function to show success
show_success() {
    dialog --title "Success" --msgbox "$1" 8 50
}

# Prompt for username
dialog --inputbox "Enter username to modify:" 8 50 2> "$TMP_INPUT"
username=$(<"$TMP_INPUT")

# Check if user exists
if ! id "$username" &>/dev/null; then
    show_error "User '$username' does not exist!"
    rm -f "$TMP_INPUT"
    exit 1
fi

# Menu to choose what to modify
dialog --menu "What would you like to modify?" 15 50 5 \
    1 "Change Full Name (Comment Field)" \
    2 "Change Primary Group" \
    3 "Change Secondary Groups" \
    4 "Lock/Unlock Account" \
    5 "Change Password" 2> "$TMP_INPUT"

choice=$(<"$TMP_INPUT")

case $choice in
    1)
        dialog --inputbox "Enter new full name:" 8 50 2> "$TMP_INPUT"
        newname=$(<"$TMP_INPUT")
        usermod -c "$newname" "$username"
        if [ $? -eq 0 ]; then
            show_success "Full name updated."
            log_action "Modified full name for $username to $newname"
        else
            show_error "Failed to update full name."
        fi
        ;;
    2)
        dialog --inputbox "Enter new primary group (must exist):" 8 50 2> "$TMP_INPUT"
        newgroup=$(<"$TMP_INPUT")
        if getent group "$newgroup" > /dev/null; then
            usermod -g "$newgroup" "$username"
            if [ $? -eq 0 ]; then
                show_success "Primary group updated."
                log_action "Changed primary group of $username to $newgroup"
            else
                show_error "Failed to change group."
            fi
        else
            show_error "Group does not exist."
        fi
        ;;
    3)
        dialog --inputbox "Enter new secondary groups (comma-separated):" 8 50 2> "$TMP_INPUT"
        newgroups=$(<"$TMP_INPUT")
        usermod -G "$newgroups" "$username"
        if [ $? -eq 0 ]; then
            show_success "Secondary groups updated."
            log_action "Updated secondary groups for $username to $newgroups"
        else
            show_error "Failed to update groups."
        fi
        ;;
    4)
        # Check if account is locked
        passwd -S "$username" | grep -q "L"
        if [ $? -eq 0 ]; then
            dialog --yesno "Account is currently LOCKED. Unlock it?" 8 50
            if [ $? -eq 0 ]; then
                usermod -U "$username"
                show_success "Account unlocked."
                log_action "Unlocked account $username"
            fi
        else
            dialog --yesno "Account is currently UNLOCKED. Lock it?" 8 50
            if [ $? -eq 0 ]; then
                usermod -L "$username"
                show_success "Account locked."
                log_action "Locked account $username"
            fi
        fi
        ;;
    5)
        dialog --insecure --passwordbox "Enter new password:" 8 50 2> "$TMP_INPUT"
        password=$(<"$TMP_INPUT")
        echo "$username:$password" | chpasswd
        if [ $? -eq 0 ]; then
            show_success "Password updated successfully."
            log_action "Changed password for $username"
        else
            show_error "Failed to update password."
        fi
        ;;
    *)
        show_error "Invalid choice."
        ;;
esac

# Cleanup
rm -f "$TMP_INPUT"
