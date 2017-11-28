# Overview
A collection of scripts and docker builds to create the infrastructure required for HipChat Datacenter ( Redis, Postgres, NFS, HAPRoxy )

Note this is not for production. Only tested via MacOS and using VMWare Fusion to run Hipchat DC Nodes.

## init_stack.sh
Creates the directories needed for docker-compose persistent storage and tests port connectivity.

## del_stack.sh
Deletes the composed stack but keeps container images + data on volumes. 

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

