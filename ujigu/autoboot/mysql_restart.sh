#!/bin/bash

MYSQL_HOME=/usr/local/mysql

MYSQLD_PATH=$MYSQL_HOME/bin/mysqld
CONF_FILE=/etc/my.cnf

pidfile=$(cat $CONF_FILE | grep pid-file | awk -F'=' '{print $2}')
if [ -f $pidfile ];then
   CURR_PID=`cat $pidfile`
   echo "kill -s QUIT $CURR_PID"
   kill -s QUIT $CURR_PID

   sleep 5
   if [ -f "$pidfile" ];then
     echo "kill -9 $CURR_PID"
     kill -9 $CURR_PID
   fi
fi

$MYSQLD_PATH --user=mysql &
