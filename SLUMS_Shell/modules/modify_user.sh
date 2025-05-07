#!/bin/bash

source ./modules/logger.sh

echo "---- Modify User Info ----"
read -p "Enter the username to modify: " username

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "❌ User '$username' does not exist."
    exit 1
fi

echo "Select what you want to modify:"
echo "1. Change Username"
echo "2. Change Password"
echo "3. Modify Groups (Primary/Secondary)"
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        read -p "Enter new username: " new_username
        if id "$new_username" &>/dev/null; then
            echo "❌ Username already exists."
            exit 1
        fi
        usermod -l "$new_username" "$username"
        if [ $? -eq 0 ]; then
            echo "✅ Username changed from $username to $new_username."
            log_action "Changed username: $username ➜ $new_username"
        else
            echo "❌ Failed to change username."
        fi
        ;;
    2)
        passwd "$username"
        if [ $? -eq 0 ]; then
            echo "✅ Password changed for $username."
            log_action "Password changed for: $username"
        else
            echo "❌ Failed to change password."
        fi
        ;;
    3)
        echo "1. Change Primary Group"
        echo "2. Add Secondary Group"
        echo "3. Remove from Secondary Group"
        read -p "Enter choice [1-3]: " g_choice
        case $g_choice in
            1)
                read -p "Enter new primary group: " pgroup
                if ! getent group "$pgroup" > /dev/null; then
                    echo "❌ Group does not exist."
                    exit 1
                fi
                usermod -g "$pgroup" "$username"
                echo "✅ Primary group changed."
                log_action "Primary group for $username ➜ $pgroup"
                ;;
            2)
                read -p "Enter secondary group to add: " sgroup
                if ! getent group "$sgroup" > /dev/null; then
                    echo "❌ Group does not exist."
                    exit 1
                fi
                usermod -aG "$sgroup" "$username"
                echo "✅ Added to secondary group $sgroup."
                log_action "Added $username to secondary group: $sgroup"
                ;;
            3)
                read -p "Enter secondary group to remove: " rgroup
                current_groups=$(id -nG "$username" | sed "s/ /,/g" | sed "s/$rgroup,//;s/,$rgroup//;s/^$rgroup,//;s/,$rgroup,/,/")
                usermod -G "$current_groups" "$username"
                echo "✅ Removed from secondary group $rgroup."
                log_action "Removed $username from secondary group: $rgroup"
                ;;
            *)
                echo "❌ Invalid option."
                ;;
        esac
        ;;
    *)
        echo "❌ Invalid choice."
        ;;
esac
