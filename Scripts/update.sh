#!/bin/bash

# Get the hostname of the system 
HOSTNAME=$(hostname)

# Update package list
sudo apt-get update

# Upgrade all installed packages
sudo aptitude safe-upgrade -y

# Clean up unnecessary packages
sudo apt-get autoremove -y

if [[ "$HOSTNAME" == "docker" ]]; then 
echo "Performing tasks for $HOSTNAME" # Add the commands for task A here sudo apt-get update

# update docker

cd docker-compose
docker compose pull

elif [[ "$HOSTNAME" == "xo" ]]; then 
echo "Performing tasks for $HOSTNAME" 

# update orchestra

cd XenOrchestraInstallerUpdater
sudo bash xo-install.sh --update

fi


echo "Completed updates for $HOSTNAME" 



