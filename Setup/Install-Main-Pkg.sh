#!/bin/bash

set -e

timedatectl set-ntp yes
bash -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'
bash -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'
sysctl -p
apt-get update
apt-get dist-upgrade
apt-get install zip vsftpd unzip wget vim screen smartmontools
wget -P /usr/local/bin https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-WiFi-Reconnect/wifi-reconnect.sh
chmod +x /usr/local/bin/wifi-reconnect.sh
echo '* * * * * root /usr/local/bin/wifi-reconnect.sh' >> /etc/crontab

read -p 'Do you want to install IP Auto Reporter? [Y/N]' var

case $var in
  [Yy])
    echo 'Installing IP Auto Reporter...'
    wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-Report-IP/report-ip.py
    read -p 'Please enter your email address> ' email
    echo 'Sender is '$email
    sed -i 's/username = "Sender@gmail.com"/username = "'${email}'"/g' /home/pi/report-ip.py
    echo "If you don't have the App Password, please go here to get the password: \nhttps://security.google.com/settings/security/apppasswords"
    read -p 'Please enter your email password> ' password
    sed -i 's/password = "Sender Password"/password = "'${password}'"/g' /home/pi/report-ip.py
    read -p 'Please enter receiver email address> ' receiver
    echo 'Receiver Email is '$receiver
    sed -i 's/receiver = \["Receiver@gmail.com"\]/receiver = \["'$receiver'"\]/g' /home/pi/report-ip.py
    chmod +x report-ip.py
    mv report-ip.py /usr/local/bin
    wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-Report-IP/report-ip.service
    mv report-ip.service /etc/systemd/system
    systemctl enable report-ip
    systemctl start report-ip
    systemctl status report-ip
    echo '* * * * * root /usr/bin/python3.5 /usr/local/bin/report-ip.py' >> /etc/crontab
    ;;
  [Nn])
    echo 'Setting up rclone...'
    ;;
  *)
    echo 'You can only choose Yes or No'
    exit 2
    ;;
esac

service cron restart
curl https://rclone.org/install.sh | sudo bash
echo 'Wait 10 seconds...'
sleep 10
reboot

exit 0
