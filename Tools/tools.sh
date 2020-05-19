#!/usr/bin/env bash

#=================================================
#   System Required: Raspbian
#   Description: Regular Command For Raspberry Pi
#   Author: carry0987
#   Web: https://github.com/carry0987
#=================================================

#Set variable
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
cur_dir=$(pwd)
#Set font prefix
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="[${green}Info${plain}]"
Error="[${red}Error${plain}]"

set -e

if [[ -n $1 && $1 =~ ^[0-9]+$ ]]; then
    tool=$1
fi

if [[ ! -n $tool ]]; then
    echo '1) Download files (link)'
    echo '2) Download files (list)'
    echo '3) Count Files'
    echo '4) Delete File Or Folder'
    echo '5) Check Crontab status'
    echo '6) Rclone copy files'
    echo '7) Rclone move files'
    echo '8) Rclone delete files'
    echo '9) Rclone upload type files'
    echo '10) Rclone sync remotes'
    echo '11) Rclone list remotes'
    echo '12) Rclone config file location'
    echo '13) Get CPU Temperature'
    echo '14) Get Pi Voltage'
    echo '15) Set TCP-BBR'
    echo '16) Update Packages'
    echo '17) Install Packages'
    echo '18) Check Kernal version'
    echo '19) Resource Monitor (Sort By CPU)'
    echo '20) Resource Monitor (Sort By Memory)'
    echo '21) Estimate Usage Of Folder'
    echo '22) Exit'
    read -p 'Which tool do you want to use ? ' tool
fi

DEFAULT_PATH=''

#Detect tools
case $tool in
    1)
        read -p 'Please enter your link>' link
        if [[ -z $DEFAULT_PATH ]]; then
            read -e -p 'Please enter the path that you want to save this file, or just leave blank if you want to save to current path>' download_path
        else
            download_path=$DEFAULT_PATH
        fi
        if [ -z $download_path ]; then
            wget --content-disposition $link
        else
            wget -P $download_path --content-disposition $link
        fi
        ;;
    2)
        read -e -p 'Please enter your path of link list>' link_list
        if [[ -z $DEFAULT_PATH ]]; then
            read -e -p 'Please enter the path that you want to save this file, or just leave blank if you want to save to current path>' download_list_path
        else
            download_list_path=$DEFAULT_PATH
        fi
        if [ -z $download_list_path ]; then
            wget --content-disposition -i $link_list
        else
            wget -P $download_list_path --content-disposition -i $link_list
        fi
        ;;
    3)
        read -e -p 'Enter your path>' count_path
        find $count_path -type f |wc -l
        ;;
    4)
        read -e -p 'Enter file or folder that you want to remove>' file_or_folder
        read -p 'Do you really want to remove '$file_or_folder' ? [Y/N]' var
        if [[ $var =~ ^([Yy])+$ ]]; then
            rm -vRf $file_or_folder
        elif [[ $var =~ ^([Nn])+$ ]]; then
            bash tools.sh
        else
            echo 'You can only choose yes or no'
        fi
        ;;
    5)
        /etc/init.d/cron status
        ;;
    6)
        read -e -p 'Please enter the file or directory which you want to copy>' upload_file
        read -e -p 'Please enter the target that you want to save>' upload_path
        prefix_file=${upload_file//\'/\'\"\'\"\'}
        prefix_path=${upload_path//\'/\'\"\'\"\'}
        check_user=$USER
        if [ $check_user == 'root' ]; then
            read -p 'The current user is Root now, please enter your rclone user or leave blank if you want to run rclone under Root>' select_user
            su $select_user -c  "rclone copy -v --stats 1s '$prefix_file' '$prefix_path'"
        else
            su $USER -c "rclone copy -v --stats 1s '$prefix_file' '$prefix_path'"
        fi
        ;;
    7)
        read -p 'Please enter the name of remote>' rclone_name
        read -p 'Please enter the file or directory which you want to move from> '$rclone_name':/' move_from
        read -p 'Please enter the path that you want to move to> '$rclone_name':/' move_to
        prefix_from=${move_from//\'/\'\"\'\"\'}
        prefix_to=${move_to//\'/\'\"\'\"\'}
        move_to_path=`basename $prefix_from`
        check_user=$USER
        if [ $check_user == 'root' ]; then
            read -p 'The current user is Root now, please enter your rclone user or leave blank if you want to run rclone under Root>' select_user
            su $select_user -c "rclone move -v --stats 1s '$rclone_name:/$prefix_from' '$rclone_name:/$prefix_to/$move_to_path'"
        else
            su $USER -c "rclone move -v --stats 1s '$rclone_name:/$prefix_from' '$rclone_name:/$prefix_to/$move_to_path'"
        fi
        ;;
    8)
        read -p 'Please enter the file or directory which you want to delete>' delete_file_or_dir
        prefix_delete=${delete_file_or_dir//\'/\'\"\'\"\'}
        check_user=$USER
        if [ $check_user == 'root' ]; then
            read -p 'The current user is Root now, please enter your rclone user or leave blank if you want to run rclone under Root>' select_user
            su $select_user -c "rclone delete -v --stats 1s '$prefix_delete'"
        else
            su $USER -c "rclone delete -v --stats 1s '$prefix_delete'"
        fi
        ;;
    9)
        script_path="$(cd "$(dirname "$0")"; pwd -P)"
        read -e -p 'Please enter the path that you want to upload, or leave blank if you want to save in '$script_path'>' type_path
        if [ -z $type_path ]; then
            file_path=${script_path%/}
        else
            file_path=${type_path%/}
            #file_space_path=${file_path// /\\ }
        fi
        read -p 'Please enter the type of files that you want to upload>'$file_path'/' file_type
        mkdir -p $file_path'/''EHT_'$file_type
        mv $file_path'/'*.$file_type $file_path'/''EHT_'$file_type
        read -p 'Do you want to upload all '$file_path'/'$file_type' files to remote drive? [Y/N] ' remote
        if [[ $remote =~ ^([Yy])+$ ]]; then
            read -p 'Please enter the remote path that you want to save>' upload_path
            prefix_path=${upload_path//\'/\'\"\'\"\'}
            check_user=$USER
            if [ $check_user == 'root' ]; then
                read -p 'The current user is Root now, please enter your rclone user or leave blank if you want to run rclone under Root>' select_user
                su $select_user -c  "rclone copy -v --stats 1s $file_path/EHT_$file_type '$prefix_path'"
            else
                su $USER -c "rclone copy -v --stats 1s $file_path/EHT_$file_type '$prefix_path'"
            fi
            echo 'Upload Finished !'
            read -p 'Do you want to remove '$file_path'/'$file_type' files from local? [Y/N] ' remove_dir
            if [[ $remove_dir =~ ^([Yy])+$ ]]; then
                rm -vRf $file_path'/''EHT_'$file_type
            elif [[ $remove_dir =~ ^([Nn])+$ ]]; then
                exit 0
            else
                echo 'You can only choose yes or no'
            fi
        elif [[ $remote =~ ^([Nn])+$ ]]; then
            exit 0
        else
            echo 'You can only choose yes or no'
        fi
        ;;
    10)
        read -e -p 'Please enter the remote which you want to sync>' sync_from
        read -e -p 'Please enter the target remote that you want to sync with '$sync_from'>' sync_to
        prefix_sync_from=${sync_from//\'/\'\"\'\"\'}
        prefix_sync_to=${sync_to//\'/\'\"\'\"\'}
        check_user=$USER
        if [ $check_user == 'root' ]; then
            read -p 'The current user is Root now, please enter your rclone user or leave blank if you want to run rclone under Root>' select_user
            su $select_user -c  "rclone sync -v --stats 1s '$prefix_sync_from' '$prefix_sync_to'"
        else
            su $USER -c "rclone sync -v --stats 1s '$prefix_sync_from' '$prefix_sync_to'"
        fi
        ;;
    11)
        read -e -p 'Please enter the remote name which you want to list>' remote_list
        read -e -p 'Please enter the level that you want rclone descend directories deep>' list_level
        prefix_remote_list=${remote_list//\'/\'\"\'\"\'}
        check_user=$USER
        if [ $check_user == 'root' ]; then
            read -p 'The current user is Root now, please enter your rclone user or leave blank if you want to run rclone under Root>' select_user
            su $select_user -c  "rclone tree -v --human --level $list_level $prefix_remote_list"
        else
            su $USER -c "rclone tree -v --human --level $list_level $prefix_remote_list"
        fi
        ;;
    12)
        check_user=$USER
        if [ $check_user == 'root' ]; then
            read -p 'The current user is Root now, please enter your rclone user or leave blank if you want to run rclone under Root>' select_user
            su $select_user -c  "rclone -h | grep 'Config file'"
        else
            su $USER -c "rclone -h | grep 'Config file'"
        fi
        ;;
    13)
        vcgencmd measure_temp
        ;;
    14)
        for id in core sdram_c sdram_i sdram_p ; do \
            echo -e "$id:\t$(vcgencmd measure_volts $id)" ; \
        done
        ;;
    15)
        check_bbr_status() {
            local param=$(sudo sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
            if [[ x"${param}" == x"bbr" ]]; then
                return 0
            else
                return 1
            fi
        }
        check_bbr_status
        if [ $? -eq 0 ]; then
            echo
            echo -e "[${green}Info${plain}] TCP BBR has already been installed"
            exit 0
        else
            sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
            sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
            echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
            echo 'Successful setting net core'
            echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
            echo 'Successful setting tcp congestion control'
            echo '######################'
            echo 'TCP-BBR Status'
            echo '######################'
            sysctl -p
            sysctl net.ipv4.tcp_available_congestion_control
            echo '######################'
        fi
        ;;
    16)
        check_user=$USER
        if [ $check_user == 'root' ]; then
            apt-get update
            apt-get dist-upgrade
            apt-get clean
        else
            sudo apt-get update
            sudo apt-get dist-upgrade
            sudo apt-get clean
        fi
        ;;
    17)
        read -p 'Please enter the packages name that you want to install>' pkg_name
        if [ -z $pkg_name ]; then
            echo 'The package name is empty !'
            exit 0
        fi
        check_user=$USER
        if [ $check_user == 'root' ]; then
            apt-get update
            apt-get dist-upgrade
            apt-get clean
            apt-get install $pkg_name
        else
            sudo apt-get update
            sudo apt-get dist-upgrade
            sudo apt-get clean
            sudo apt-get install $pkg_name
        fi
        ;;
    18)
        uname -a
        #rpi-update
        #secs=$((5))
        #while [ $secs -gt 0 ]
        #do
        #    echo -ne 'Wait '"$secs\033[0K"' seconds to reboot'"\r"
        #    sleep 1
        #    : $((secs--))
        #done
        #reboot
        ;;
    19)
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head
        ;;
    20)
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
        ;;
    21)
        read -e -p 'Please enter the folder that you want to estimate usage of>' estimate_folder
        if [[ -z $estimate_folder ]]; then
            echo 'You must type the folder path !'
        else
            count_estimate_folder=${estimate_folder%/}
            du -sch $count_estimate_folder
        fi
        ;;
    22 | 'q')
        echo 'Exited'
        ;;
    *)
        echo 'Tools not supported'
        ;;
esac

exit 0
