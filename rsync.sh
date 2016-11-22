#!/bin/bash
#ip=`ifconfig eth0|head -n2|tail -n1|awk '{print $2}'|awk -F: '{print $2}'`
while true   
  do
   rsync -auvztP --append --delete /usr/local/apache/logs/ deployer@10.163.106.210::`hostname`/  2>&1 >/dev/null
    sleep 3		
  done

