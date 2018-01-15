#!/bin/bash

# Configure these values...
DBSERVER=127.0.0.1
REDISSERVER=127.0.0.1
NFSSERVER=127.0.0.1

POSTGRES=5432
REDIS=6379
NFS=2049

DBLOG=postgres_network.log
RDLOG=redis_network.log
NFSLOG=nfs_network.log
DBPINGLOG=dbping.log
RDPINGLOG=rdsping.log
NFSPINGLOG=nfsping.log
LIMITS=ulimits.log
CNTRACK=conntrack.log
SARLOG1=sarlog1.log
SARLOG2=sarlog2.log
CPUDATA=cpu.log

OPTS1="-zvw1"
C="-c 1"

VAL=10s
VAL2=30s
TIMESTAMP="$(date +%D%H%M%S)"

# Record the CPU Profiles
cat /proc/cpuinfo >> $CPUDATA

# Monitor Functions
function dbconnect() {
nc $OPTS1 $DBSERVER $POSTGRES >> $DBLOG 2>&1
}

function rdsconnect() {
nc $OPTS1 $REDISSERVER $REDIS >> $RDLOG 2>&1
}

function nfsconnect() {
nc $OPTS1 $NFSSERVER $NFS >> $NFSLOG 2>&1
}

function dbping() {
ping $DBSERVER $C -D >> $DBPINGLOG 2>&1
}

function rdsping() {
ping $REDISSERVER $C -D >> $RDPINGLOG 2>&1
}

function nfsping() {
ping $NFSSERVER $C -D >> $NFSPINGLOG 2>&1
}

function reculimit() {
ulimit -a | gawk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0 }' >> $LIMITS
}

function conntrack() {
cat /proc/sys/net/netfilter/nf_conntrack_count | gawk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0 }' >> $CNTRACK
}

function sard() {
sar -d >> $SARLOG1
sar >> $SARLOG2
}

# Execute the loop
{
while sleep $VAL;
do
    dbconnect; echo "Executing DB Connect Monitor"
    rdsconnect; echo "Executing REDIS Connect Monitor"
    nfsconnect; echo "Executing NFS Connect Monitor"
    dbping; echo "Pinging the DB Server for Network Latency"
    rdsping; echo "Pinging Redis.. should be HiRedis"
    nfsping; echo "Pinging NFS Storage"
    reculimit; echo "Recording ulimits"
    conntrack; echo "Recording conntrack table"
    sard; echo "Recording SAR TPS"
done
}
