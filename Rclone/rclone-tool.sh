#!/usr/bin/env bash

#=================================================
#   System Required: Raspbian
#   Description: Common Rclone Script
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
    echo '1) Rclone copy files'
    echo '2) Rclone move files'
    echo '3) Rclone delete files'
    echo '4) Rclone upload type files'
    echo '5) Rclone sync remotes'
    echo '6) Rclone list remotes'
    echo '7) Rclone config file location'
    echo '8) Exit'
    read -p 'Which tool do you want to use ? ' tool
fi

DEFAULT_PATH=''

#Detect tools
case $tool in
    1)
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
    2)
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
    3)
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
    4)
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
    5)
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
    6)
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
    7)
        check_user=$USER
        if [ $check_user == 'root' ]; then
            read -p 'The current user is Root now, please enter your rclone user or leave blank if you want to run rclone under Root>' select_user
            su $select_user -c  "rclone -h | grep 'Config file'"
        else
            su $USER -c "rclone -h | grep 'Config file'"
        fi
        ;;
    *)
        echo 'Tools not supported'
        ;;
esac

exit 0
