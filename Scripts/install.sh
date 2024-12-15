#!/bin/bash


# Get the hostname of the system 
HOSTNAME=$(hostname)


# add repository 


sudo apt-add-repository ppa:git-core/ppa


# Function to check if a package is installed
check_install() {
    PACKAGE=$1
    dpkg -l | grep -qw $PACKAGE || sudo apt-get install -y $PACKAGE
}

# Update package information
echo "Updating package information..."
sudo apt-get update

# Check and install xe-guest-utilities
echo "Checking and installing xe-guest-utilities..."
check_install xe-guest-utilities

# Check and install OpenSSH server
echo "Checking and installing OpenSSH server..."
check_install openssh-server

# Check and install git
echo "Checking and installing git..."
check_install git

# Check and install aptitude
echo "Checking and installing aptitude..."
check_install aptitude

echo "All requested packages have been checked and installed if necessary!"


# Update package list
sudo apt-get update

# Upgrade all installed packages
sudo aptitude safe-upgrade -y

# Clean up unnecessary packages
sudo apt-get autoremove -y

# make autoremove run monthly 

sudo sh -c 'echo "sudo apt autoremove -y" >> /etc/cron.monthly/autoremove'

sudo chmod +x /etc/cron.monthly/autoremove

# Set the timezone to London
timedatectl set-timezone Europe/London

# Verify the change
timedatectl


# Create a 4GB swap file
echo "Creating a 4GB swap file..."
sudo fallocate -l 4G /swapfile

# Set the correct permissions
echo "Setting the correct permissions..."
sudo chmod 600 /swapfile

# Set up the swap area
echo "Setting up the swap area..."
sudo mkswap /swapfile

# Enable the swap file
echo "Enabling the swap file..."
sudo swapon /swapfile

# Make the swap file permanent
echo "Making the swap file permanent..."
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify the swap file is active
echo "Verification:"
sudo swapon --show
free -h



# Disable IPv6
echo "Disabling IPv6..."
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Make changes persistent
echo "Making changes persistent..."
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

# Apply changes
echo "Applying changes..."
sudo sysctl -p

# Verify that IPv6 is disabled
echo "IPv6 has been disabled. Verification:"
cat /proc/sys/net/ipv6/conf/all/disable_ipv6




