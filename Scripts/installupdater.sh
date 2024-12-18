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

# Function to pull Docker Compose images and restart updated containers
docker_compose_pull_and_restart() {
    # Change to the directory containing the docker-compose.yml file
    local compose_dir=${1:-$DEFAULT_DOCKER_FILEPATH}
    cd $compose_dir

    echo "Pulling the latest Docker Compose images..."
    docker-compose pull

    echo "Checking if there are any updates..."
    updated=$(docker-compose pull | grep -i "up to date")
    
    if [ -z "$updated" ]; then
        echo "Updates detected. Restarting containers..."
        docker-compose up -d
        echo "Containers restarted."
    else
        echo "No updates detected. Containers are up to date."
    fi
}

# Function to update Docker Compose
update_docker_compose() {
    # Get the latest version number
    local latest_version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    echo "Latest Docker Compose version is $latest_version"

    # Download the latest version
    echo "Downloading Docker Compose $latest_version..."
    sudo curl -L "https://github.com/docker/compose/releases/download/${latest_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # Apply executable permissions to the binary
    echo "Applying executable permissions to Docker Compose binary..."
    sudo chmod +x /usr/local/bin/docker-compose

    # Verify the installation
    echo "Verifying Docker Compose installation..."
    docker-compose --version
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
    update_docker_compose
    docker_compose_pull_and_restart

  elif [[ "$HOSTNAME" == "xo" ]]; then 
    echo "Performing tasks for $HOSTNAME" 

    # Update XO orchestra
    cd "$DEFAULT_XO_FILEPATH" || exit
    sudo bash xo-install.sh --update
  fi

  echo "Completed updates for $HOSTNAME" 
}

# Function to display help information
display_help() {
    echo "Usage: $0 {option}"
    echo
    echo "Options:"
    echo "  -u, --update           Update the system"
    echo "  -au, --appupdate       Update applications and services"
    echo "  -ii, --initialinstall  Perform initial installation and setup"
    echo "  -s, --stop <service_name>  Stop a specific service"
    echo "  -h, --help             Display this help message"
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
  -h|--help)
    display_help
    ;;
  *)
    echo "Invalid option. Use -h or --help for usage information."
    exit 1
    ;;
esac
