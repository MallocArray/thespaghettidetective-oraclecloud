#! /bin/sh

# Installing prerequisite software
sudo apt update
sudo apt install docker-compose jq zip -y



# Clone The Spaghetti Detective repo
cd /
git clone https://github.com/TheSpaghettiDetective/TheSpaghettiDetective.git



# Attempt to restore a backup if present
bucket=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -c ".bucket" | tr --delete '"')
if [ ${bucket} ]; then
# Download existing database backup
sudo wget ${bucket}db.sqlite3 -O /TheSpaghettiDetective/web/db.sqlite3


# Setup daily backups

# Create backup script file
	echo '#!/bin/bash' | sudo tee /TheSpaghettiDetective/tsd-backup.sh
	echo 'bucket=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -c ".bucket" | tr --delete '\''"'\'' )' | sudo tee -a /TheSpaghettiDetective/tsd-backup.sh
	# echo sudo zip -r /tmp/TheSpaghettiDetectiveBackup.zip /TheSpaghettiDetective/web | sudo tee -a /TheSpaghettiDetective/tsd-backup.sh
	# echo sudo tar -czvf /tmp/TheSpaghettiDetectiveBackup.tar /TheSpaghettiDetective/web/db.sqlite3 | sudo tee -a /TheSpaghettiDetective/tsd-backup.sh
	echo curl -T /TheSpaghettiDetective/web/db.sqlite3 \$bucket | sudo tee -a /TheSpaghettiDetective/tsd-backup.sh
	sudo chmod u+x /TheSpaghettiDetective/tsd-backup.sh



	cat > /etc/systemd/system/tsd-backup.service <<_EOF
[Unit]
Description=Daily backup of TSD/web to OCI Storage service
After=network-online.target
Wants=network-online.target
[Service]
Type=oneshot
ExecStart=/TheSpaghettiDetective/tsd-backup.sh
_EOF

	cat > /etc/systemd/system/tsd-backup.timer <<_EOF
[Unit]
Description=Daily backup of TSD/web to OCI Storage service
[Timer]
OnCalendar=1:00
RandomizedDelaySec=30m
[Install]
WantedBy=timers.target
_EOF
	systemctl daemon-reload
	systemctl start tsd-backup.timer
	echo "Backups to OCI Storage set up"
fi



# Build and start TheSpaghettiDetective
cd /TheSpaghettiDetective && sudo docker-compose up -d


# Install all remaining updates and keep current iptables settings
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt upgrade -y
# Reboot to ensure all updates are applied
sudo reboot
