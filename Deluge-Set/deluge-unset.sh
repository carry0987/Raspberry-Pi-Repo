#!/bin/bash

set -e

# Check Deluge
if ! [ -x "$(command -v deluged)" ]; then
    echo 'Deluge is not installed.' >&2
    echo 'Nothing can be uninstall'
    exit 0
fi

# Pkill Deluge
check_user=$USER
if [ $check_user == 'root' ]; then
    read -p 'The current user is Root now, please enter your current user or leave blank if you want to run the script under Root>' select_user
    su $select_user -c "pkill deluged"
else
    su $USER -c "pkill deluged"
fi

# Remove Deluge purge
read -p 'Do you want to remove deluge and related packages ? [Y/N]' remove_deluge_purge
if [[ $remove_deluge_purge =~ ^([Yy])+$ ]]; then
    echo 'Remove entire deluge...'
    sudo apt-get update
    sudo apt-get remove --auto-remove --purge *deluge*
elif [[ $remove_deluge_purge =~ ^([Nn])+$ ]]; then
    echo 'Canceled'
    exit 0
else
    echo 'You can only choose yes or no'
    exit 0
fi

# Check if deluge config file exist
if [ -z '/home/pi/.config/deluge/' ]; then
    read -p 'Do you want to clean up deluge config ? [Y/N]' remove_deluge_config
    if [[ $remove_deluge_config =~ ^([Yy])+$ ]]; then
        echo 'Clean up deluge config...'
        sudo rm -rvf /home/pi/.config/deluge
    elif [[ $remove_deluge_config =~ ^([Nn])+$ ]]; then
        echo 'Canceled'
        exit 0
    else
        echo 'You can only choose yes or no'
        exit 0
    fi
fi

echo 'Disable deluge service...'
sudo systemctl stop deluged.service
sudo systemctl disable deluged.service
sleep 3
sudo systemctl stop deluge-web.service
sudo systemctl disable deluge-web.service
echo 'Wait for reboot....'
sleep 3
sudo reboot
