#!/usr/bin/env bash

set -e

#Install youtube-upload
if ! [ -x "$(command -v youtube-upload)" ]; then
    echo 'youtube-upload is not installed.' >&2
    sudo apt-get install python-setuptools python3-setuptools
    sudo easy_install pip
    sudo easy_install3 pip
    sudo pip install --upgrade google-api-python-client oauth2client progressbar2
    wget https://github.com/tokland/youtube-upload/archive/master.zip
    unzip master.zip
    cd youtube-upload-master
    sudo python setup.py install
fi

#Install pip, google-api-python-client, oauth2client, progressbar2
if ! [ -x "$(command -v pip)" ]; then
    echo 'pip is not installed.' >&2
    sudo apt-get install python-setuptools python3-setuptools
    sudo easy_install pip
    sudo easy_install3 pip
    sudo pip install --upgrade google-api-python-client oauth2client progressbar2
fi

#Get file path
script_path="$(cd "$(dirname "$0")"; pwd -P)"
read -e -p 'Please enter the path of videos, or leave blank if the path is '$script_path'>' upload_list
if [ -z $upload_list ]; then
    file_path=${script_path%/}
else
    file_path=${upload_list%/}
fi

#Get file type
read -p 'Please enter the file extension of videos that you want to upload>' file_type

#Check user
check_user=$USER
if [ $check_user == 'root' ]; then
    read -p 'The current user is Root now, please enter your youtube-upload user or leave blank if you want to run youtube-upload under Root>' select_user
    for video_file in $file_path/*.$file_type
    do
        filename=$(basename -- "$video_file")
        video_name="${filename%.*}"
        su $select_user -c "youtube-upload --client-secrets='/home/pi/.config/youtube-upload/youtube-upload-client-secrets.json' --credentials-file='/home/pi/.config/youtube-upload/youtube-upload-credentials.json' --privacy=private --title='$video_name' '$video_file'"
    done
    echo 'Upload Finished !'
    read -p 'Do you want to remove all videos from local? [Y/N] ' remove_dir
    if [[ $remove_dir =~ ^([Yy])+$ ]]; then
      rm -vRf $file_path/*.$file_type
    elif [[ $remove_dir =~ ^([Nn])+$ ]]; then
      exit 0
    else
      echo 'You can only choose yes or no'
    fi
else
    for video_file in $file_path/*.$file_type
    do
        filename=$(basename -- "$video_file")
        video_name="${filename%.*}"
        su $USER -c "youtube-upload --client-secrets='/home/pi/.config/youtube-upload/youtube-upload-client-secrets.json' --credentials-file='/home/pi/.config/youtube-upload/youtube-upload-credentials.json' --privacy=private --title='$video_name' '$video_file'"
    done
    echo 'Upload Finished !'
    read -p 'Do you want to remove all videos from local? [Y/N] ' remove_dir
    if [[ $remove_dir =~ ^([Yy])+$ ]]; then
      rm -vRf $file_path/*.$file_type
    elif [[ $remove_dir =~ ^([Nn])+$ ]]; then
      exit 0
    else
      echo 'You can only choose yes or no'
    fi
fi

exit 0
