#!/bin/bash
# Script Notes..
# Configure IP or FQDNs of Postgres, Redis and NFS Services
# Configure Service Ports
# Configure $VAL for collection frequency pending server load.. Best is 30s
# We check that the sysstat service is installed and enabled on lolubuntu..
# We enable sysstat collections in /etc/defaults/sysstat
# We check that NMON is installed... Install from here if the script exits!

# Configure these values...
DBSERVER=127.0.0.1
REDISSERVER=127.0.0.1
NFSSERVER=127.0.0.1

POSTGRES=5432
REDIS=6379
NFS=2049
# End configurable values

# Log Files
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
NMONDATA="$(hostname)"

OPTS1="-zvw1"
C="-c 1"

VAL=30s
TIMESTAMP="$(date +%D%H%M%S)"
PWD=$(pwd)

# Begin script
printf "Data and logs contained in $PWD\n"
printf "Control-C stops script and tars all data...\n"

# This is a control-c trap... this exits the script and tars the logs in the working directory
trap '{ echo "Control-C detected, wrapping logs an cleaning up.... exiting.." ;
    # Kill nmon process..
    kill -9 $(pidof nmon)
        echo "killing nmon collector..."
    # Collect SAR results
    sar -d >> $SARLOG1
    sar >> $SARLOG2
    tar -czvf support.tar.gz $DBLOG $RDLOG $NFSLOG $DBPINGLOG $RDPINGLOG $NFSPINGLOG $LIMITS $CNTRACK $SARLOG1 $SARLOG2 $CPUDATA $NMONDATA
        echo "compressing logs..."
    exit 1; }' INT


# Record the CPU Profiles
cat /proc/cpuinfo >> $CPUDATA

# Check systat enabled, if not enable and restart services
service sysstat status
    if [ $? -eq 1 ]
    then echo "sysstat service is not enabled or installed, attempting..."
    apt-get install sysstat
    echo "ENABLED="true"" > /etc/default/sysstat
    service sysstat enable
    service sysstat start
    type sar
    fi

# Check if NMON is present
type nmon
    if [ $? -eq 1 ]
    then echo "Nmon does not exist!"
    echo "Nmon is not installed! Stable without source is here: http://sourceforge.net/projects/nmon/files/nmon_linux_14i.tar.gz\n"
    echo "Use the Use the UbuntuX86_64_13 binary and cp to /usr/bin/nmon\n"
    echo "Ensure the manual command like this works.. nmon -f -t\n"
    exit
    fi

# Start NMON background collector
nmon -f -t $NMONDATA.nmon & echo $!

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
done
}
