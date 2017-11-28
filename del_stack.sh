#!/bin/bash
printf "Deleting Hipchat backend services\nThis does not remove data, data is stored on /Users/name/dockerdata/\n"
printf "Error response from daemon can be ignored as containers are already dead\n"
docker ps -a | awk '{print $NF}' | grep -e '/*_hipchat' | xargs docker kill | xargs docker rm
exit 0