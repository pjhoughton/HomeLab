#!/bin/bash
# Get the hostname of the system 

# Declare global variables
HOSTNAME=$(hostname)
DEFAULT_TIME_ZONE="Europe/London"
DEFAULT_SWAP_FILE="4G"
DEFAULT_DOCKER_FILEPATH="docker-compose"
DEFAULT_XO_FILEPATH="XenOrchestraInstallerUpdater"
DEFAULT_INITIAL_APPS=("xe-guest-utilities" "openssh-server" "git" "aptitude" "cockpit")

# Function to display help
display_help() {
  echo "Usage: $0 [option]"
  echo
  echo "Options:"
  echo "  update_system                Update the system"
  echo "  check_install PACKAGE_NAME   Check if a package is installed and install it if not"
  echo "  change_time_zone TIME_ZONE   Change the time zone (default: $DEFAULT_TIME_ZONE)"
  echo "  create_swap_file SIZE        Create a swap file of the specified size (default: $DEFAULT_SWAP_FILE)"
  echo "  disable_ipv6                 Permanently disable IPv6"
  echo "  stop_service SERVICE_NAME    Stop the specified service"
  echo "  docker_compose_pull_and_restart DIRECTORY"
  echo "                               Pull Docker Compose images and restart containers in the specified directory"
  echo "  update_docker_compose        Update Docker Compose to the latest version"
  echo "  initial_install              Run the initial system setup"
  echo "  app_update                   Update system and specific applications"
  echo "  help                         Display this help message"
  echo
}

# Function to update the system
update_system() {
  echo "Updating the system..."
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt-get autoremove -y
}

# Function to stop a service
stop_service() {
  local service_name=$1
  echo "Stopping service: $service_name"
  sudo systemctl stop $service_name
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
  if [ -f /usr/share/zoneinfo/$time_zone]; then
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


# Function to set up the firewall and allow all outgoing connections
setup_firewall() {
    # Enable UFW firewall
    sudo ufw enable

    # Allow all outgoing connections
    sudo ufw default allow outgoing

    # Loop through the global ports and allow them
    for port in "${GLOBAL_PORTS[@]}"; do
        echo "Allowing traffic on port $port"
        sudo ufw allow $port
    done

    # Check the status of the firewall
    sudo ufw status
}



# Call the function with optional arguments for comment and remote computers
create_and_copy_ssh_keys "$1" "$2"


# Function to install Docker and Docker Compose from sources
install_docker_and_compose() {
    # Update package information and install prerequisites
    echo "Updating package information and installing prerequisites..."
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

    # Add Docker's official GPG key
    echo "Adding Docker's official GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Set up the Docker stable repository
    echo "Setting up the Docker stable repository..."
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"

    # Update package information again
    echo "Updating package information again..."
    sudo apt-get update

    # Install Docker CE (Community Edition)
    echo "Installing Docker CE (Community Edition)..."
    sudo apt-get install -y docker-ce

    # Download the latest version of Docker Compose
    local latest_version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    echo "Downloading Docker Compose version $latest_version..."
    sudo curl -L "https://github.com/docker/compose/releases/download/${latest_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # Apply executable permissions to the Docker Compose binary
    echo "Applying executable permissions to Docker Compose binary..."
    sudo chmod +x /usr/local/bin/docker-compose

    # Verify the installations
    echo "Verifying Docker installation..."
    docker --version
    echo "Verifying Docker Compose installation..."
    docker-compose --version

    echo "Docker and Docker Compose have been successfully installed!"
}

# Function to install Ansible
install_ansible() {
    # Update package information
    echo "Updating package information..."
    sudo apt-get update

    # Install prerequisites
    echo "Installing prerequisites..."
    sudo apt-get install -y \
        software-properties-common

    # Add Ansible PPA
    echo "Adding Ansible PPA..."
    sudo add-apt-repository --yes --update ppa:ansible/ansible

    # Install Ansible
    echo "Installing Ansible..."
    sudo apt-get install -y ansible

    # Verify the installation
    echo "Verifying Ansible installation..."
    ansible --version
}


# Function to install Xen Orchestra using the installer/updater script
install_xo() {
    # Update package information and install prerequisites
    echo "Updating package information and installing prerequisites..."
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

    # Download and run the installer/updater script from GitHub
    echo "Downloading and running the Xen Orchestra installer/updater script..."
    sudo curl -fsSL https://raw.githubusercontent.com/ronivay/XenOrchestraInstallerUpdater/master/xo-install.sh | sudo bash

    # Verify the installation
    echo "Verifying Xen Orchestra installation..."
    xo --version
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
initial_install() {
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
  
  # setup firewall 
  setup_firewall
  
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

# Main script logic
if [ $# -eq 0 ]; then
  display_help
  exit 1
fi

case "$1" in
  update_system)
    update_system
    ;;
  install_package)
    check_install "$2"
    ;;
  change_time_zone)
    change_time_zone "$2"
    ;;
  create_swap_file)
    create_swap_file "$2"
    ;;
  disable_ipv6)
    disable_ipv6
    ;;
  stop_service)
    stop_service "$2"
    ;;
  docker_compose_pull)
    docker_compose_pull_and_restart "$2"
    ;;
  update_docker_compose)
    update_docker_compose
    ;;
  initial_install)
    initial_install
    ;;
  app_update)
    app_update
    ;;
  help)
    display_help
    ;;
  *)
    echo "Invalid option: $1"
    display_help
    exit 1
    ;;
esac
