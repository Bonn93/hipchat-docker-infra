# Overview
A collection of scripts and docker builds to create the infrastructure required for HipChat Datacenter ( Redis, Postgres, NFS, HAPRoxy ). 

Note this is not for production. Only tested via MacOS and using VMWare Fusion to run Hipchat DC Nodes. I've only tested this on MacOS, however it should work just fine on a generic linux/docker hosts. 

Use this for:
* Testing HA
* Fast POCs
* Testing Features/New Versions without several VMS

# Upcoming HA Features 
* Redis HA Clustering
* Postgres HA Clustering
* HAProxy Clustering

### Not for production use ###

## Getting Started:
* Clone this Repo
* ./init_stack.sh 
* Get a coffee 
* ???
* Profit


## init_stack.sh
Creates the directories needed for docker-compose persistent storage and tests port connectivity.
* Creates $HOME/dockerdata/blah
* Copies the NFS Exports cfg to the above nfs_hipchat folder
* Tests local ports for availability ( can remove this and let docker handle your failures )
* Checks if hipc.pem is present, if not creates a dummy .pem for you
* Builds the HAProxy Container and tags the image locally
* Runs the docker compose and prints outputs to your shell
* Runs the docker-compose-ha.yml by default
    * 3x Redis
    * 1x Sentinel
    * 3x Postgres 9.5 in Master/Slave
    * 2x Pgpool with Watchdog
    * 1x HAProxy
    * 1x NFSv4
* Update the docker-compose -f line with choice of docker-compose.yml or docker-compose-ha.yml 

## del_stack.sh
Deletes the composed stack but keeps container images + data on volumes.

## down_stack.sh
Performs a docker-compose down to shutdown all containers.

## nuke.sh
Deletes all containers and images! Only use to cleanup images and containers when no longer neded. DELETES all containers!
* Runs -f flag to force the deletion of images

# Standalone Services:
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
* configure backend IP addresses in haproxy.cfg or use 192.168.122.100 etc etc

### Next Steps
* Deploy the HipChat 3.1.1+ .OVA
* Configure your HCDC Nodes with IPs from the HAProxy.cfg
* Using the Web UI Setup wizard, configure the Postgres service, then Redis and NFS using the IP address from your workstation after a successful compose
* To benefit from automagic failovers, connect to postgres via PGPool (port 5430) and Redis Sentinel via (port 9000)
* Using the hipchat datacenter cli - Configure your instance using a config.json, restart the instance and reboot. On reboot, perform the hipchat datacenter selfcheck
* Official Atlassion doco for these steps here: https://confluence.atlassian.com/hipchatdc3/configure-hipchat-data-center-nodes-909770912.html

# High Availability Services:
### NFS
* Singular instance for now... 

### Redis HA
* 3x Redis 3.2 Instances ( 1 Master, 2 Slaves )
* 1x Sentinel Monitor ( QUORUM = 1)

### Postgres + PGPool
* 3x Postgres 9.5 Instances ( 1 Master, 2 Slaves )
* 2x PGPool with Watchdog

### HAProxy + KeepAlived
* Singular Instance for now

# Next Steps
* Deploy the HipChat 3.1.1+ .OVA
* Configure your HCDC Nodes with IPs from the HAProxy.cfg
* Using the Web UI Setup wizard, configure the Postgres service, then Redis and NFS using the IP address from your workstation after a successful compose
* Using the hipchat datacenter cli - Configure your instance using a config.json, restart the instance and reboot. On reboot, perform the hipchat datacenter selfcheck
* Official Atlassion doco for these steps here: https://confluence.atlassian.com/hipchatdc3/configure-hipchat-data-center-nodes-909770912.html


# I want to use this in Production?
By all means, take the concept, but this isn't a production deployment bible. You should look at the following as the next steps:
* Using a CI/CD Pipeline to manage container builds + publish them to a Registry
* Use a Orchestration engine such as Kubernetes instead as docker-compose is not a production ready service
* Scale/Replicas of "services"
* Apply Best practices like 3+ Sentinel Nodes, Multiple PGPOOL nodes etc
* Use AWS EFS + NFS or a SAN NFS Volume and let the hardware vendors manage your disk/failover
* Understand how docker volumes, data persistence and docker in general works
