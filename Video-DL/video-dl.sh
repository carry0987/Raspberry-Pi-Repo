#!/usr/bin/env bash

set -e
check_user=$USER
script_path="$(cd "$(dirname "$0")"; pwd -P)"

#Install youtube-dl
if ! [ -x "$(command -v youtube-dl)" ]; then
    echo 'youtube-dl is not installed.' >&2
    sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
    sudo chmod a+rx /usr/local/bin/youtube-dl
fi

echo '1) Download videos (link)'
echo '2) Download videos (list)'
echo '3) Set youtube-dl config'
echo '4) Exit'
read -p 'Which tool do you want to use ? ' tool

#Detect tools
case $tool in
    1)
        read -p 'Please enter your link>' video_link
        #Set saving path
        if ! [ -e $script_path'/.config/youtube-dl/config' ]; then
            read -e -p 'Please enter the path which you want to save videos, or leave blank if you want to save to '$script_path'>' set_path
            if [ -z $set_path ]; then
                save_path=${script_path%/}
            else
                save_path=${set_path%/}
            fi
        fi
        #Check user
        if [ $check_user == 'root' ]; then
            read -p 'The current user is Root now, please enter your youtube-dl user or leave blank if you want to run youtube-dl under Root>' select_user
            if [ -e $script_path'/.config/youtube-dl/config' ]; then
                su $select_user -c "youtube-dl $video_link"
            else
                su $select_user -c "youtube-dl -o $save_path/'%(title)s.%(ext)s' $video_link"
            fi
        else
            if [ -e $script_path'/.config/youtube-dl/config' ]; then
                su $USER -c "youtube-dl $video_link"
            else
                su $USER -c "youtube-dl -o $save_path/'%(title)s.%(ext)s' $video_link"
            fi
        fi
        ;;
    2)
        #Get file path
        read -e -p 'Please enter the path of list, or leave blank if the path is '$script_path'>' dl_list
        if [ -z $dl_list ]; then
            file_path=${script_path%/}
        else
            file_path=${dl_list%/}
        fi
        #Get file content
        read -e -p 'Please enter the name of list file, or leave blank if the file name is list.txt>' list_file
        if [ -z $list_file ]; then
            filename=$file_path'/list.txt'
        else
            filename=$file_path'/'$list_file
        fi
        #Set saving path
        if ! [ -e $script_path'/.config/youtube-dl/config' ]; then
            read -e -p 'Please enter the path which you want to save videos, or leave blank if you want to save to '$script_path'>' set_path
            if [ -z $set_path ]; then
                save_path=${script_path%/}
            else
                save_path=${set_path%/}
            fi
        fi
        #Check user
        if [ $check_user == 'root' ]; then
            read -p 'The current user is Root now, please enter your youtube-dl user or leave blank if you want to run youtube-dl under Root>' select_user
            if [ -e $script_path'/.config/youtube-dl/config' ]; then
                while read -r line
                do
                    su $select_user -c "youtube-dl $line"
                done < $filename
            else
                while read -r line
                do
                    su $select_user -c "youtube-dl -o $save_path/'%(title)s.%(ext)s' $line"
                done < $filename
            fi
        else
            while read -r line
            do
                su $USER -c "youtube-dl -o $save_path/'%(title)s.%(ext)s' $line"
            done
        fi
        ;;
    3)
        sudo mkdir -p /home/pi/.config/youtube-dl
        read -e -p 'Please enter the path that you want to save video files>' default_save_path
        if [ -e $default_save_path ]; then
            config_save_path=${default_save_path%/}
            touch /home/pi/.config/youtube-dl/config
            echo '# Save all videos under Movies directory in your home directory' > /home/pi/.config/youtube-dl/config
            echo '-o '${config_save_path}'/%(title)s.%(ext)s' >> /home/pi/.config/youtube-dl/config
            sudo chmod -R 777 /home/pi/.config/youtube-dl
            cat /home/pi/.config/youtube-dl/config
            echo 'Set Up Success !'
        else
            echo 'Cannot get your type, do you want to save in /media/hd/file ? [Y/N]>' set_config
            if [[ $set_config =~ ^([Yy])+$ ]]; then
                wget -P /home/pi/.config/youtube-dl https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Video-DL/config
                sudo chmod -R 777 /home/pi/.config/youtube-dl
                cat /home/pi/.config/youtube-dl/config
                echo 'Set Up Success !'
            elif [[ $set_config =~ ^([Nn])+$ ]]; then
                echo 'Exited'
                exit 0
            else
                echo 'You can only choose yes or no'
                exit 0
            fi
        fi
        ;;
    4)
        echo 'Exited'
        ;;
    *)
        echo 'Tools not supported'
        ;;
esac

exit 0
