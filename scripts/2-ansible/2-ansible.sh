#!/bin/bash

# Check if the script is being run as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Step 1: Update the package list
echo "Updating package list..."
sudo apt-get update -y

# Step 2: Install necessary dependencies
echo "Installing dependencies..."
sudo apt-get install -y software-properties-common

# Step 3: Add Ansible PPA (Personal Package Archive) repository
echo "Adding Ansible PPA repository..."
sudo add-apt-repository --yes --update ppa:ansible/ansible

# Step 4: Update package list again after adding Ansible PPA
echo "Updating package list after adding Ansible PPA..."
sudo apt-get update -y

# Step 5: Install Ansible
echo "Installing Ansible..."
sudo apt-get install -y ansible

# Step 6: Verify Ansible installation
echo "Verifying Ansible installation..."
ansible --version

# Final message
echo "Ansible has been successfully installed on Ubuntu 22.04."
