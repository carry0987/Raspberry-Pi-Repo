#!/bin/bash

set -e

#Set Time & Date NTP
timedatectl set-ntp yes

#Check if TCP-BBR has already setup
if [ `grep -c "net.core.default_qdisc=fq" /etc/sysctl.conf` -eq '1' ]; then
    bbr_qdisc=1
else
    bash -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'
    echo 'Successful setting net core'
    bbr_qdisc=2
fi

if [ `grep -c "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf` -eq '1' ]; then
    bbr_tcc=1
else
    bash -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'
    echo 'Successful setting tcp congestion control'
    bbr_tcc=2
fi

if [[ $bbr_qdisc -eq '1' && $bbr_tcc -eq '1' ]]; then
    echo 'TCP-BBR has already setup !'
elif [[ $bbr_qdisc -eq '2' || $bbr_tcc -eq '2' ]]; then
    echo '######################'
    echo 'TCP-BBR'
    echo '######################'
    sysctl -p
    sysctl net.ipv4.tcp_available_congestion_control
else
    echo 'Failed to set up TCP-BBR'
fi

#Update package list
apt-get update
apt-get dist-upgrade
apt-get install zip vsftpd unzip wget vim screen smartmontools
apt-get clean
wget -P /usr/local/bin https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-WiFi-Reconnect/wifi-reconnect.sh
chmod +x /usr/local/bin/wifi-reconnect.sh
echo '* * * * * root /usr/local/bin/wifi-reconnect.sh' >> /etc/crontab

read -p 'Do you want to install IP Auto Reporter? [Y/N]' var

case $var in
  [Yy])
    echo 'Installing IP Auto Reporter...'
    wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-Report-IP/report-ip.py
    read -p 'Please enter this device name>' name
    echo 'Name: ' $name
    sed -i 's/sender = "RPi"/sender = "'${name}'"/g' /home/pi/report-ip.py
    read -p 'Please enter sender email address> ' email
    echo 'Sender email address is '$email
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
    echo 'Setting up...'
    ;;
  *)
    echo 'You can only choose Yes or No'
    exit 2
    ;;
esac

service cron restart
echo 'Wait 5 seconds to reboot...'
sleep 5
reboot

exit 0
