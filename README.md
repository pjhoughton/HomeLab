# Homelab

## Overview
This repository documents and manages my homelab environment.  
It includes virtualization with **XCP-ng**, orchestration via **Xen Orchestra**, and storage integration using **Synology NAS shares**.  
The goal is to provide a reliable, flexible, and automated platform for experimentation, learning, and running services at home.

## Vision & Documentation
This repository is part of my broader homelab and automation projects.  
For the full vision, detailed documentation, and cross project context, visit my website:  
👉 [pjhoughton.github.io](https://pjhoughton.github.io)

*Building blocks of my homelab — automation, containers, and smart integrations, shared openly.*

## Getting Started
### Prerequisites
- XCP-ng installed on physical host(s)
- Xen Orchestra deployed for management
- Synology NAS available on the network
- SSH access and administrative credentials

### Usage
#### 1. Virtualization with XCP-ng
- Install XCP-ng on your server hardware.
- Access the host via Xen Orchestra or `xe` CLI.
- Example: create a new VM
```bash
xe vm-install template="Debian 12" new-name-label="TestVM"


# Media Server / HomeLab

Home Lab Incorporating XCP-NG hypervisor for VM and Docker compose for containers 

This repo is a constant work-in-progress... 

#### Diagram

![homelab setup](https://github.com/user-attachments/assets/20f216e2-a52b-47d4-816a-0dcf0e2795d9)

#### Hardware 

- Nas (Network Attached Storage) 
  - Model: Synology DS918+ 
  - Processor: Intel Celeron J3455 Quad Core (2M cache, 1.5 bursts up to 2.3 GHz) with AES-NI hardware encryption engine1234.
  - RAM: 8GB DDR3L
  - Network: Dual 1GbE LAN  using Link Aggregation (LACP)
  - Storage: 4 * 6TB WD RED HDD
  - Operating System: Version: 7.2.2-72806 Update 1
 
- Mini PC (XCP-NG Host) 
  - Model: Beelink EQR6
  - Processor: AMD Ryzen 9 6900HX 8 Core 16 Threads
  - RAM: 24GB DDR5
  - Network: Dual 1GbE LAN  using Link Aggregation (LACP)
  - Storage: 500GB PCIe4.0 SSD
  - Operating System: XCP-NG Version: 8.3
 
  #### Virtual Machines
  
- XO 
  - Purpose: Xen Orchestrator ( Virtualization Manager)
  - Processor: 4
  - RAM: 4GB
  - Storage: 100GB (Thin Provisioned)
  - Operating System: Ubuntu 24.04.1
 
- HA   
  - Purpose: Home Assistant ( Home automation)
  - Processor: 4
  - RAM: 4GB
  - Storage: 32GB (Thin Provisioned)
  - Operating System: Home Assistant OS 13.2
 
- Docker   
  - Purpose: Docker Host
  - Processor: 4
  - RAM: 8GB
  - Storage: 100GB (Thin Provisioned)
  - Operating System: Ubuntu 24.04.1


#### Software

- Xen Orchestra (Ubuntu VM with XO built from sources)

Based on Citrix XenServer hypervisor™, XCP-ng is a fully open source virtualization platform. Result of the massive cooperation between individuals as well as companies XCP-ng is now part of the Linux Foundation as an incubated solution under the Xen Project. XCP-ng is very similar as Citrix Hypervisor™ with the notable exception of the restrictions: XCP-ng has none! Unleash the true power of virtualization.

Xen Orchestra is the officially supported client for XCP-ng. It's currently developed by the same team as the XCP-ng project (Vates).

It's also far more than just a client: because it runs 24/7 in a daemon, a lot of extra cool stuff is possible:

Various reports
ACLs
Self Service
VM load balancing
SDN controller
Backup
Delta backup
Disaster Recovery
Continuous Replication
Backup with RAM
Warm migration
and much more!
 
- Unifi SDN  Network Controller ( built into gateway) 

The UniFi Controller serves as the central nervous system for managing and configuring UniFi devices, such as switches, firewalls, Voice over IP phones, and access points.

For Self hosting i would advise using the install/updater scripts created by: https://glennr.nl/s/unifi-network-controller

- Home Assistant ( VM using vmdk from Home assistant)

Home Assistant is free and open-source software used for home automation. It serves as an integration platform and smart home hub, allowing users to control smart home devices

- Docker / Docker Compose

Docker is a set of platform as a service (PaaS) products that use OS-level virtualization to deliver software in packages called containers.

- Home Media Server

  - Plex (Synology App)

Plex Media Server (PMS) is free software that enables users to create a client–server for movies, television shows, and music.

  - SABNZB ( Docker Container)

SABnzbd is a multi-platform binary newsgroup downloader.
The program works in the background and simplifies the downloading verifying and extracting of files from Usenet.

  - Sonarr (Docker container)

Sonarr is a PVR for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

  - Radarr (Docker container)

Radarr is a movie collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new movies and will interface with clients and indexers to grab, sort, and rename them. It can also be configured to automatically upgrade the quality of existing files in the library when a better quality format becomes available.

  - Homepage (Docker container)

A modern, fully static, fast, secure fully proxied, highly customizable application dashboard with integrations for over 100 services and translations into multiple languages. Easily configured via YAML files or through docker label discovery.

![Homepagedesktop](https://github.com/user-attachments/assets/162b93a3-7677-46c0-a8a2-8bd33ac6ac1d)

  - GlueTUN ( Docker container)

Gluetun is a VPN client in a thin Docker container for multiple VPN providers, written in Go, and using OpenVPN or Wireguard, DNS over TLS, with a few proxy servers built-in.

This is not used anymore instead i added a client VPN to my UNifi Router, which always multiple VPN instances for different regions and  allocate  specific devices to use the VPN.

  - NGINX Proxy Manager (Docker Container)

A Proxy manager that integrates with Lets Encrypt with DNS chaallenge ,  allowing all internal servers to have a valid certificate without having to pay for a  certificate or expose them to the internet. THis removes the anoying browser certificate errors    


####  Configure mini PC

  - Enter bios using del key 
  - Ensure EUFI is enabled not bios 
  - Ensure PC auto starts after a power failure 
  - set UMA Frame Buffer Size 1GB ( default 4Gb)

Click on Advanced tab - AMD CBS - FCH Common options - FCH Common options set to always on.

  - Ensure virtualization is enabled
  - 
####  SSH Keys

Its best practice to comnect using SSH Key pairs. The Public key can be given out as required the private key should be kept secret. Where possible you should use a modern algorythm such as ed25519, if a legacy system doesnt support it RSA 2048 or above can be used. Ideally you should set a passphrase, this may not  be possible with automation


 - Generate a Key pair
   
To generate the key pair open terminal on Windows, Linux  or Mac  and type the following command:
 
   - rsa 

 ssh-keygen -o -t rsa -b 4096 -C "pjhoughton"

   - ed25519

ssh-keygen -a 100 -t ed25519  -C "pjhoughton"


 


####  Configure NAS

I mostly use the NAS as datastore but I do currently use the Synology Plex App although this could  just as easily be a Docker container.

  - Folder Structure
    
   ![format](https://github.com/user-attachments/assets/e5fbd97f-1979-4adb-8203-d1957cfe74ad)

### Configure Ubuntu 24.01

  -  Ensure system is upto date
    
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

  - Install xcp vmtools
    
Mount Disk on server
sudo mount /dev/cdrom /mnt
sudo bash /mnt/Linux/install.sh -y

  - Set Timezone
    
sudo dpkg-reconfigure tzdata

  - Install NTP

sudo apt update && sudo apt install ntp -y
service ntp status

  - Create a swap file
    
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab'

  - Configure autoremove

sudo apt autoremove -y
sudo sh -c 'echo "sudo apt autoremove -y" >> /etc/cron.monthly/autoremove'
sudo chmod +x /etc/cron.monthly/autoremove

- Create NFS Mount Points

Prerequistes: ensure NFS Shares on created on the NAS (NFS Server) . NFS Permisisons are based on IP adddress not username or password

sudo nano /etc/fstab

Add the rquired mount points 

NASIPAdress:/volumename/docker  /mnt/docker nfs nfsvers=4.1,rw,auto 0 0
NASIPAddress:/volumename/media  /mnt/media nfs nfsvers=4.1,rw,auto 0 0

install nfs client package 

sudo apt install nfs-common

create the mount path

sudo mkdir -p /mnt/docker
sudo mkdir -p /mnt/media

 

sudo apt install nfs-common

####  XCP-NG & XXen Orchestra

  - XCP-NG
    
    - install xcp-ng
      - Download ISO file for XCP-ng from:
 https://mirrors.xcp-ng.org/isos/8.3/xcp-ng-8.3.0.iso?https=1

      - Use Rufus to create the bootable USB stick: https://rufus.akeo.ie/


  - XO (Xen Orchestra)
    - Build a base VM either ubuntu or Debian
    - install  prerequisites git and oppenssl
    - Use XenOrchestrorInstallerUpfster script to deploy Xen Orchestrator. https://github.com/ronivay/XenOrchestraInstallerUpdater
   



commands 

git clone https://github.com/ronivay/XenOrchestraInstallerUpdater.git

cd XenOrchestraInstallerUpdater

cp sample.xo-install.cfg xo-install.cfg

sudo nano xo-install.cfg - amend options as appropriate by uncommenting 

sudo apt-get install openssl

sudo mkdir /opt/xo

sudo openssl req -newkey rsa:4096 \
            -x509 \
            -sha256 \
            -days 3650 \
            -nodes \
            -out /opt/xo/xo.crt  \
            -keyout /opt/xo/xo.key
  


#### Install Docker Compose 

  - Install Docker 

sudo apt install curl apt-transport-https ca-certificates software-properties-common 

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt install docker-ce -y

sudo usermod -aG docker $USER

newgrp



  - Install Docker Compose 

mkdir -p ~/.docker/cli-plugins/

 curl -SL https://github.com/docker/compose/releases/download/v2.2.27/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

chmod +x  ~/.docker/cli-plugins/docker-compose



  - Useful Docker Commands:

    - Stops, removes containers ,Volumes, networks 

docker compose down

    - Download all containers latest version 

docker compose pull

    - Builds, (re)creates, starts, containers  -d  runs in background 

docker compose up -d

    - Lists Containers 

docker compose ps











  
