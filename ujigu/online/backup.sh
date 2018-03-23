#!/bin/bash

source /etc/profile

BAK_SERV_IP=119.23.224.191
LOCAL_IP=`/sbin/ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | grep 192`

for d in "/data/www" "/data/scripts" "/usr/local/nginx/conf" "/data/servers"
  do
    if [ -d "$d" ];then
      /usr/bin/rsync -aurvz --exclude 'temp' --exclude 'work' --exclude 'bak' --exclude 'logs' --password-file=/etc/rsyncd.pass $d backup@$BAK_SERV_IP::bak/$LOCAL_IP
    fi
  done
