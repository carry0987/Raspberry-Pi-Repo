#!/usr/bin/env bash

set -e

# Set path & user
check_user=$USER
script_path="$(cd "$(dirname "$0")"; pwd -P)"

# Set fan control
read -p 'Set up fan control? [Y/N]> ' start_set_fan
if [[ $start_set_fan =~ ^([Yy])+$ ]]; then
    wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Fan-Control/fan.sh
    chmod +x fan.sh
    sudo mv -v fan.sh /usr/local/bin
    wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Fan-Control/fan-pwm.service
    mv fan-pwm.service /etc/systemd/system
    systemctl enable fan-pwm
    systemctl start fan-pwm
    systemctl status fan-pwm
    echo '* * * * * root /bin/bash /usr/local/bin/fan.sh >/dev/null 2>&1' >> /etc/crontab
elif [[ $start_set_fan =~ ^([Nn])+$ ]]; then
    echo 'Exit'
    exit 0
else
    echo 'You can only choose yes or no'
    exit 0
fi

exit 0
