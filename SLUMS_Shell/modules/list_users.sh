#!/bin/bash

echo "---- Existing Users ----"

printf "%-20s %-10s %-30s %-10s %-15s\n" "Username" "UID" "Groups" "Status" "Expiry"
echo "-----------------------------------------------------------------------------------------------"

# Avoid subshell by using process substitution
while read -r user; do
    uid=$(id -u "$user")
    groups=$(id -Gn "$user" | tr '\n' ',' | sed 's/,$//')
    status=$(passwd -S "$user" | awk '{print $2}')
    expiry=$(chage -l "$user" | grep "Account expires" | cut -d: -f2 | sed 's/^ *//')

    if [ "$status" == "L" ]; then
        status="Locked"
    else
        status="Active"
    fi

    [ -z "$expiry" ] && expiry="Never"

    printf "%-20s %-10s %-30s %-10s %-15s\n" "$user" "$uid" "$groups" "$status" "$expiry"
done < <(awk -F: '$3 >= 1000 && $1 != "nobody" { print $1 }' /etc/passwd)

echo
read -n 1 -s -r -p "Press any key to return to the main menu..."
clear
