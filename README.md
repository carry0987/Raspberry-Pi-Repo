# Raspberry-Pi-Repo
The repository for Raspberry Pi

## Download Scripts
This script will download raspberry pi repo automatically
```
bash -c "$(curl https://carry0987.github.io/repo/)"
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
1. Use wget to download the script
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

## HatH
This script can setup HentaiAtHome in the background automatically
1. Use wget to download the script
```
sudo wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/HatH/hath.sh
```
2. Use sh to run it
```
sudo sh hath.sh
```

## Rclone Mount
This script can mount remote drive (recommend Google Drive) and make it auto mount at boot
1. Use wget to download the script
```
sudo wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Rclone-Mount/rclone-mount.sh
```
2. Use bash to run it
```
sudo bash rclone-mount.sh
```

If you want to remove rclone-mount
1. Use wget to download the script
```
sudo wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Rclone-Mount/delete-rclone-mount.sh
```
2. Use bash to run it
```
sudo bash delete-rclone-mount.sh
```

## Tools
This script has these features
-  Download files (link)
-  Download files (list)
-  Count files
-  Delete File Or Folder
-  Check Crontab status
-  Rclone upload files
-  Rclone move files
-  Rclone delete files
-  Get CPU Temperature
-  Get Pi Voltage
-  Update packages

1. Use wget to download the script
```
sudo wget https://raw.github.com/carry0987/Raspberry-Pi-Repo/master/Tools/tools.sh
```
2. Use bash to run it
```
sudo bash tools.sh
```
