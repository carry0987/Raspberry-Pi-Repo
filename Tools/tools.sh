#!/usr/bin/env bash

set -e

echo '1) Download files (link)'
echo '2) Download files (list)'
echo '3) Count files'
echo '4) Delete File Or Folder'
echo '5) Get CPU Temperature'
echo '6) Get Pi Voltage'
echo '7) Update packages'
echo '8) Exit'
read -p 'Which tool do you want to use ? ' tool

#Detect tools
case $tool in
  1)
    read -p 'Please enter your link>' link
    read -p 'Please enter the path that you want to save this file, or just leave blank if you want to save to current path>' download_path
    if [ -z $download_path ]; then
        wget --content-disposition $link
    else
        wget -P $download_path --content-disposition $link
    fi
    ;;
  2)
    read -p 'Please enter your path of link list>' link_list
    read -p 'Please enter the path that you want to save this file, or just leave blank if you want to save to current path>' download_list_path
    if [ -z $download_list_path ]; then
        wget --content-disposition -i $link_list
    else
        wget -P $download_list_path --content-disposition -i $link_list
    fi
    ;;
  3)
    read -p 'Enter your path>' count_path
    find $count_path -type f |wc -l
    ;;
  4)
    read -p 'Enter file or folder that you want to remove>' file_or_folder
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
    vcgencmd measure_temp
    ;;
  6)
    for id in core sdram_c sdram_i sdram_p ; do \
      echo -e "$id:\t$(vcgencmd measure_volts $id)" ; \
    done
    ;;
  7)
    apt-get update
    apt-get dist-upgrade
    apt-get clean
    ;;
  8)
    echo 'Exited'
    ;;
  *)
    echo 'Tools not supported'
    ;;
esac

exit 0
