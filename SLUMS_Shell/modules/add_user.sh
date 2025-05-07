#!/bin/bash

# Import logger
source ./modules/logger.sh

echo "---- Add New User ----"

# Ask for username
read -p "Enter new username: " username
if id "$username" &>/dev/null; then
    echo "❌ User already exists!"
    exit 1
fi

# Ask for full name
read -p "Enter full name (optional): " fullname

# Ask for password
read -s -p "Enter password: " password
echo
read -s -p "Confirm password: " confirm_password
echo
if [ "$password" != "$confirm_password" ]; then
    echo "❌ Passwords do not match."
    exit 1
fi

# Ask for account expiry
read -p "Enter account expiry date (YYYY-MM-DD or leave blank for none): " expiry

# Ask for password expiry
read -p "Enter number of days before password expires (e.g., 30): " pass_expire_days

# Ask if account should be locked after creation
read -p "Lock the account after creation? (y/n): " lock_choice

# Ask for primary group
read -p "Enter primary group (must exist): " primary_group
if ! getent group "$primary_group" > /dev/null; then
    echo "❌ Primary group does not exist."
    exit 1
fi

# Ask for secondary groups
read -p "Enter secondary groups (comma-separated, optional): " secondary_groups

# Create user command
cmd="useradd -m -c \"$fullname\" -g $primary_group"

# Add expiry if provided
[ -n "$expiry" ] && cmd="$cmd -e $expiry"

# Add secondary groups
[ -n "$secondary_groups" ] && cmd="$cmd -G $secondary_groups"

# Final useradd
cmd="$cmd $username"
eval "$cmd"

if [ $? -ne 0 ]; then
    echo "❌ Failed to create user."
    exit 1
fi

# Set password
echo "$username:$password" | chpasswd

# Set password expiry
chage -M "$pass_expire_days" "$username"

# Force password change on first login
chage -d 0 "$username"

# Lock account if selected
if [[ "$lock_choice" == "y" || "$lock_choice" == "Y" ]]; then
    usermod -L "$username"
    echo "🔒 Account locked."
fi

echo "✅ User $username created successfully."

# Log the action
log_action "Created user: $username, Expiry: $expiry, Groups: primary=$primary_group, secondary=$secondary_groups"
