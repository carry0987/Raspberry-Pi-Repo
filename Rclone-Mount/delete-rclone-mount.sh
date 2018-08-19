#!/bin/bash

set -e

systemctl stop rclone
systemctl disable rclone
rm /etc/systemd/system/rclone.service
rm -Rf /home/pi/gdrive
reboot
