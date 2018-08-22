#!/bin/bash

set -e

rm /etc/default/locale
touch /etc/default/locale
chmod 644 /etc/default/locale

read -p 'Please type your Language>' language

echo 'LANG='$language >> /etc/default/locale
echo 'LANGUAGE='$language >> /etc/default/locale
echo 'LC_ALL='$language >> /etc/default/locale
echo 'LC_TYPE='$language >> /etc/default/locale

echo '#####################'
cat /etc/default/locale
echo '#####################'

sudo reboot
