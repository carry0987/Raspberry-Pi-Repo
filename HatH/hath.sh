#!/bin/bash

wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/HatH/client.sh
su pi -c 'screen -d -m -S HatH bash -c "client.sh;exec bash"'
