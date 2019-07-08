#!/bin/sh

set -e

timestamp() {
    date +"%Y-%m-%d %T"
}

LOGDIR='/var/log/fan.log'
VALUE=45
TEMP=`vcgencmd measure_temp | cut -c6,7`

if [[ -e /sys/class/gpio/gpio2/value ]]; then
    sudo sh -c 'echo "out" > /sys/class/gpio/gpio2/direction'
    STATUS=`cat /sys/class/gpio/gpio2/value`
else
    sudo sh -c 'echo "2" > /sys/class/gpio/export'
    sudo sh -c 'echo "out" > /sys/class/gpio/gpio2/direction'
    STATUS=`cat /sys/class/gpio/gpio2/value`
fi

check_user=$USER
if [ $check_user == 'root' ]; then
    echo `timestamp` 'Info: Temperature: '$TEMP >> $LOGDIR
    if [[ $TEMP -ge $VALUE ]] && [[ $STATUS -eq 0 ]]; then
        echo `timestamp` 'Warning: Fan started.' >> $LOGDIR
        sh -c 'echo "1" > /sys/class/gpio/gpio2/value'
    elif [[ $TEMP -le $VALUE ]] && [[ $STATUS -eq 1 ]]; then
        echo `timestamp` 'Warning: Fan stopped.' >> $LOGDIR
        sh -c 'echo "0" > /sys/class/gpio/gpio2/value'
    fi
else
    sudo echo `timestamp` 'Info: Temperature: '$TEMP >> $LOGDIR
    if [[ $TEMP -ge $VALUE ]] && [[ $STATUS -eq 0 ]]; then
        sudo echo `timestamp` 'Warning: Fan started.' >> $LOGDIR
        sudo sh -c 'echo "1" > /sys/class/gpio/gpio2/value'
    elif [[ $TEMP -le $VALUE ]] && [[ $STATUS -eq 1 ]]; then
        sudo echo `timestamp` 'Warning: Fan stopped.' >> $LOGDIR
        sudo sh -c 'echo "0" > /sys/class/gpio/gpio2/value'
    fi
fi

exit 0
