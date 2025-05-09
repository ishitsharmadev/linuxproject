#!/bin/bash

echo "SLUMS script is started..."

# ------ INIT ------
source modules/logger.sh

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root!"
    exit 1
fi



# ------ MAIN MENU FUNCTION ------
main_menu() {
    while true; do
        

        CHOICE=$(dialog --clear --backtitle "SLUMS - Smart Linux User Management Suite" \
            --title "Main Menu" \
            --menu "Choose an option:" 20 60 10 \
            1 "Add New User" \
            2 "Delete User" \
            3 "Modify User Info" \
            4 "List Existing Users" \
            5 "Smart Actions & Insights" \
            6 "View Logs" \
            7 "Exit" \
            8 "Lock Session" \
            3>&1 1>&2 2>&3)

        stop_session_lock  # Stop before running any module

        clear
        case $CHOICE in
            1) 
                bash modules/add_user.sh
                log_action "Added new user"
                ;;
            2) 
                bash modules/delete_user.sh
                log_action "Deleted a user"
                ;;
            3) 
                bash modules/modify_user.sh
                log_action "Modified user info"
                ;;
            4) 
                bash modules/list_users.sh
                log_action "Listed users"
                ;;
            5) 
                bash modules/smart_actions.sh
                log_action "Performed smart actions"
                ;;
            6) 
                dialog --textbox /var/log/slums.log 20 70
                log_action "Viewed logs"
                ;;
            7) 
                log_action "Exited SLUMS"
                break
                ;;
            8) 
    		bash modules/session_lock.sh
    		log_action "Locked the session"
    		;;
            *) 
                dialog --msgbox "Invalid choice!" 10 30
                log_action "Invalid menu choice"
                ;;
        esac
    done
    
}

# ------ RUN ------
main_menu
