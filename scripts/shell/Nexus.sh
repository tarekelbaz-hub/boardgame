#!/bin/bash

# Define variables
NEXUS_VERSION="3.59.0-01"
NEXUS_DOWNLOAD_URL="https://download.sonatype.com/nexus/3/nexus-$NEXUS_VERSION-unix.tar.gz"
NEXUS_INSTALL_DIR="/opt/nexus"
NEXUS_DATA_DIR="/opt/sonatype-work"
NEXUS_USER="nexus"

# Step 1: Update system packages
sudo apt-get update -y && sudo apt-get upgrade -y

# Step 2: Install Java (required by Nexus)
sudo apt-get install -y openjdk-11-jdk wget

# Step 3: Create a Nexus system user
sudo adduser --system --no-create-home --group $NEXUS_USER

# Step 4: Download and extract Nexus
wget $NEXUS_DOWNLOAD_URL -O /tmp/nexus-$NEXUS_VERSION-unix.tar.gz
sudo tar -xvzf /tmp/nexus-$NEXUS_VERSION-unix.tar.gz -C /opt

# Step 5: Rename the extracted directory
sudo mv /opt/nexus-$NEXUS_VERSION $NEXUS_INSTALL_DIR
sudo chown -R $NEXUS_USER:$NEXUS_USER $NEXUS_INSTALL_DIR

# Step 6: Create the data directory for Nexus
sudo mkdir -p $NEXUS_DATA_DIR
sudo chown -R $NEXUS_USER:$NEXUS_USER $NEXUS_DATA_DIR

# Step 7: Configure Nexus to run as the nexus user
echo "run_as_user=\"$NEXUS_USER\"" | sudo tee $NEXUS_INSTALL_DIR/bin/nexus.rc

# Step 8: Create a systemd service file for Nexus
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOL
[Unit]
Description=Sonatype Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=$NEXUS_USER
Group=$NEXUS_USER
ExecStart=$NEXUS_INSTALL_DIR/bin/nexus start
ExecStop=$NEXUS_INSTALL_DIR/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

# Step 9: Enable and start the Nexus service
sudo systemctl daemon-reload
sudo systemctl enable nexus.service
sudo systemctl start nexus.service

# Step 10: Check the status of the Nexus service
sudo systemctl status nexus.service

# Step 11: Display installation completion message
echo "Nexus Repository installation completed. You can access it at http://localhost:8081"
echo "Default admin password is located in: $NEXUS_DATA_DIR/nexus3/admin.password"