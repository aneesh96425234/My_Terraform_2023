#!/bin/bash

# Update package lists
sudo apt update -y

# Install Apache if not already installed
sudo apt install -y apache2

# Create an HTML file with server details
echo "<h1>Server Details</h1>
<p><strong>Hostname:</strong> $(hostname)</p>
<p><strong>IP Address:</strong> $(hostname -I | awk '{print $1}')</p>" | sudo tee /var/www/html/index.html > /dev/null

# Restart Apache to apply changes
sudo systemctl restart apache2

# Create user 'aneesh' with password 'P@ssw0rd'
sudo useradd -m -s /bin/bash aneesh
echo 'aneesh:P@ssw0rd' | sudo chpasswd

# Grant full sudo privileges to 'aneesh'
echo 'aneesh ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/aneesh

# Stop and disable firewall (ufw for Ubuntu, firewalld for RHEL-based)
if systemctl list-units --type=service | grep -q ufw; then
  sudo systemctl stop ufw
  sudo systemctl disable ufw
elif systemctl list-units --type=service | grep -q firewalld; then
  sudo systemctl stop firewalld
  sudo systemctl disable firewalld
fi