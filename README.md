# Overview
A collection of scripts and docker builds to create the infrastructure required for HipChat Datacenter ( Redis, Postgres, NFS, HAPRoxy ). 

Note this is not for production. Only tested via MacOS and using VMWare Fusion to run Hipchat DC Nodes. I've only tested this on MacOS, however it should work just fine on a generic linux/docker hosts. 

# Upcoming HA Features 
* Redis HA Clustering
* Postgres HA Clustering
* HAProxy Clustering

### Not for production use ###
## init_stack.sh
Creates the directories needed for docker-compose persistent storage and tests port connectivity.
* Creates $HOME/dockerdata/blah
* Copies the NFS Exports cfg to the above nfs_hipchat folder
* Tests local ports for availability ( can remove this and let docker handle your failures )
* checks if hipc.pem is present, if not creates a dummy .pem for you
* Builds the HAProxy Container and tags the image locally
* Runs the docker compose and prints outputs to your shell

## del_stack.sh
Deletes the composed stack but keeps container images + data on volumes. 

## nuke.sh
Deletes all containers and images! Only use to cleanup images and containers when no longer neded. DELETES all containers!

### NFS
Shared storage used by all HCDC Nodes
* NFSv4 Only
* Not secure in any way
* Seems HCDC nodes need a reboot after the config.json is applied for selfcheck to pass NFS IO tests

### Redis
Shared NoSQL Instance used by HCDC Nodes
* Simple Redis instance for caching.
* All Defaults

### Postgres
Shared SQL Database used by HCDC Nodes
* Simple Postgres DB for HipChat
* Schema creation handled by Application

### HAProxy Load balancer
Frontend of HipChat + SSL Termination
* BYO Self Generated Certificate as hipc.pem
* Config is best known and tested option
* Update Frontend port to whatever..
* Configure your HCDC Instance to the FQDN pointing at the Load Balancer ( hack your /etc/hosts if you don't have DNS )
* configure backend IP addresses in haproxy.cfg or use 192.168.21.171/172/173

### Next Steps
* Deploy the HipChat 3.1.1+ .OVA
* Using the hipchat cli ( hipchat network -opts ) configure your ip addresses, gateways, dns etc
* Using the Web UI Setup wizard, configure the Postgres service, then Redis and NFS using the IP address from your workstation after a successful compose
* Using the hipchat datacenter cli - Configure your instance using a config.json, restart the instance and reboot. On reboot, perform the hipchat datacenter selfcheck
* Official Atlassion doco for these steps here: https://confluence.atlassian.com/hipchatdc3/configure-hipchat-data-center-nodes-909770912.html

