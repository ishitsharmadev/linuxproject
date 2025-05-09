#!/bin/bash

# Temporary file to hold user data
temp_file=$(mktemp)

# Header
{
    printf "%-20s %-10s %-30s %-10s %-15s\n" "Username" "UID" "Groups" "Status" "Expiry"
    echo "-----------------------------------------------------------------------------------------------"

    # Collect user info
    while read -r user; do
        uid=$(id -u "$user")
        groups=$(id -Gn "$user" | tr '\n' ',' | sed 's/,$//')
        status=$(passwd -S "$user" | awk '{print $2}')
        expiry=$(chage -l "$user" | grep "Account expires" | cut -d: -f2 | sed 's/^ *//')

        # Determine status
        if [ "$status" == "L" ]; then
            status="Locked"
        else
            status="Active"
        fi

        [ -z "$expiry" ] && expiry="Never"

        printf "%-20s %-10s %-30s %-10s %-15s\n" "$user" "$uid" "$groups" "$status" "$expiry"
    done < <(awk -F: '$3 >= 1000 && $1 != "nobody" { print $1 }' /etc/passwd)
} > "$temp_file"

# Show in dialog box
dialog --title "List of Existing Users" --textbox "$temp_file" 20 100

# Cleanup
rm -f "$temp_file"
