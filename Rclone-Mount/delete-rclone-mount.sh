#!/bin/bash

set -e

read -p 'Do you want to remove rclone-mount? [Y/N] ' detect

case $detect in
    [Yy])
        systemctl stop rclone
        systemctl disable rclone
        rm /etc/systemd/system/rclone.service
        rm -Rf /home/pi/gdrive
        ;;
    [Nn])
        exit 0
        ;;
esac

reboot
