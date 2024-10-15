#!/bin/bash

#Initialization of Machine:

#Set root password
#!/bin/bash

# Check if the script is being run as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Prompt user for a new root password
echo "Please enter a new password for the root account."
sudo passwd root

# Check the status of the passwd command
if [ $? -eq 0 ]; then
  echo "Root password set successfully."
else
  echo "Failed to set the root password."
fi

# Step 1: Add a new user named 'devops-user'
echo "Creating user 'devops-user'..."
sudo adduser --gecos "" devops-user

# Step 2: Add 'devops-user' to the 'adm' group
echo "Adding 'devops-user' to the 'adm' group..."
sudo usermod -aG adm devops-user

# Step 3: Add 'devops-user' to the 'sudo' group
echo "Adding 'devops-user' to the 'sudo' group..."
sudo usermod -aG sudo devops-user

# Step 4: Grant 'devops-user' passwordless sudo privileges
echo "Granting 'devops-user' passwordless sudo privileges..."
echo "devops-user ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/devops-user

# Step 5: Install necessary packages
echo "Installing vim, openssh-client, openssh-server and git"
sudo apt update -y
sudo apt install vim openssh-client openssh-server git -y

# Step 6: Check if SSH service is running and start it if necessary
echo "Checking SSH service status..."
sudo systemctl status ssh || sudo systemctl start ssh

#Edit the /etc/hosts with names and IP Addresses
# Define the list of host entries to add
HOSTS_LIST="
192.168.10.150  master.depi.local   master
192.168.10.151  worker1.depi.local  worker1
192.168.10.152  worker2.depi.local  worker2
192.168.10.153  nexus.depi.local    nexus
192.168.10.154  prometheus.depi.local prometheus
"

# Backup the existing /etc/hosts file
sudo cp /etc/hosts /etc/hosts.backup

# Add each host entry to /etc/hosts if it doesn't already exist
echo "Adding host entries to /etc/hosts..."
while read -r line; do
  if ! grep -q "$line" /etc/hosts; then
    echo "$line" | sudo tee -a /etc/hosts > /dev/null
    echo "Added: $line"
  else
    echo "Entry already exists: $line"
  fi
done <<< "$HOSTS_LIST"

echo "Host entries have been updated successfully in /etc/hosts."

# Final message
echo "Setup completed successfully. 'devops-user' has been created and configured with passwordless sudo privileges."

