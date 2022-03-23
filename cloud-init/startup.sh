#! /bin/sh

# Installing prerequisite software
sudo apt update
sudo apt install docker-compose jq zip -y



# Clone The Spaghetti Detective repo
cd /
git clone -b release https://github.com/TheSpaghettiDetective/TheSpaghettiDetective.git



# Attempt to restore a backup if present
bucket=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -c ".bucket" | tr --delete '"')
if [ ${bucket} ]; then
	# Download existing database backup
	sudo wget ${bucket}db.sqlite3 -O /TheSpaghettiDetective/web/db.sqlite3
	sudo wget ${bucket}docker-compose.yml -O /TheSpaghettiDetective/docker-compose.yml


	# Setup daily backups

	# Create backup script file
	echo '#!/bin/bash' | sudo tee /TheSpaghettiDetective/tsd-backup.sh
	echo 'bucket=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -c ".bucket" | tr --delete '\''"'\'' )' | sudo tee -a /TheSpaghettiDetective/tsd-backup.sh
	# echo sudo zip -r /tmp/TheSpaghettiDetectiveBackup.zip /TheSpaghettiDetective/web | sudo tee -a /TheSpaghettiDetective/tsd-backup.sh
	# echo sudo tar -czvf /tmp/TheSpaghettiDetectiveBackup.tar /TheSpaghettiDetective/web/db.sqlite3 | sudo tee -a /TheSpaghettiDetective/tsd-backup.sh
	echo curl -T /TheSpaghettiDetective/web/db.sqlite3 \$bucket | sudo tee -a /TheSpaghettiDetective/tsd-backup.sh
	echo curl -T /TheSpaghettiDetective/docker-compose.yml \$bucket | sudo tee -a /TheSpaghettiDetective/tsd-backup.sh
	sudo chmod u+x /TheSpaghettiDetective/tsd-backup.sh

	# Schedule weekly backups of database using cron on Sundays at 1:00 am
	# https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
	crontab -l | { cat; echo "* 1 * * 0 /TheSpaghettiDetective/tsd-backup.sh"; } | crontab -
fi


# Build and start TheSpaghettiDetective
cd /TheSpaghettiDetective && sudo docker-compose up -d

# Install all remaining updates and keep current iptables settings
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt upgrade -y
# Reboot to ensure all updates are applied
sudo reboot
