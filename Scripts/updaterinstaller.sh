#!/bin/bash


# Declare global variables
HOSTNAME=$(hostname)
DEFAULT_TIME_ZONE="Europe/London"
DEFAULT_SWAP_FILE="4G"
DEFAULT_DOCKER_FILEPATH="docker-compose"
DEFAULT_XO_FILEPATH="XenOrchestraInstallerUpdater"
DEFAULT_COMMENT="HoughtonPJ"
DEFAULT_INITIAL_APPS=("xe-guest-utilities" "openssh-server" "git" "aptitude" "cockpit")
GLOBAL_PORTS=("22" "9090" "443" "80")
#REMOTE_COMPUTERS=("user@host1" "user@host2")

# Function to display help
display_help() {
  echo "Usage: $0 [option]"
  echo
  echo "Options:"
  echo "  -u  --update                             Update the system"
  echo "  -ua --update_app                         Update system and specific applications"
  echo "  --update_docker_compose                  Update Docker Compose to the latest version"
  echo "  --docker_pull DIRECTORY                  Pulls new Docker container versions and restarts if any have updated (default: $DEFAULT_DOCKER_FILEPATH)"
  echo "  -i  --install PACKAGE_NAME               Check if a package is installed and install it if not"
  echo "  -ia --install_ansible                    Install Ansible"
  echo "  -id --install_docker                     Install Docker and Docker Compose"
  echo "  -ii --install_initial                    Run the initial system setup"
  echo "  -ix --install_xo                         Install Xen Orchestra"
  echo "  --disable_ipv6                           Permanently disable IPv6"
  echo "  --firewall                               enables firewall (default: $GLOBAL_PORTS)"
  echo "  --swapfile  SIZE                         Create a swap file of the specified size (default: $DEFAULT_SWAP_FILE)"
  echo "  --timezone                               Change the time zone (default: $DEFAULT_TIME_ZONE)"
  echo "  --stop_service SERVICE_NAME              Stop the specified service"
  echo "  --create_ssh_keys [COMMENT]              Create rsa and ed25519   SSH keys with the specified comment (or use default comment)"
  echo "  --copy_ssh_keys [user@host ...]          Copy SSH keys to specified remote computers (or use default remote computers)"
  echo "  --create_and_copy_ssh_keys [COMMENT]     Create SSH keys and copy them to specified remote computers"
  echo "  help                                     Display this help message"
  echo
}

# Function to update the system
update_system() {
  echo "Updating the system..."
  sudo apt-get update 
  sudo aptitude safe-upgrade -y
  sudo apt-get autoremove -y
}

# Function to updates apps

update_app() {
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

# Function to check if a package is installed
check_install() {
    PACKAGE=$1
    dpkg -l | grep -qw $PACKAGE || sudo apt-get install -y $PACKAGE
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


# Function to install Docker and Docker Compose from sources
install_docker() {
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

# Function for Initial Install
install_initial() {
  echo "Initial Update"

  # Update system
  sudo apt-get update && sudo apt-get upgrade -y

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

# Function to set up the firewall and allow all outgoing connections
setup_firewall(){
 
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

# Function to stop a service
stop_service() {
  local service_name=$1

  # Check if the service name is provided
  if [ -z "$service_name" ]; then
    echo "Usage: stop_service SERVICE_NAME"
    return 1
  fi

  echo "Stopping service: $service_name"
  
  # Stop the service using systemctl
  sudo systemctl stop "$service_name"
  
  # Check the status of the service to confirm it's stopped
  sudo systemctl status "$service_name"
}


# Function to check if .ssh folder exists and create SSH keys
create_ssh_keys() {
  local comment=${1:-$DEFAULT_COMMENT}

  # Ensure .ssh directory exists locally
  if [ ! -d "$HOME/.ssh" ]; then
    echo "Creating .ssh directory locally..."
    mkdir -p "$HOME/.ssh"
  else
    echo ".ssh directory already exists locally."
  fi

  # Generate an ed25519 SSH key with the provided comment
  echo "Generating ed25519 SSH key with comment '$comment'..."
  ssh-keygen -a 100 -t ed25519 -C "$comment" -f "$HOME/.ssh/id_ed25519" -N ""

  # Generate an RSA 4096-bit SSH key with the provided comment
  echo "Generating RSA 4096-bit SSH key with comment '$comment'..."
  ssh-keygen -t rsa -b 4096 -C "$comment" -f "$HOME/.ssh/id_rsa" -N ""

  echo "SSH keys have been created locally."
}

# Function to copy SSH keys to remote servers
copy_ssh_keys() {
  local remote_computers=("${@:-${REMOTE_COMPUTERS[@]}}")

  # Copy the public keys to each remote computer
  for remote in "${remote_computers[@]}"; do
    echo "Ensuring .ssh directory exists on $remote..."
    ssh $remote 'mkdir -p ~/.ssh'

    echo "Copying ed25519 public key to $remote..."
    ssh-copy-id -i "$HOME/.ssh/id_ed25519.pub" $remote

    echo "Copying RSA 4096-bit public key to $remote..."
    ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" $remote
  done

  echo "SSH keys have been copied to all specified remote computers."
}


# Main script logic
if [ $# -eq 0 ]; then
  display_help
  exit 1
fi

case "$1" in
  -u|--update)
    update_system
    ;;
  -ua|--update_app)
    update_app
    ;;
  --update_docker_compose)
    update_docker_compose
    ;;
  --docker_pull)
    docker_compose_pull_and_restart "$2"
    ;;
  -i|--install)
    check_install "$2"
    ;;
  -ia|--install_ansible)
    install_ansible
    ;;
  -id|--install_docker)
    install_docker
    ;;
  -ii|--install_initial)
    install_initial
    ;;
  -ix|--install_xo)
    install_xo
    ;;
  --disable_ipv6)
    disable_ipv6
    ;;
  --firewall)
    setup_firewall 
    ;;
  --swapfile)
    create_swap_file "$2"
    ;;
  --timezone)
    change_time_zone "$2"
    ;;
  --stop_service)
    stop_service "$2"
	;;
  --create_ssh_keys)
    create_ssh_keys "$2"
    ;;
  --copy_ssh_keys)
    copy_ssh_keys "${@:2}"
    ;;
  --create_and_copy_ssh_keys)
    create_ssh_keys "$2"
    copy_ssh_keys "${@:3}"
    ;;
   
  *)
    echo "Invalid option: $1"
    display_help
    exit 1
    ;;
esac
