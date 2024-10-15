#!/bin/bash

# Variables
SONAR_VERSION="sonarqube-9.9.1.69595"
SONAR_DOWNLOAD_URL="https://binaries.sonarsource.com/Distribution/sonarqube/$SONAR_VERSION.zip"
SONARQUBE_USER="sonarqube"

# Update and upgrade system packages
sudo apt-get update -y && sudo apt-get upgrade -y

# Install necessary dependencies
sudo apt-get install -y wget unzip openjdk-11-jdk postgresql postgresql-contrib

# Create SonarQube user
sudo adduser --system --no-create-home --group --disabled-login $SONARQUBE_USER

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE USER sonar WITH PASSWORD 'sonar';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -u postgres psql -c "ALTER USER sonar WITH SUPERUSER;"

# Download and extract SonarQube
wget $SONAR_DOWNLOAD_URL -O /tmp/$SONAR_VERSION.zip
sudo unzip /tmp/$SONAR_VERSION.zip -d /opt
sudo mv /opt/$SONAR_VERSION /opt/sonarqube
sudo chown -R $SONARQUBE_USER:$SONARQUBE_USER /opt/sonarqube

# Configure SonarQube database properties
sudo tee /opt/sonarqube/conf/sonar.properties > /dev/null <<EOL
# Database configuration
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
# Web server configuration
sonar.web.host=0.0.0.0
sonar.web.port=9000
EOL

# Create a systemd service for SonarQube
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOL
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=simple
User=$SONARQUBE_USER
Group=$SONARQUBE_USER
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and enable SonarQube service
sudo systemctl daemon-reload
sudo systemctl enable sonarqube.service

# Start SonarQube service
sudo systemctl start sonarqube.service

# Check SonarQube service status
sudo systemctl status sonarqube.service

echo "SonarQube installation completed. You can access it at http://localhost:9000"
