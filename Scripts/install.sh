#!/bin/bash

# Get the hostname of the system 
HOSTNAME=$(hostname)

# Update package list
sudo apt-get update

# Upgrade all installed packages
sudo aptitude safe-upgrade -y

# Clean up unnecessary packages
sudo apt-get autoremove -y

# List of packages to check and install if necessary
packages=("aptitude" "openssh-server" "package3")

for pkg in "${packages[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg "; then
        echo "$pkg is already installed."
    else
        echo "$pkg is not installed. Installing..."
        sudo apt-get install -y $pkg
    fi
done

echo "Package check and installation complete."

# Create Swap File

sudo fallocate -l 4G /swapfile

# Set correct permissions

sudo chmod 600 /swapfile

# set up swap 

sudo mkswap /swapfile

# enable swap

sudo swapon /swapfile

# Make swap file permenent

echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab



# Disable IPv6 by adding configuration to sysctl.conf

echo "Disabling IPv6..."
sudo sed -i 's/^#net.ipv6.conf.all.disable_ipv6 = 1/net.ipv6.conf.all.disable_ipv6 = 1/' /etc/sysctl.conf
sudo sed -i 's/^#net.ipv6.conf.default.disable_ipv6 = 1/net.ipv6.conf.default.disable_ipv6 = 1/' /etc/sysctl.conf
sudo sed -i 's/^#net.ipv6.conf.lo.disable_ipv6 = 1/net.ipv6.conf.lo.disable_ipv6 = 1/' /etc/sysctl.conf

# Apply the changes
sudo sysctl -p

echo "IPv6 has been disabled."









