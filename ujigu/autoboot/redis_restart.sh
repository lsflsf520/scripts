#!/bin/bash

REDIS_HOME=/usr/local/redis-3.2.8

CLI_PATH=$REDIS_HOME/bin/redis-cli
SERVER_PATH=$REDIS_HOME/bin/redis-server
CONF_FILE=$REDIS_HOME/conf/redis.conf

pidfile=$(cat $CONF_FILE | grep pidfile | awk '{print $2}')
if [ -f "$pidfile" ];then
   kill -9 `cat $pidfile` 
fi

$SERVER_PATH $CONF_FILE