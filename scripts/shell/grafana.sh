#!/bin/bash

# Update and upgrade system packages
sudo apt-get update -y && sudo apt-get upgrade -y

# Install necessary dependencies
sudo apt-get install -y software-properties-common apt-transport-https wget

# Add Grafana GPG key
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Add Grafana repository
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Update package list again
sudo apt-get update -y

# Install Grafana
sudo apt-get install -y grafana

# Enable and start the Grafana service
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Check Grafana service status
sudo systemctl status grafana-server

echo "Grafana installation completed. You can access Grafana at http://localhost:3000"