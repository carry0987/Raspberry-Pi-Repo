#!/usr/bin/env bash

set -e

echo '1) Download files (link)'
echo '2) Download files (list)'
echo '3) Count files'
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
echo '17) Check RPi kernal version'
echo '18) Resource Monitor (Sort By CPU)'
echo '19) Resource Monitor (Sort By Memory)'
echo '20) Exit'
read -p 'Which tool do you want to use ? ' tool

#Detect tools
case $tool in
    1)
        read -p 'Please enter your link>' link
        read -e -p 'Please enter the path that you want to save this file, or just leave blank if you want to save to current path>' download_path
        if [ -z $download_path ]; then
            wget --content-disposition $link
        else
            wget -P $download_path --content-disposition $link
        fi
        ;;
    2)
        read -e -p 'Please enter your path of link list>' link_list
        read -e -p 'Please enter the path that you want to save this file, or just leave blank if you want to save to current path>' download_list_path
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
            su $select_user -c  "rclone tree -v --human --level $list_level $prefix_remote_list:"
        else
            su $USER -c "rclone tree -v --human --level $list_level $prefix_remote_list:"
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
        #Check if TCP-BBR has already setup
        if [ `grep -c "net.core.default_qdisc=fq" /etc/sysctl.conf` -eq '1' ]; then
            bbr_qdisc=1
        else
            bash -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'
            echo 'Successful setting net core'
            bbr_qdisc=2
        fi

        if [ `grep -c "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf` -eq '1' ]; then
            bbr_tcc=1
        else
            bash -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'
            echo 'Successful setting tcp congestion control'
            bbr_tcc=2
        fi

        if [[ $bbr_qdisc -eq '1' && $bbr_tcc -eq '1' ]]; then
            echo 'TCP-BBR has already setup !'
        elif [[ $bbr_qdisc -eq '2' || $bbr_tcc -eq '2' ]]; then
            echo '######################'
            echo 'TCP-BBR'
            echo '######################'
            sysctl -p
            sysctl net.ipv4.tcp_available_congestion_control
        else
            echo 'Failed to set up TCP-BBR'
        fi
        ;;
    16)
        apt-get update
        apt-get dist-upgrade
        apt-get clean
        ;;
    17)
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
    18)
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head
        ;;
    19)
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
        ;;
    20)
        echo 'Exited'
        ;;
    *)
        echo 'Tools not supported'
        ;;
esac

exit 0
