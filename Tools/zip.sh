#!/bin/bash

set -e

script_path="$(cd "$(dirname "$0")"; pwd -P)"

read -e -p 'Please enter parent directory that have sub-directory to compress>' compress_directory
read -e -p 'Please enter the path that you want to save, or leave blank if you want to save in '$script_path'>' save_path

#Remove slash at the end of save path
prefix_save=${save_path%/}

#Check if compress directory set
if [ -z $compress_directory ]; then
    cd ./
else
    cd $compress_directory
fi

#Check if compress directory set
if [ -z $prefix_save ]; then
    target_path=$script_path
else
    target_path=$prefix_save
fi

#Use for-loop to compress all sub-directory
read -p 'It will compress all sub-directories into individual zip files, continue? [Y/N] ' detect

case $detect in
    [Yy])
        for i in */;
        do
            zip -r $target_path/"${i%/}.zip" "$i";
        done
        ;;
    [Nn])
        exit 0
        ;;
esac

exit 0
