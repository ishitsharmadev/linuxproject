#!/bin/bash

# Show menu to choose a smart insight
CHOICE=$(dialog --clear --backtitle "Smart Actions & Insights" \
    --title "Choose Insight Type" \
    --menu "Select an action to perform:" 15 50 4 \
    1 "Users inactive for 30+ days" \
    2 "Users with weak/never-changed passwords" \
    3 "Privileged group members" \
    3>&1 1>&2 2>&3)

clear

case $CHOICE in
    1)
        echo "📌 Users inactive for 30+ days:" > /tmp/slums_smart_output
        lastlog -b 30 | awk 'NR>1 && $NF!="*Never logged in*" {print $1, $4, $5, $6}' >> /tmp/slums_smart_output
        [ ! -s /tmp/slums_smart_output ] && echo "None found." >> /tmp/slums_smart_output
        dialog --textbox /tmp/slums_smart_output 20 70
        ;;

    2)
        echo "📌 Users with weak/never-changed passwords:" > /tmp/slums_smart_output
        for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
            pw_expire=$(chage -l "$user" | grep "Password expires" | cut -d: -f2 | xargs)
            if [[ "$pw_expire" == "never" || "$pw_expire" == "Password inactive" ]]; then
                echo "$user - Password never changed or inactive" >> /tmp/slums_smart_output
            fi
        done
        [ ! -s /tmp/slums_smart_output ] && echo "None found." >> /tmp/slums_smart_output
        dialog --textbox /tmp/slums_smart_output 20 70
        ;;

    3)
        echo "📌 Users in privileged groups (sudo, adm, docker):" > /tmp/slums_smart_output
        for grp in sudo adm docker; do
            members=$(getent group $grp | cut -d: -f4)
            if [ -n "$members" ]; then
                echo "$grp: $members" >> /tmp/slums_smart_output
            else
                echo "$grp: No members" >> /tmp/slums_smart_output
            fi
        done
        dialog --textbox /tmp/slums_smart_output 20 70
        ;;
        
    *)
        dialog --msgbox "Invalid choice!" 10 30
        ;;
esac
