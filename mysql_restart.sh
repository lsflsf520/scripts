#!/bin/bash

MYSQL_PID=`ps aux | grep mysqld | grep -v grep | awk '{print $2}'`
if [ ! -z "$MYSQL_PID" ];then
  /etc/init.d/mysql stop  
  sleep 3
  MYSQL_PID=`ps aux | grep mysqld | grep -v grep | awk '{print $2}'`
  if [ ! -z "$MYSQL_PID" ];then
    kill -9 $MYSQL_PID
  fi
fi

/etc/init.d/mysql start

