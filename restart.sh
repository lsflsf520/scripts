#!/bin/bash

source /etc/profile

PROJECT_NAME=$1
if [ -z "$1" ]; then
  echo "Please give a web prefix , available prefix are follow:"
  echo " web-teacher、web-ms、web-rpc-basedata、web-student "
  exit 1
fi

TIMEOUT=60
if [ ! -z "$2" ];then
  TIMEOUT=$2
fi

WAR_NAME=${PROJECT_NAME}.war
NEW_FILE=/tmp/$WAR_NAME
TOMCAT_HOME=/usr/local/apache/tomcat-$PROJECT_NAME
WORK_DIR=$TOMCAT_HOME/webapps/$PROJECT_NAME
BAK_DIR=~/bak/$PROJECT_NAME
CONF_DIR=~/deployConfig/$PROJECT_NAME

if [ ! -d "$TOMCAT_HOME"  ];then
  echo "$TOMCAT_HOME is not exists, then exit."
  exit 1
fi

if [ -z "$JAVA_HOME" ];then
  echo "JAVA_HOME has not set yet, then exit."
  exit 1
fi

if [ ! -d "$WORK_DIR" ];then
  echo "$WORK_DIR not exists, then create it."
  mkdir -p $WORK_DIR
fi

if [ -f $NEW_FILE ];then
  CURRPID=`ps aux | grep "/tomcat-${PROJECT_NAME}/" | grep java | awk '{print $2}'`
  if [ ! -z "$CURRPID" ];then
    echo "exec $TOMCAT_HOME/bin/shutdown.sh"
    $TOMCAT_HOME/bin/shutdown.sh
  
    echo "sleep 3 seconds ..."
    sleep 3

    #杀掉当前正在运行的tomcat进程
    CURRPID=`ps aux | grep "/tomcat-${PROJECT_NAME}/" | grep java | awk '{print $2}'`
    if [ ! -z "$CURRPID" ];then
      echo "kill -9 $CURRPID"
      kill -9 $CURRPID
    fi
  fi

  echo "found $NEW_FILE , then begin redeploy it in $WORK_DIR"
  cd $WORK_DIR

  if [ -d "$WORK_DIR/WEB-INF" ];then
    DATESTR=`date +%Y%m%d_%H%M`
    echo "$JAVA_HOME/bin/jar -cf $WAR_NAME *"
    $JAVA_HOME/bin/jar -cf $WAR_NAME *

    if [ ! -d $BAK_DIR ];then
      echo "mkdir -p $BAK_DIR"
      mkdir -p $BAK_DIR
    fi 

    echo "mv $WORK_DIR/${WAR_NAME} $BAK_DIR/${WAR_NAME}_${DATESTR}"
    mv -f $WORK_DIR/${WAR_NAME} $BAK_DIR/${WAR_NAME}_${DATESTR}
  fi

  echo "rm -fr $WORK_DIR/*"
  rm -fr $WORK_DIR/*

  if [ -d $TOMCAT_HOME/work ];then
    echo "rm -fr $TOMCAT_HOME/work/*"
    rm -fr $TOMCAT_HOME/work/*
  fi

  echo "cp $NEW_FILE $WORK_DIR"
  cp $NEW_FILE $WORK_DIR

  echo "$JAVA_HOME/bin/jar -xf $NEW_FILE && rm -f $WORK_DIR/$WAR_NAME"
  $JAVA_HOME/bin/jar -xf $NEW_FILE && rm -f $WORK_DIR/$WAR_NAME

  echo "cp -r $CONF_DIR/* $WORK_DIR/WEB-INF/classes"
  cp -r $CONF_DIR/* $WORK_DIR/WEB-INF/classes
 
  echo "exec $TOMCAT_HOME/bin/startup.sh"
  $TOMCAT_HOME/bin/startup.sh  

  #echo "sleep 15 seconds to check the catalina.out"
  #sleep 15

  echo "tail -n300 $TOMCAT_HOME/logs/catalina.out"
  tail -fn5 $TOMCAT_HOME/logs/catalina.out & sleep $TIMEOUT ; eval 'kill -9 $!' &> /dev/null
else
  echo "$NEW_FILE has not found, then exit."
  exit 1
fi


