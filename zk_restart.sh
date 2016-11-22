#!/bin/bash

ZK_HOME=/usr/local/software/zookeeper-3.4.6

cd $ZK_HOME
ZK_PID=`ps aux | grep QuorumPeerMain | grep zookeeper | awk '{print $2}'`
if [ ! -z "$ZK_PID" ];then
  echo "zookeeper is running, then stop it."
  ./bin/zkServer.sh stop

  sleep 1
  ZK_PID=`ps aux | grep QuorumPeerMain | grep zookeeper | awk '{print $2}'`
  if [ ! -z "$ZK_PID" ];then
    kill -9 $ZK_PID
  fi

fi

echo "begin to start zookeeper"
./bin/zkServer.sh start

sleep 2

ZK_PID=`ps aux | grep QuorumPeerMain | grep zookeeper | awk '{print $2}'`
if [ -z "$ZK_PID" ];then
  echo "not found zookeeper process after 2 seconds, please check it your self"
else
  echo "zookeeper start success."
fi

