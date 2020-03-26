#!/bin/bash

set -e

check_user=$USER
script_path="$(cd "$(dirname "$0")"; pwd -P)"

#Install openjdk
if ! [ -x "$(command -v java)" ]; then
    echo 'openjdk is not installed' >&2
    apt-get update
    apt-get dist-upgrade
    sudo apt-get install openjdk-8-jdk
    sudo apt-get install openjdk-8-jre
    apt-get clean
fi

#Get mount driver path
echo 'Please enter the path of External Hard Drive, '
read -p 'or just leave blank if the path is /media/hd/hath> ' start_set_up
if [ -z $start_set_up ]; then
    cd /media/hd/hath
    sudo chmod 777 /media/hd/hath
else
    cd $start_set_up
    sudo chmod 777 $start_set_up
fi
sudo wget https://repo.e-hentai.org/hath/HentaiAtHome_1.6.0.zip
sudo unzip HentaiAtHome_1.6.0.zip
wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/HatH/client.sh
su pi -c 'screen -d -m -S HatH bash -c "client.sh;exec bash"'
#su pi -c 'screen -S HatH -dm bash -c "rclone --version; exec bash -i"'

echo 'Finish'

exit 0
