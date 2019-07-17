#!/bin/bash

set -e

# Set path & user
check_user=$USER
script_path="$(cd "$(dirname "$0")"; pwd -P)"

echo '1) Set mSMTP'
echo '2) Exit'
read -p 'Please choose what you want to do>' var

case $var in
    1)
        # Check mSMTP
        if ! [ -x "$(command -v msmtp)" ]; then
            echo 'mSMTP is not installed.' >&2
            sudo apt-get update
            sudo apt-get dist-upgrade
            sudo apt-get install msmtp ca-certificates
        fi
        # Check operating user
        if [[ $check_user == 'root' ]]; then
            read -e -p 'Where is your .bashrc file? /home/>' select_user
        fi
        echo 'Setting mSMTP...'
        read -p 'Please enter sender email address> ' email
        echo 'Sender email address is '$email
        sudo mkdir -v /etc/msmtp
        sudo mkdir -v /var/log/msmtp
        wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/mSMTP/gmail-msmtprc
        sed -i 's/user example@gmail.com/user '${email}'/g' /home/${select_user}/gmail-msmtprc
        sed -i 's/from example@gmail.com/from '${email}'/g' /home/${select_user}/gmail-msmtprc
        echo "If you don't have the App Password, please go here to get the password:"
        echo 'https://security.google.com/settings/security/apppasswords'
        read -p 'Please enter your email password> ' password
        sed -i 's/password passwd/password '${password}'/g' /home/${select_user}/gmail-msmtprc
        sudo mv /home/${select_user}/gmail-msmtprc /etc/msmtp/
        echo 'Sending test email...'
        read -p 'Please enter receiver email address> ' receiver
        echo 'Receiver Email is '$receiver
        echo "This is a test" | msmtp $receiver
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
