# Raspberry-Pi-Repo
The repository for Raspberry Pi

<details>
    <summary>
        <strong>Table of Contents</strong>
    </summary>
    <ul>
        <li><a href="#download-scripts">Download Scripts</a></li>
        <li><a href="#auto-report-ip">Auto Report IP</a></li>
        <li><a href="#auto-wifi-reconnect">Auto WiFi Reconnect</a></li>
        <li><a href="#deluge-set">Deluge-Set</a></li>
        <li><a href="#hath">HatH</a></li>
        <li><a href="#rclone-tools">Rclone Tools</a></li>
        <li><a href="#tools">Tools</a></li>
    </ul>
</details>

## Download Scripts
This script will download raspberry pi repo automatically
```
bash -c "$(curl https://carry0987.github.io/repo/rpi/)"
```
## Auto Report IP
This script will automatically send your current public ip to your email if your public ip have been changed.
Please enter the email info here:
[Report-IP.py](https://github.com/carry0987/Raspberry-Pi-Repo/blob/master/Auto-Report-IP/report-ip.py#L19-L22)
```bash
username = "Sender@gmail.com"
password = "Sender Password"
sender = "RPi"
receiver = ["Receiver@gmail.com"]
```

## Auto WiFi Reconnect
This script can auto reconnect WiFi when the WiFi down
1. Use `wget` to download the script
```
sudo wget -P /usr/local/bin https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Auto-WiFi-Reconnect/wifi-reconnect.sh
```
2. Give the script permission to run
```
sudo chmod +x /usr/local/bin/wifi-reconnect.sh
```
3. Edit crontab to let it check WiFi connection every minute
```
sudo echo '* * * * * root /usr/local/bin/wifi-reconnect.sh' >> /etc/crontab
```

## Deluge-Set
This script can setup Deluge & Deluge-Web
1. Use `wget` to download the script
```
sudo wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Deluge-Set/deluge-setup.sh
```
2. Use sh to run it
```
sudo sh deluge-setup.sh
```

## HatH
This script can setup HentaiAtHome in the background automatically
1. Use `wget` to download the script
```
sudo wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/HatH/hath.sh
```
2. Use sh to run it
```
sudo sh hath.sh
```

## Rclone Tools
### Rclone Common Tool
This script include some common function of Rclone
1. Use `wget` to download the script
```
sudo wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Rclone/rclone-tool.sh
```
2. Use `bash` to run it
```
sudo bash rclone-tool.sh
```

### Rclone Mount
This script can mount remote drive (recommend Google Drive) and make it auto mount at boot
1. Use `wget` to download the script
```
sudo wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Rclone/rclone-mount.sh
```
2. Use `bash` to run it
```
sudo bash rclone-mount.sh
```

If you want to remove rclone-mount
1. Use `wget` to download the script
```
sudo wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Rclone-Mount/delete-rclone-mount.sh
```
2. Use `bash` to run it
```
sudo bash delete-rclone-mount.sh
```

## Tools
This script has these features
```
1. Download files (link)
2. Download files (list)
3. Count Files
4. Delete File Or Folder
5. Check Crontab status
6. Get CPU Temperature
7. Get Pi Voltage
8. Set TCP-BBR
9. Update Packages
10. Install Packages
11. Check RPi kernal version
12. Resource Monitor (Sort By CPU)
13. Resource Monitor (Sort By Memory)
14. Estimate Usage Of Folder
15. Exit
```

1. Use `wget` to download the script
```
sudo wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Tools/tools.sh
```
2. Use `bash` to run it
```
sudo bash tools.sh
```
