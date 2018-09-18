#!/bin/bash

set -e

read -p 'Do you want to remove rclone-mount? [Y/N] ' detect

case $detect in
    [Yy])
        systemctl stop rclone
        systemctl disable rclone
        rm /etc/systemd/system/rclone.service
        ;;
    [Nn])
        exit 0
        ;;
esac

#Reboot
secs=$((5))
while [ $secs -gt 0 ]
do
    echo -ne 'Wait '"$secs\033[0K"' seconds to reboot'
    sleep 1
    : $((secs--))
done
reboot
