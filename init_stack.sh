#!/bin/bash
PORTS=(2049 5432 6379 1936 666)
# Ensure dirs are present prior to compose
mkdir -p $HOME/dockerdata/nfs_hipchat $HOME/dockerdata/rds_hipchat/ $HOME/dockerdata/psql_hipchat/ $HOME/dockerdata/ha_hipchat/
# Copy NFS Export CFG to Dockerdata
cp -f nfs-export-cfg $HOME/dockerdata/nfs_hipchat/nfs-export-cfg
# Test ports on localhost are not in use
printf "Testing the following ports for availability:\n"
printf "%s\n" "${PORTS[@]}"
{
for element in "${PORTS[@]}";
do
    nc -zv -w 1 127.0.0.1 ${PORTS[0]}; nc -zv -w 1 127.0.0.1 ${PORTS[1]}; nc -zv -w 1 127.0.0.1 ${PORTS[2]}; nc -zv -w 1 127.0.0.1 ${PORTS[3]}; nc -zv -w 1 127.0.0.1 ${PORTS[4]};
done
} &> /dev/null
    if [ $? -eq 1 ]
        then
            echo "Port Test Passed"
    else
        echo "Port test failed, check ports 2049-NFS, 5432-POSTGRES, 666-HAPROXY, 1936-HAPROXY and 6379-REDIS"
        echo  "This failure means a port is already in use, and the docker compose will fail"
        exit 1
    fi
# Check if we've got a SSL Cert, else create one
stat hipc.pem
    if [ $? -eq 1 ]
    then
        echo "No hipc.pem for HAProxy, Generating cert!"
        openssl req -x509 -newkey rsa:4096 -keyout key.pem -out hipc.crt -days 30 -nodes -subj "/C=AU/ST=Sydney/L=Sydney/O=1337 Hax/OU=Valhalla/CN=local.com"
        cat key.pem hipc.crt > hipc.pem
    else
        echo "Found hipc.pem! Let's build!"
    fi
# Building Custom Containers:
docker build -f Dockerfile_HAPROXY -t haproxy_dev .
printf "HAProxy Container built and tagged as haproxy_dev\n"
# Start Composing
echo "Starting Compose of Backend HipChat Stacks"
docker-compose -f hcdc_nfs_rds_psql.yml up -d
# Output Docker Containers
docker ps -a
# Helpful Info
printf "To drop into a shell within each docker contain the substitute each container name with following commands:\n"
printf "docker exec -it container_name sh\n"
printf "Note some alpine containers do not have bash!\n"
printf "Here's a list of the running container names:\n"
docker ps | awk '{print $NF}' | grep -e '/*_hipchat'
printf "Load Balancer Status Page: http://localohost:1936\n"
printf "Your connection for Redis, Postgres and NFS should be the primary IP address of your workstation\n"
exit 0
