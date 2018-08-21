#!/usr/bin/env bash

set -e

echo '1) Download files (link)'
echo '2) Download files (list)'
echo '3) Count files'
echo '4) Delete File Or Folder'
echo '5) Check Crontab status'
echo '6) Rclone upload files'
echo '7) Rclone move files'
echo '8) Rclone delete files'
echo '9) Get CPU Temperature'
echo '10) Get Pi Voltage'
echo '11) Update packages'
echo '12) Exit'
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
    read -e -p 'Please enter the file or directory which you want to upload>' upload_file
    read -p 'Please enter the remote path that you want to save>' upload_path
    su pi -c "rclone copy -v --stats 1s $upload_file $upload_path"
    ;;
  7)
    read -p 'Please enter the name of remote>' rclone_name
    read -p 'Please enter the file or directory which you want to move from> '$rclone_name':/' move_from
    read -p 'Please enter the path that you want to move to> '$rclone_name':/' move_to
    move_to_path=`basename $move_from`
    su pi -c "rclone move -v --stats 1s $rclone_name:/$move_from $rclone_name:/$move_to/$move_to_path"
    ;;
  8)
    read -p 'Please enter the file or directory which you want to delete>' delete_file_or_dir
    su pi -c "rclone delete -v --stats 1s $delete_file_or_dir"
    ;;
  9)
    vcgencmd measure_temp
    ;;
  10)
    for id in core sdram_c sdram_i sdram_p ; do \
      echo -e "$id:\t$(vcgencmd measure_volts $id)" ; \
    done
    ;;
  11)
    apt-get update
    apt-get dist-upgrade
    apt-get clean
    ;;
  12)
    echo 'Exited'
    ;;
  *)
    echo 'Tools not supported'
    ;;
esac

exit 0
