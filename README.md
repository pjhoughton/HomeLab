# Media Server / HomeLab

Home Lab Incorporating XCP-NG hypervisor for VM and Docker compose for containers 

This repo is a constant work-in-progress... 


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
  - Purpose: Xen Orchestrator
  - Processor: 4
  - RAM: 4GB
  - Storage: 100GB (Thin Provisioned)
  - Operating System: Ubuntu 24.04.1
 
- HA   
  - Purpose: Home Assistant
  - Processor: 4
  - RAM: 4GB
  - Storage: 32GB (Thin Provisioned)
  - Operating System: Home Assistant OS 13.2
 
- Docker   
  - Purpose: Docker Host
  - Processor: 4x
  - RAM: 8GB
  - Storage: 100GB (Thin Provisioned)
  - Operating System: Ubuntu 24.04.1


#### Software

- Xen Orchestrator (Ubuntu VM with XO built from sources) 
- Unifi SDN  Network Controller ( built into gateway) 
- Home Assistant ( VM using vmdk from Home assistant)
- Docker / Docker Compose
- Home Media Server
  - Plex (Synology App)
  - Sonarr (Docker container)
  - Radarr (Docker container)
  - Homepage (Docker container)

####  Configure mini PC

  - Enter bios using del key 
  - Ensure EUFI is enabled not bios 
  - Ensure PC auto starts after a power failure 

Click on Advanced tab - AMD CBS - FCH Common options - FCH Common options set to always on.

  - Ensure virtualization is enabled 


####  Configure NAS

I mostly use the NAS as datastore but I do currently use the Synology Plex App although this could  just as easily be a Docker container.

  - Folder Structure


![Screenshot 2024-11-21 164210](https://github.com/user-attachments/assets/805b88e4-11cb-4c24-a3d8-449c173b8e08)



####  XCP-NG & Xen Orchestrator 

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



  - XCP-NG
    - install xcp-ng
      - Download ISO file for XCP-ng from:
 https://mirrors.xcp-ng.org/isos/8.3/xcp-ng-8.3.0.iso?https=1

      - Use Rufus to create the bootable USB stick: https://rufus.akeo.ie/


  - XO (Xen Orchestrator)
    - Build a base VM either ubuntu or Debian
    - install  prerequisites git and oppenssl
    - Use XenOrchestrorInstallerUpfster script to deploy Xen Orchestrator.


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
  




#### Docker Compose 

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











  
