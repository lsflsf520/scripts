#!/bin/bash

REDIS_HOME=/usr/local/software/redis-stable
WATCH_SCRIPT=/home/deployer/scripts/watch_redis_on_zk.sh
HOST=`ifconfig | grep "inet addr:" | grep "192.168" | cut -d: -f2 | awk '{print $1}'`
PORT=6379
if [ ! -z "$1" ];then
  HOST=$1
fi

if [ ! -z "$2" ];then
  PORT=$2
fi

cd $REDIS_HOME

PID=`ps aux |grep redis-server | grep $PORT | grep -v grep | awk '{print $2}'`
if [ ! -z "$PID" ];then
  echo "./bin/redis-cli -p $PORT shutdown"
  ./bin/redis-cli -p $PORT shutdown
  sleep 2
  PID=`ps aux |grep redis-server | grep $PORT | grep -v grep | awk '{print $2}'`
  if [ ! -z "$PID" ];then
   kill -9 $PID
  fi
fi

echo "./bin/redis-server $REDIS_HOME/conf/redis_$PORT.conf"
./bin/redis-server $REDIS_HOME/conf/redis_$PORT.conf

sleep 1
PID=`ps aux |grep redis-server | grep $PORT | grep -v grep | awk '{print $2}'`
if [ ! -z "$PID" ];then
  echo "redis started success on port $PORT and start watch zk state"
  
  $WATCH_SCRIPT $HOST $PORT
else
  echo "check redis status unnormal, please check it yourself with command 'netstat -na | grep $PORT'"
  exit 1
fi


