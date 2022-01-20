#! /bin/sh

# Installing prerequisite software
sudo apt update
sudo apt install docker-compose jq zip -y


# Install The Spaghetti Detective
git clone https://github.com/TheSpaghettiDetective/TheSpaghettiDetective.git

# Attempt to restore a backup if present
bucket=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -c ".bucket" | tr --delete '"')
if [ ${bucket} ]; then
# Download existing backup to the /tmp folder
wget ${bucket}TheSpaghettiDetectiveBackup.zip -P /tmp
# Unzip to new directory
unzip /tmp/TheSpaghettiDetectiveBackup.zip -d .
fi

# Build and start TheSpaghettiDetective
cd TheSpaghettiDetective && sudo docker-compose up -d


# sudo zip -r /tmp/TheSpaghettiDetectiveBackup.zip ~/TheSpaghettiDetective/web
# bucket=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -c ".bucket" | tr --delete '"')
# /usr/bin/find /tmp/TheSpaghettiDetectiveBackup.zip -iname '*.unf' -exec curl -T {} $bucket \;
