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
    echo '6) Get CPU Temperature'
    echo '7) Get Pi Voltage'
    echo '8) Set TCP-BBR'
    echo '9) Update Packages'
    echo '10) Install Packages'
    echo '11) Check Kernal version'
    echo '12) Resource Monitor (Sort By CPU)'
    echo '13) Resource Monitor (Sort By Memory)'
    echo '14) Estimate Usage Of Folder'
    echo '15) Exit'
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
        find $count_path -type f | wc -l
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
        vcgencmd measure_temp
        ;;
    7)
        for id in core sdram_c sdram_i sdram_p ; do \
            echo -e "$id:\t$(vcgencmd measure_volts $id)" ; \
        done
        ;;
    8)
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
    9)
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
    10)
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
    11)
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
    12)
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head
        ;;
    13)
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
        ;;
    14)
        read -e -p 'Please enter the folder that you want to estimate usage of>' estimate_folder
        if [[ -z $estimate_folder ]]; then
            echo 'You must type the folder path !'
        else
            count_estimate_folder=${estimate_folder%/}
            du -sch $count_estimate_folder
        fi
        ;;
    15 | 'q')
        echo 'Exited'
        ;;
    *)
        echo 'Tools not supported'
        ;;
esac

exit 0
