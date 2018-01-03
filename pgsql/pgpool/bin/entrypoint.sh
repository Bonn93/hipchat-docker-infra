#!/usr/bin/env bash
set -e

export CONFIG_FILE='/usr/local/etc/pgpool.conf'
export PCP_FILE='/usr/local/etc/pcp.conf'
export HBA_FILE='/usr/local/etc/pool_hba.conf'
export POOL_PASSWD_FILE='/usr/local/etc/pool_passwd'

#echo "host all all 0.0.0.0/0 trust" >> /etc/pgpool2/pool_hba.conf
#touch /usr/local/etc/passwd
#echo "hipchat:hipchat" >> /usr/local/etc/passwd
pg_md5 -u hipchat -m hipchat -f pgpool.conf


#echo "host all all 0.0.0.0/0 md5" /etc/pgpool2/pool_hba.conf
#echo "host hipchat hipchat 0.0.0.0/0 md5" /etc/pgpool2/pool_hba.conf
#echo "hipchat" | pg_md5 --username hipchat -m hipchat -p
#echo "hipchat:08b4beb3dbcb40739e1b3feff15fbe98" > /etc/pgpool2/pool_passwd
#echo "hipchat:hipchat" > /usr/local/etc/pool_passwd


echo '>>> STARTING SSH (if required)...'
source /home/postgres/.ssh/entrypoint.sh

echo '>>> TURNING PGPOOL...'
/usr/local/bin/pgpool/pgpool_setup.sh

echo '>>> STARTING PGPOOL...'
gosu postgres /usr/local/bin/pgpool/pgpool_start.sh