#!/bin/bash

ZK_HOME=/usr/local/software/zookeeper-3.4.6
ZK_NODES=127.0.0.1:2181
ZK_PATH=/csjy/redis/defaultgrp/r
WATCH_HOST=`ifconfig | grep "inet addr:" | grep "10" | cut -d: -f2 | awk '{print $1}'`
WATCH_PORT=6379
# get local ip 
#LC_ADDR=`ifconfig | grep "inet addr:" | grep "10" | cut -d: -f2 | awk '{print $1}'`

SERVICE_RESTART_SCRIPT=/home/deployer/scripts/redis_restart.sh

if [ ! -z "$1" ];then
  WATCH_HOST=$1
fi

if [ ! -z "$2" ];then
  WATCH_PORT=$2
fi

cd $ZK_HOME

SERV_PORT_CHK=`netstat -na | grep $WATCH_PORT | grep LISTEN | grep -v grep`
if [ -z "$SERV_PORT_CHK" ];then
 echo "port $WATCH_PORT is not exists. then will exec restart script $SERVICE_RESTART_SCRIPT." 
 $SERVICE_RESTART_SCRIPT $@
 exit $?
fi


function createIfNotExist(){
  NODE_PATH=$1
  if [ -z "$NODE_PATH" ];then
   echo "Please define a zk node path"
   exit 1
  fi
  
  DIR=`dirname $NODE_PATH`
  STD_OUT=`./bin/zkCli.sh stat $DIR 2>&1`
  echo "$STD_OUT" | grep -q "not exist"
  if [ $? -eq 0 ];then
    createIfNotExist $DIR
  else
    echo "./bin/zkCli.sh create $NODE_PATH ''"
    ./bin/zkCli.sh create $NODE_PATH ""
  fi

}

SERV_NODE_PATH=$ZK_PATH/$WATCH_HOST:$WATCH_PORT
createIfNotExist $SERV_NODE_PATH
val=`./bin/zkCli.sh get $SERV_NODE_PATH`

echo "$val" | grep -q "true"
if [ $? -ne 0 ];then
  echo "service on zk state is down, and will change it 'true'."
  ./bin/zkCli.sh set $SERV_NODE_PATH "true"
else
  echo "service work normally."
fi
 
