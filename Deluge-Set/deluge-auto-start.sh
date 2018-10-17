#!/bin/bash

set -e

echo 'Setting auto start Deluge on boot...'
wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Deluge-Set/deluged.service
wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Deluge-Set/deluge-web.service
#sudo mv deluged.service /etc/systemd/system/
#sudo mv deluge-web.service /etc/systemd/system/
read -p 'Please enter the name of driver if you have set it in fstab, or just leave it blank>' deluge_mount
if [ -z $deluge_mount ]; then
    sed -i 's/After=network-online.target drive.mount/After=network-online.target/g' /home/pi/deluged.service
    sed -i '/Requires=drive.mount/d' /home/pi/deluged.service
    sed -i '/BindsTo=drive.mount/d' /home/pi/deluged.service
    sed -i 's/WantedBy=multi-user.target drive.mount/WantedBy=multi-user.target/g' /home/pi/deluged.service
fi

cat deluged.service

exit 0

#sudo chmod 660 /etc/systemd/system/deluged.service
#sudo chmod 660 /etc/systemd/system/deluge-web.service
#sudo systemctl daemon-reload
#sudo systemctl enable deluged.service
#sudo systemctl start deluged
#sudo systemctl status deluged
#sudo systemctl enable deluge-web.service
#sudo systemctl start deluge-web
#sudo systemctl status deluge-web
