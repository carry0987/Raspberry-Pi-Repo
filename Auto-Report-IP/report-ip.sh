#!/bin/bash

set -e

# Set ip curl
ip_url='https://icanhazip.com/'
public_ip=`curl -s4 $ip_url`

# Reciver Email
email_to='Receiver@gmail.com'
email_from='Sender@gmail.com'
sender=[HatH]
subject_changed=$sender' IP CHANGED'
subject_not_changed=$sender' IP INFO'

# Check IP
if [ -e /home/pi/last-ip.log ]; then
    last_ip_permission=`stat -c %A /home/pi/last-ip.log`
    if [[ last_ip_permission != '-rw-r--r--' ]]; then
        sudo chmod 777 /home/pi/last-ip.log
    fi
    last_ip=`cat /home/pi/last-ip.log`
else
    touch /home/pi/last-ip.log
    echo 'Default' > /home/pi/last-ip.log
    last_ip=`cat /home/pi/last-ip.log`
fi

if [ $public_ip != $last_ip ]; then
    echo $public_ip > /home/pi/last-ip.log
    echo 'IP changed. New ip: '$public_ip
    {
        echo To: $email_to
        echo From: $email_from
        echo Subject: $subject_changed
        echo $public_ip
    } | msmtp $email_to --file=/etc/msmtp/gmail-msmtprc
    echo 'Successfully send the e-mail.'
else
    echo 'IP not change.'
#    {
#        echo To: $email_to
#        echo From: $email_from
#        echo Subject: $subject_not_changed
#        echo $public_ip
#    } | msmtp $email_to --file=/etc/msmtp/gmail-msmtprc
#    echo 'Successfully send the e-mail.'
fi

exit 0
