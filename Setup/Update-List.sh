#!/bin/bash

sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get clean

#Get mount driver path
read -p 'Reboot ? [Y/N]> ' check_reboot
if [[ $check_reboot =~ ^([Yy])+$ ]]; then
    sudo reboot
elif [[ $check_reboot =~ ^([Nn])+$ ]]; then
    exit 0
else
    echo 'You can only choose yes or no'
    exit 0
fi
