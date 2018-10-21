[Unit]
Description=IP Reporter
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/report-ip.py

[Install]
WantedBy=multi-user.target