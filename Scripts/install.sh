#!/bin/bash
# Get the hostname of the system 

# Declare global variables

HOSTNAME=$(hostname)
DEFAULT_TIME_ZONE="Europe/London"
DEFAULT_SWAP_FILE="4G"
DEFAULT_DOCKER_FILEPATH="docker-compose"
DEFAULT_XO_FILEPATH="XenOrchestraInstallerUpdater"
DEFAULT_INITIAL_APPS=("xe-guest-utilities" "openssh-server" "git" "aptitude" "cockpit")

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
  local time_zone=${1:-$DEFAULT_TIME_ZONE}

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
  local swap_size=${1:-$DEFAULT_SWAP_FILE}

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
  echo "Pulling Docker"
  cd "$DEFAULT_DOCKER_FILEPATH" || exit

  echo "Pulling Docker Compose images using $compose_file_path..."
  docker compose pull

  echo "Docker Compose images pulled successfully."
}

# Function for Initial Install
Initial_Install() {
  echo "Initial Update"

  # Update system
  update_system

  for initialapp in "${DEFAULT_INITIAL_APPS[@]}"; do
    echo "Checking and installing $initialapp"
    check_install $initialapp
  done

  echo "All requested packages have been checked and installed if necessary!"

  # Change Timezone
  change_time_zone

  # Create Swap file
  create_swap_file

  # Disable IPV6
  disable_ipv6

  # Make autoremove run monthly 
  sudo sh -c 'echo "sudo apt autoremove -y" >> /etc/cron.monthly/autoremove'
  sudo chmod +x /etc/cron.monthly/autoremove
}

app_update() {
  update_system

  if [[ "$HOSTNAME" == "docker" ]]; then 
    echo "Performing tasks for $HOSTNAME" 

    # Update Docker
    pull_docker_compose_from_location

  elif [[ "$HOSTNAME" == "xo" ]]; then 
    echo "Performing tasks for $HOSTNAME" 

    # Update XO orchestra
    cd "$DEFAULT_XO_FILEPATH" || exit
    sudo bash xo-install.sh --update
  fi

  echo "Completed updates for $HOSTNAME" 
}

# Check the provided option and execute the corresponding function
case "$1" in
  -u|--update)
    update_system
    ;;
  -au|--appupdate)
    app_update
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
    echo "Usage: $0 {-u|--update} | {-au|--appupdate} | {-ii|--initialinstall} | {-s|--stop <service_name>}"
    exit 1
    ;;
esac
