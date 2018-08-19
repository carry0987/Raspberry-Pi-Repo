#!/bin/bash

set -e

read -p -r 'Please enter the path that you want to mount with>' mount
if [ -z $mount ]; then
    mkdir -p $mount
    chmod a+rx $mount
    read -p 'Please enter the name of remote>' rclone
    if [ -z $rclone ]; then
        rclone mount "$rclone": $mount --allow-other --allow-non-empty --vfs-cache-mode writes &
    else
        echo 'The name of remote should not be empty !'
        exit 0
    fi
else
    echo 'The path should not be empty !'
    exit 0
fi

#Make rclone auto mount at boot
wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Rclone-Mount/rclone.service
mv -v rclone.service /etc/systemd/system
chmod 660 /etc/systemd/system/rclone.service
systemctl daemon-reload
systemctl start rclone
systemctl enable rclone
systemctl status rclone
echo 'Wait 5 seconds to reboot...'
sleep 10
reboot
