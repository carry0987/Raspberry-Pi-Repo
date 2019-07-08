#!/bin/bash

set -e

# Set path & user
check_user=$USER
script_path="$(cd "$(dirname "$0")"; pwd -P)"

# Check operating user
if [ $check_user == 'root' ]; then
    read -e -p 'Where is your .bashrc file? /home/>' select_user
fi

echo '1) Set WiFi Reconnect'
echo '2) Set Auto Report IP (Shell)'
echo '3) Set Auto Report IP (Python)'
echo '4) Exit'
read -p 'Please choose what you want to do>' var

case $var in
    1)
        wget -P /usr/local/bin https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-WiFi-Reconnect/wifi-reconnect.sh
        chmod +x /usr/local/bin/wifi-reconnect.sh
        echo '* * * * * root /usr/local/bin/wifi-reconnect.sh >/dev/null 2>&1' >> /etc/crontab
        ;;
    2)
        # Check sSMTP
        if ! [ -x "$(command -v ssmtp)" ]; then
            echo 'sSMTP is not installed.' >&2
            sudo apt-get update
            sudo apt-get dist-upgrade
            sudo apt-get install ssmtp mailutils
        fi
        echo 'Installing IP Auto Reporter (Shell)...'
        wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-Report-IP/report-ip.sh
        read -p 'Please enter this device name>' name
        echo 'Name: ' $name
        sed -i 's/sender=\[HatH\]/sender='${name}'/g' /home/${select_user}/report-ip.sh
        read -p 'Please enter sender email address> ' email
        echo 'Sender email address is '$email
        sed -i 's/email_from='\'Sender@gmail.com\''/email_from='\'${email}\''/g' /home/${select_user}/report-ip.sh
        echo 'Setting up sSMTP...'
        sudo cp /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.bak
        sudo rm -rf /etc/ssmtp/ssmtp.conf
        wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/sSMTP/ssmtp.conf
        sed -i 's/AuthUser=user@gmail.com/AuthUser='${email}'/g' /home/${select_user}/ssmtp.conf
        #read -p 'Please enter email address that used to receive system info> ' ssmtp_root
        #sed -i 's/root=localhost/root='${ssmtp_root}'/g' /home/${select_user}/ssmtp.conf
        #read -p 'Please enter the hostname that you want to use> ' ssmtp_hostname
        #sed -i 's/hostname=raspberrypi/hostname='${ssmtp_hostname}'/g' /home/${select_user}/ssmtp.conf
        echo "If you don't have the App Password, please go here to get the password:"
        echo 'https://security.google.com/settings/security/apppasswords'
        read -p 'Please enter your email password> ' password
        sed -i 's/AuthPass=authpass/AuthPass='${password}'/g' /home/${select_user}/ssmtp.conf
        sudo mv /home/${select_user}/ssmtp.conf /etc/ssmtp/
        sudo groupadd ssmtp
        sudo chown :ssmtp /etc/ssmtp/ssmtp.conf
        sudo chown :ssmtp /usr/sbin/ssmtp
        sudo chmod 640 /etc/ssmtp/ssmtp.conf
        sudo chmod g+s /usr/sbin/ssmtp
        read -p 'Please enter receiver email address> ' receiver
        echo 'Receiver Email is '$receiver
        sed -i 's/email_to='\'Receiver@gmail.com\''/email_to='\'${receiver}\''/g' /home/${select_user}/report-ip.sh
        chmod +x report-ip.sh
        mv report-ip.sh /usr/local/bin
        wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-Report-IP/report-ip-sh.service
        mv report-ip-sh.service /etc/systemd/system
        systemctl enable report-ip-sh
        systemctl start report-ip-sh
        systemctl status report-ip-sh
        echo '* * * * * root /bin/bash /usr/local/bin/report-ip.sh >/dev/null 2>&1' >> /etc/crontab
        ;;
    3)
        echo 'Installing IP Auto Reporter (Python)...'
        wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-Report-IP/report-ip.py
        read -p 'Please enter this device name>' name
        echo 'Name: ' $name
        sed -i 's/sender = "RPi"/sender = "'${name}'"/g' /home/${select_user}/report-ip.py
        read -p 'Please enter sender email address> ' email
        echo 'Sender email address is '$email
        sed -i 's/username = "Sender@gmail.com"/username = "'${email}'"/g' /home/${select_user}/report-ip.py
        echo "If you don't have the App Password, please go here to get the password:"
        echo 'https://security.google.com/settings/security/apppasswords'
        read -p 'Please enter your email password> ' password
        sed -i 's/password = "Sender Password"/password = "'${password}'"/g' /home/${select_user}/report-ip.py
        read -p 'Please enter receiver email address> ' receiver
        echo 'Receiver Email is '$receiver
        sed -i 's/receiver = \["Receiver@gmail.com"\]/receiver = \["'$receiver'"\]/g' /home/${select_user}/report-ip.py
        chmod +x report-ip.py
        mv report-ip.py /usr/local/bin
        wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-Report-IP/report-ip-py.service
        mv report-ip-py.service /etc/systemd/system
        systemctl enable report-ip-py
        systemctl start report-ip-py
        systemctl status report-ip-py
        echo '* * * * * root /usr/bin/python3.5 /usr/local/bin/report-ip.py >/dev/null 2>&1' >> /etc/crontab
        ;;
    4)
        echo 'Exited'
        exit 0
        ;;
    *)
        echo 'You can only choose Yes or No'
        exit 0
        ;;
esac
