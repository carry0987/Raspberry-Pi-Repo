#!/bin/bash

set -e

echo 'LANGUAGE=en_US.UTF-8' >> /etc/default/locale
echo 'LC_ALL=en_US.UTF-8' >> /etc/default/locale
echo 'LC_TYPE=en_US.UTF-8' >> /etc/default/locale

sudo reboot
