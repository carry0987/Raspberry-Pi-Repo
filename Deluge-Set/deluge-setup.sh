#!/bin/bash

set -e

#Check Deluge
if ! [ -x "$(command -v deluged)" ]; then
    echo 'Deluge is not installed.' >&2
    sudo apt-get update
    sudo apt-get dist-upgrade
    echo 'deb http://ftp.us.debian.org/debian sid main' >> /etc/apt/sources.list
    sudo apt-get update
    sudo apt-get install deluged deluge-console
    sed -i '/deb http:\/\/ftp.us.debian.org\/debian sid main/d' /etc/apt/sources.list
    sudo apt-get update
    sudo apt-get clean
fi

# Check if deluge stat file exist
if [ -z '/home/pi/.config/deluge/state/torrents.state' ]; then
        echo 'Make up stat file...'
        sudo touch /home/pi/.config/deluge/state/torrents.state
fi

if [ -z '/home/pi/.config/deluge/state/torrents.state.bak' ]; then
        echo 'Make up stat.bak file...'
        sudo touch /home/pi/.config/deluge/state/torrents.state.bak
fi

#Check if deluge conf file exist
#if [ -e '/home/pi/.config/deluge/core.conf' ]; then
#        echo 'Make up core.conf file...'
#        sudo chmod 777 /home/pi/.config/deluge/core.conf
#fi
#
#if [ -e '/home/pi/.config/deluge/web.conf' ]; then
#        echo 'Make up web.conf file...'
#        sudo chmod 777 /home/pi/.config/deluge/web.conf
#fi

# Setting Deluge
check_user=$USER
if [ $check_user == 'root' ]; then
    read -p 'The current user is Root now, please enter your rclone user or leave blank if you want to run rclone under Root>' select_user
    su $select_user -c "deluged"
    echo 'Waiting for deluge start....'
    sleep 3
    read -p 'Please enter the username that you allowed to use deluge, just leave blank if the user is pi>' deluge_user
    if [ -z $deluge_user ]; then
        set_user=pi
    else
        set_user=$deluge_user
    fi

    #Set deluge user
    read -p 'Please enter the password for '$set_user'>' deluge_pass

    #Check if deluge user has already setup
    if [ -e '/home/pi/.config/deluge/auth' ]; then
        if [ `grep -c "${set_user}:${deluge_pass}:10" /home/pi/.config/deluge/auth` -eq '1' ]; then
            echo 'This user has already setup !'
        else
            echo ${set_user}':'${deluge_pass}':10' >> /home/pi/.config/deluge/auth
            echo 'Successful setting Deluge User'
        fi
    fi
    su $select_user -c "deluge-console config -s allow_remote True"
    su $select_user -c "deluge-console config allow_remote"
    su $select_user -c "deluge-console config -s max_upload_slots_global 15"
    su $select_user -c "deluge-console config -s max_active_limit 18"
    su $select_user -c "deluge-console config -s max_active_downloading 15"
    su $select_user -c "deluge-console config -s max_active_seeding 3"
    #Set Deluge download path
    read -e -p 'Please enter deluge base path, or just leave blank if the path is /media/hd>' set_deluge_base
    if [ -z $set_deluge_base ]; then
        deluge_base=/media/hd
    else
        deluge_base=${set_deluge_base%/}
    fi

    echo 'Please enter the directory for downloading files, or just leave blank if the path is '$deluge_base'/deluge/downloading :'
    read -e -p '>'$deluge_base'/' deluge_downloading
    if [ -z $deluge_downloading ]; then
        if [[ ! -d "$deluge_base"/deluge/downloading ]]; then
            sudo mkdir -p $deluge_base/deluge/downloading
            sudo chmod 777 $deluge_base/deluge/downloading
        fi
        echo 'Setting up download location to '${deluge_base}'/deluge/downloading'
        su $select_user -c "deluge-console config -s download_location ${deluge_base}/deluge/downloading"
    else
        sudo mkdir -p $deluge_base/${deluge_downloading%/}
        sudo chmod 777 $deluge_base/${deluge_downloading%/}
        echo 'Setting up download location to '${deluge_base}'/'${deluge_downloading%/}
        su $select_user -c "deluge-console config -s download_location ${deluge_base}/${deluge_downloading%/}"
    fi

    echo 'Please enter the directory for completed files, or just leave blank if the path is '$deluge_base'/deluge/completed :'
    read -e -p '>'$deluge_base'/' deluge_completed
    if [ -z $deluge_completed ]; then
        if [[ ! -d "$deluge_base"/deluge/completed ]]; then
            sudo mkdir -p $deluge_base/deluge/completed
            sudo chmod 777 $deluge_base/deluge/completed
        fi
        echo 'Setting up completed location to '${deluge_base}'/deluge/completed'
        su $select_user -c "deluge-console config -s move_completed_path ${deluge_base}/deluge/completed"
        su $select_user -c "deluge-console config -s move_completed True"
    else
        sudo mkdir -p $deluge_base/${deluge_completed%/}
        sudo chmod 777 $deluge_base/${deluge_completed%/}
        echo 'Setting up completed location to '${deluge_base}'/'${deluge_completed%/}
        su $select_user -c "deluge-console config -s move_completed_path ${deluge_base}/${deluge_completed%/}"
        su $select_user -c "deluge-console config -s move_completed True"
    fi

    echo 'Please enter the directory for torrent-backups files, or just leave blank if the path is '$deluge_base'/deluge/torrent-backups :'
    read -e -p '>'$deluge_base'/' deluge_torrent_backups
    if [ -z $deluge_torrent_backups ]; then
        if [[ ! -d "$deluge_base"/deluge/torrent-backups ]]; then
            sudo mkdir -p $deluge_base/deluge/torrent-backups
            sudo chmod 777 $deluge_base/deluge/torrent-backups
        fi
        echo 'Setting up torrent-backups location to '${deluge_base}'/deluge/torrent-backups'
        su $select_user -c "deluge-console config -s torrentfiles_location ${deluge_base}/deluge/torrent-backups"
        su $select_user -c "deluge-console config -s copy_torrent_file True"
    else
        sudo mkdir -p $deluge_base/${deluge_torrent_backups%/}
        sudo chmod 777 $deluge_base/${deluge_torrent_backups%/}
        echo 'Setting up torrent-backups location to '${deluge_base}'/'${deluge_torrent_backups%/}
        su $select_user -c "deluge-console config -s torrentfiles_location ${deluge_base}/${deluge_torrent_backups%/}"
        su $select_user -c "deluge-console config -s copy_torrent_file True"
    fi

    echo 'Please enter the directory for auto-add-torrent files, or just leave blank if the path is '$deluge_base'/deluge/watch :'
    read -e -p '>'$deluge_base'/' deluge_watch
    if [ -z $deluge_watch ]; then
        if [[ ! -d "$deluge_base"/deluge/watch ]]; then
            sudo mkdir -p $deluge_base/deluge/watch
            sudo chmod 777 $deluge_base/deluge/watch
        fi
        echo 'Setting up auto-add-torrent location to '${deluge_base}'/deluge/watch'
        su $select_user -c "deluge-console config -s autoadd_location ${deluge_base}/deluge/watch"
        su $select_user -c "deluge-console config -s autoadd_enable True"
    else
        sudo mkdir -p $deluge_base/${deluge_watch%/}
        sudo chmod 777 $deluge_base/${deluge_watch%/}
        echo 'Setting up auto-add-torrent location to '${deluge_base}'/'${deluge_watch%/}
        su $select_user -c "deluge-console config -s autoadd_location ${deluge_base}/${deluge_watch%/}"
        su $select_user -c "deluge-console config -s autoadd_enable True"
    fi
    su $select_user -c "deluge-console exit"
else
    su $USER -c "deluged"
    echo 'Waiting for deluge start....'
    sleep 3
    su $USER -c "deluge-console config -s allow_remote True"
    su $USER -c "deluge-console config allow_remote"
    su $USER -c "deluge-console config -s max_upload_slots_global 15"
    su $USER -c "deluge-console config -s max_active_limit 18"
    su $USER -c "deluge-console config -s max_active_downloading 15"
    su $USER -c "deluge-console config -s max_active_seeding 3"
    su $USER -c "deluge-console exit"
    #Set Deluge download path
    read -e -p 'Please enter deluge base path, or just leave blank if the path is /media/hd>' set_deluge_base
    if [ -z $set_deluge_base ]; then
        deluge_base=/media/hd
    else
        deluge_base=${set_deluge_base%/}
    fi

    echo 'Please enter the directory for downloading files, or just leave blank if the path is '$deluge_base'/deluge/downloading :'
    read -e -p '>'$deluge_base'/' deluge_downloading
    if [ -z $deluge_downloading ]; then
        if [[ ! -d "$deluge_base"/deluge/downloading ]]; then
            sudo mkdir -p $deluge_base/deluge/downloading
            sudo chmod 777 $deluge_base/deluge/downloading
        fi
        echo 'Setting up download location to '${deluge_base}'/deluge/downloading'
        su $USER -c "deluge-console config -s download_location ${deluge_base}/deluge/downloading"
    else
        sudo mkdir -p $deluge_base/${deluge_downloading%/}
        sudo chmod 777 $deluge_base/${deluge_downloading%/}
        echo 'Setting up download location to '${deluge_base}'/'${deluge_downloading%/}
        su $USER -c "deluge-console config -s download_location ${deluge_base}/${deluge_downloading%/}"
    fi

    echo 'Please enter the directory for completed files, or just leave blank if the path is '$deluge_base'/deluge/completed :'
    read -e -p '>'$deluge_base'/' deluge_completed
    if [ -z $deluge_completed ]; then
        if [[ ! -d "$deluge_base"/deluge/completed ]]; then
            sudo mkdir -p $deluge_base/deluge/completed
            sudo chmod 777 $deluge_base/deluge/completed
        fi
        echo 'Setting up completed location to '${deluge_base}'/deluge/completed'
        su $USER -c "deluge-console config -s move_completed_path ${deluge_base}/deluge/completed"
        su $USER -c "deluge-console config -s move_completed True"
    else
        sudo mkdir -p $deluge_base/${deluge_completed%/}
        sudo chmod 777 $deluge_base/${deluge_completed%/}
        echo 'Setting up completed location to '${deluge_base}'/'${deluge_completed%/}
        su $USER -c "deluge-console config -s move_completed_path ${deluge_base}/${deluge_completed%/}"
        su $USER -c "deluge-console config -s move_completed True"
    fi

    echo 'Please enter the directory for torrent-backups files, or just leave blank if the path is '$deluge_base'/deluge/torrent-backups :'
    read -e -p '>'$deluge_base'/' deluge_torrent_backups
    if [ -z $deluge_torrent_backups ]; then
        if [[ ! -d "$deluge_base"/deluge/torrent-backups ]]; then
            sudo mkdir -p $deluge_base/deluge/torrent-backups
            sudo chmod 777 $deluge_base/deluge/torrent-backups
        fi
        echo 'Setting up torrent-backups location to '${deluge_base}'/deluge/torrent-backups'
        su $USER -c "deluge-console config -s torrentfiles_location ${deluge_base}/deluge/torrent-backups"
        su $USER -c "deluge-console config -s copy_torrent_file True"
    else
        sudo mkdir -p $deluge_base/${deluge_torrent_backups%/}
        sudo chmod 777 $deluge_base/${deluge_torrent_backups%/}
        echo 'Setting up torrent-backups location to '${deluge_base}'/'${deluge_torrent_backups%/}
        su $USER -c "deluge-console config -s torrentfiles_location ${deluge_base}/${deluge_torrent_backups%/}"
        su $USER -c "deluge-console config -s copy_torrent_file True"
    fi

    echo 'Please enter the directory for auto-add-torrent files, or just leave blank if the path is '$deluge_base'/deluge/watch :'
    read -e -p '>'$deluge_base'/' deluge_watch
    if [ -z $deluge_watch ]; then
        if [[ ! -d "$deluge_base"/deluge/watch ]]; then
            sudo mkdir -p $deluge_base/deluge/watch
            sudo chmod 777 $deluge_base/deluge/watch
        fi
        echo 'Setting up auto-add-torrent location to '${deluge_base}'/deluge/watch'
        su $USER -c "deluge-console config -s autoadd_location ${deluge_base}/deluge/watch"
        su $USER -c "deluge-console config -s autoadd_enable True"
    else
        sudo mkdir -p $deluge_base/${deluge_watch%/}
        sudo chmod 777 $deluge_base/${deluge_watch%/}
        echo 'Setting up auto-add-torrent location to '${deluge_base}'/'${deluge_watch%/}
        su $USER -c "deluge-console config -s autoadd_location ${deluge_base}/${deluge_watch%/}"
        su $USER -c "deluge-console config -s autoadd_enable True"
    fi
fi

if [ $check_user == 'root' ]; then
    read -p 'The current user is Root now, please enter your rclone user or leave blank if you want to run script under Root>' select_user
    su $select_user -c "pkill deluged"
else
    su $USER -c "pkill deluged"
fi

#If you want to change deluge-web page, here is the index.html path :
#/usr/lib/python2.7/dist-packages/deluge/ui/web/

echo 'Setting auto start Deluge on boot...'
wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Deluge-Set/deluged.service
#wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Deluge-Set/deluge-web.service
sudo mv deluged.service /etc/systemd/system/
#sudo mv deluge-web.service /etc/systemd/system/
read -p 'Please enter the name of driver if you have set it in fstab, or just leave it blank>' deluge_mount
if [ -z $deluge_mount ]; then
    sed -i 's/After=network-online.target drive.mount/After=network-online.target/g' /etc/systemd/system/deluged.service
    sed -i '/Requires=drive.mount/d' /etc/systemd/system/deluged.service
    sed -i '/BindsTo=drive.mount/d' /etc/systemd/system/deluged.service
    sed -i 's/WantedBy=multi-user.target drive.mount/WantedBy=multi-user.target/g' /etc/systemd/system/deluged.service
else
    sed -i 's/After=network-online.target drive.mount/After=network-online.target '${deluge_mount}'.mount/g' /etc/systemd/system/deluged.service
    sed -i 's/Requires=drive.mount/Requires='${deluge_mount}'.mount/g' /etc/systemd/system/deluged.service
    sed -i 's/BindsTo=drive.mount/BindsTo='${deluge_mount}'.mount/g' /etc/systemd/system/deluged.service
    sed -i 's/WantedBy=multi-user.target drive.mount/WantedBy=multi-user.target '${deluge_mount}'.mount/g' /etc/systemd/system/deluged.service
fi
sudo chmod 660 /etc/systemd/system/deluged.service
#sudo chmod 660 /etc/systemd/system/deluge-web.service
sudo systemctl daemon-reload
sudo systemctl enable deluged.service
sudo systemctl start deluged
sudo systemctl status deluged
sleep 3
#sudo systemctl enable deluge-web.service
#sudo systemctl start deluge-web
#sudo systemctl status deluge-web

#At this point, your Deluge daemon is ready for remote access.
#Head to your normal PC (not the Raspberry Pi) and install the Deluge desktop program.
#You’ll find the installer for your operating system on the Deluge Downloads page.
#Once you’ve installed Deluge on your PC, run it for the first time; we need to make some quick changes.
#Once launched, navigate to Preferences > Interface. Within the interface submenu, you’ll see a checkbox for “Classic Mode”.
#By default it is checked. Uncheck it.
