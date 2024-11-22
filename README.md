# Media Server / HomeLab

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
 
  #### Virual Machines
  
- XO 
  - Purpose: Xen Orchestrator
  - Processor: 4x
  - RAM: 4GB
  - Storage: 100GB (Thin Provissioned)
  - Operating System: Ubuntu 24.04.1
 
- HA   
  - Purpose: Home Assistantant
  - Processor: 4x
  - RAM: 4GB
  - Storage: 32GB (Thin Provissioned)
  - Operating System: Home Assistant OS 13.2
 
- Docker   
  - Purpose: Docker Host
  - Processor: 4x
  - RAM: 8GB
  - Storage: 100GB (Thin Provissioned)
  - Operating System: Ubuntu 24.04.1


#### Software

- Xen Orchestrator
- Unifi Network Controller
- Home Assistant
- Docker / Docker Compose
- Home Media Server
  - Plex
  - Sonarr
  - Radarr
  - Homepage
  - Home Assistant

  
