#!/bin/bash
# Get the hostname of the system 
HOSTNAME=$(hostname)

# Function to update the system
update_system() {
  echo "Updating the system..."
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt-get autoremove -y
}

# Function to check if a package is installed
check_install() {
    PACKAGE=$1
    dpkg -l | grep -qw $PACKAGE || sudo apt-get install -y $PACKAGE
}

# Function to change the time zone
change_time_zone() {
  local time_zone=${1:-"Europe/London"}

  echo "Changing time zone to $time_zone..."

  # Check if the specified time zone is valid
  if [ -f /usr/share/zoneinfo/$time_zone ]; then
    sudo timedatectl set-timezone $time_zone
    echo "Time zone changed to $time_zone."
  else
    echo "Invalid time zone: $time_zone"
    exit 1
  fi
}

# Function to create a swap file with a default size of 4GB if no size is specified
create_swap_file() {
  local swap_size=${1:-4G}

  echo "Creating a ${swap_size} swap file..."

  sudo fallocate -l $swap_size /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile

  echo "Swap file created and enabled."

  # Add to /etc/fstab for persistence
  if ! grep -q '/swapfile' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  fi
}

# Function to permanently disable IPv6
disable_ipv6() {
  echo "Disabling IPv6..."

  # Add/modify sysctl settings
  sudo bash -c 'cat << EOF > /etc/sysctl.d/99-disable-ipv6.conf
# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF'

  # Apply the settings
  sudo sysctl --system

  echo "IPv6 has been disabled. A reboot is required for changes to take full effect."
}

# Function to stop a service
stop_service() {
  local service_name=$1
  echo "Stopping service: $service_name"
  sudo systemctl stop $service_name
}


# Function to pull Docker Compose images from a specified location
pull_docker_compose_from_location() {
  local compose_file_path=${1:-/docker-compose/docker-compose.yml}
  local compose_dir

  # Extract the directory from the specified path
  compose_dir=$(dirname "$compose_file_path")

  # Check if the specified Docker Compose file exists
  if [ -f "$compose_file_path" ]; then
    echo "Changing to directory $compose_dir..."
    cd "$compose_dir" || exit

    echo "Pulling Docker Compose images using $compose_file_path..."
    docker-compose -f $(basename "$compose_file_path") pull

    echo "Docker Compose images pulled successfully."
  else
    echo "Docker Compose file $compose_file_path not found."
    exit 1
  fi
}


# Function Initial Install
Initial_Install() {

# Update system

update_system

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

# Change Timezone

change_time_zone

# Create Swap file
create_swap_file

# Disable IPV6

disable_ipv6

# make autoremove run monthly 

sudo sh -c 'echo "sudo apt autoremove -y" >> /etc/cron.monthly/autoremove'
sudo chmod +x /etc/cron.monthly/autoremove


}



# Check the provided option and execute the corresponding function
case "$1" in
  -u|--update)
    update_system
    ;;
  -ii|--initialinstall)
    Initial_Install
    ;;
  -s|--stop)
    if [ -z "$2" ]; then
      echo "Service name is required for stopping a service"
      exit 1
    fi
    stop_service "$2"
    ;;
  *)
    echo "Usage: $0 {-u|--update} | {-ii|--initialinstall} {-s|--stop <service_name>}"
    exit 1
    ;;
esac

