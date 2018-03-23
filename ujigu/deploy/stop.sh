#!/bin/bash

source /etc/profile

DIR=`dirname $0`
source $DIR/config.sh

function tomcatStop(){
  PROJECT_NAME=$1

  echo "checkEnv $@"
  checkEnv $@

  if [ $? != 0 ];then
   exit
  fi

  TIMEOUT=10
  if [ ! -z "$2" ];then
    TIMEOUT=$2
  fi

  TOMCAT_NAME=tomcat_$PROJECT_NAME
  TOMCAT_HOME=/data/servers/$TOMCAT_NAME

  CURRPID=`ps aux | grep "/$TOMCAT_NAME/" | grep java | awk '{print $2}'`
  if [ ! -z "$CURRPID" ];then
    echo "exec $TOMCAT_HOME/bin/shutdown.sh"
    $TOMCAT_HOME/bin/shutdown.sh

    echo "sleep 3 seconds ..."
    sleep 3

    #杀掉当前正在运行的tomcat进程
    CURRPID=`ps aux | grep "/$TOMCAT_NAME/" | grep java | awk '{print $2}'`
    if [ ! -z "$CURRPID" ];then
      echo "kill -9 $CURRPID"
      kill -9 $CURRPID
    fi
  fi

}

checkEnv "$@"

PROJECTS=$1
shift
LEFT_PARAM=$@
for PROJECT_NAME in $PROJECTS
  do
    echo "tomcatStop $PROJECT_NAME $LEFT_PARAM"
    tomcatStop $PROJECT_NAME $LEFT_PARAM
  done

