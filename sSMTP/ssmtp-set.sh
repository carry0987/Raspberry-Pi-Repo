#!/bin/bash

set -e

# Set path & user
check_user=$USER
script_path="$(cd "$(dirname "$0")"; pwd -P)"

echo '1) Set sSMTP'
echo '2) Exit'
read -p 'Please choose what you want to do>' var

case $var in
    1)
        # Check sSMTP
        if ! [ -x "$(command -v ssmtp)" ]; then
            echo 'sSMTP is not installed.' >&2
            sudo apt-get update
            sudo apt-get dist-upgrade
            sudo apt-get install ssmtp mailutils
        fi
        # Check operating user
        if [[ $check_user == 'root' ]]; then
            read -e -p 'Where is your .bashrc file? /home/>' select_user
        fi
        echo 'Setting sSMTP...'
        read -p 'Please enter sender email address> ' email
        echo 'Sender email address is '$email
        if [[ -e /etc/ssmtp/ssmtp.conf ]]; then
            sudo cp /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.bak
            sudo rm -rf /etc/ssmtp/ssmtp.conf
        fi
        wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/sSMTP/ssmtp.conf
        sed -i 's/AuthUser=user@gmail.com/AuthUser='${email}'/g' /home/${select_user}/ssmtp.conf
        echo "If you don't have the App Password, please go here to get the password:"
        echo 'https://security.google.com/settings/security/apppasswords'
        read -p 'Please enter your email password> ' password
        sed -i 's/AuthPass=authpass/AuthPass='${password}'/g' /home/${select_user}/ssmtp.conf
        sudo mv /home/${select_user}/ssmtp.conf /etc/ssmtp/
        if [[ $(getent group ssmtp) ]]; then
            echo 'group ssmtp exists'
        else
            sudo groupadd ssmtp
        fi
        sudo chown :ssmtp /etc/ssmtp/ssmtp.conf
        sudo chown :ssmtp /usr/sbin/ssmtp
        sudo chmod 640 /etc/ssmtp/ssmtp.conf
        sudo chmod g+s /usr/sbin/ssmtp
        echo 'Sending test email...'
        read -p 'Please enter receiver email address> ' receiver
        echo 'Receiver Email is '$receiver
        echo "This is a test" | ssmtp $receiver
        ;;
    2)
        echo 'Exited'
        exit 0
        ;;
    *)
        echo 'You can only choose Yes or No'
        exit 0
        ;;
esac

echo 'Setting Success !'

exit 0
