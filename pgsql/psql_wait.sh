#!/bin/bash
# Wait for Postgres repsonse

set -e

host="$1"
shift
cmd="$@"

until psql -h "$host" -U "postgres" -c '\q'; do
    >&2 echo "Waiting for Postgres - sleeping"
    sleep 1
done
>&2 echo "Postgres is responding - lets proceed"
exec $cmd