# SLUMS - Shell-based Linux User Management System

SLUMS is a Bash-based modular system for managing Linux users from the command line. It provides essential administrative functions such as adding, deleting, modifying users, and managing sessions, all while maintaining logs for audit purposes.

## Features

- Add new users
- Delete existing users
- Modify user details
- List current system users
- Lock/unlock sessions
- Log user management actions
- Modular structure for easy customization and maintenance

## File Structure
SLUMS_Shell/
├── slums.sh # Main script to run the system
├── modules/ # Modular scripts for specific operations
│ ├── add_user.sh
│ ├── delete_user.sh
│ ├── modify_user.sh
│ ├── list_users.sh
│ ├── logger.sh
│ ├── session_lock.sh
│ └── smart_actions.sh
└── logs/
└── slums.log # Activity log


## Prerequisites

- Linux/Unix system with Bash
- Root or sudo privileges for managing users

## Usage

Run the main script:

```bash
sudo bash slums.sh

