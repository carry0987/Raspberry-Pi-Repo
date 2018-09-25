#!/bin/bash

set -e

#Install FUSE
apt-get install fuse

#Install Rclone
if ! [ -x "$(command -v rclone)" ]
then
    echo 'Rclone is not installed.' >&2
    curl https://rclone.org/install.sh | sudo bash
    su pi -c 'rclone config'
fi

read -p 'Please enter the name of remote>' rclone
if [ -n $rclone ]; then
    read -p 'Please enter the path of remote, just leave blank if you want to mount whole remote drive>' remote_path
    if [ -n $remote_path ]; then
        read -e -p 'Please enter the path that you want to mount with>' mount
        if [ -n $mount ]; then
            chmod 777 $mount
            su pi -c "rclone mount $rclone':'$remote_path $mount --allow-non-empty --vfs-cache-mode writes &"
        else
            echo 'The path of mount point should not be empty !'
            exit 0
        fi
    else
        echo 'The path of remote should not be empty !'
        exit 0
    fi
else
    echo 'The name of remote should not be empty !'
    exit 0
fi

#Make rclone auto mount at boot
#sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf
wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Rclone-Mount/rclone.service
mv -v rclone.service /etc/systemd/system
sed '7 aExecStart=/usr/bin/rclone mount '${rclone}':'${remote_path}' '${mount}' --allow-non-empty --vfs-cache-mode writes' -i /etc/systemd/system/rclone.service
chmod 660 /etc/systemd/system/rclone.service
systemctl daemon-reload
systemctl start rclone
systemctl enable rclone
systemctl status rclone
secs=$((5))
while [ $secs -gt 0 ]
do
    echo -ne 'Wait '"$secs\033[0K"' seconds to reboot'"\r"
    sleep 1
    : $((secs--))
done
reboot
