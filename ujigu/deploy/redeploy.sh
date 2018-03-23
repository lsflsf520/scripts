#!/bin/bash

source /etc/profile

DIR=`dirname $0`
source $DIR/config.sh

function redeploy(){
  WAR_DIR=$1
  shift
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

  WAR_NAME=${PROJECT_NAME}.war
  NEW_FILE=$WAR_DIR/$WAR_NAME
  TOMCAT_NAME=tomcat_$PROJECT_NAME
  TOMCAT_HOME=/data/servers/$TOMCAT_NAME
  CODE_HOME=/data/www/$PROJECT_NAME
  WORK_DIR=$CODE_HOME/ROOT
  BAK_DIR=/data/scripts/bak/$PROJECT_NAME
  CONF_DIR=$CODE_HOME/conf

  if [ ! -d "$TOMCAT_HOME"  ];then
    echo "$TOMCAT_HOME is not exists, then exit."
    exit 1
  fi

  if [ ! -d "$WORK_DIR" ];then
    echo "$WORK_DIR not exists, then create it."
    mkdir -p $WORK_DIR
  fi

  if [ -f $NEW_FILE ];then
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

    APP_PROP_FILE="$WORK_DIR/WEB-INF/classes/application.properties"
    if [ -f "$APP_PROP_FILE" ];then
      TIMESTR=`date +%H%M%S`
      echo "sed -i s/static.resource.version=.*/static.resource.version=$TIMESTR/g $APP_PROP_FILE"
      sed -i s/static.resource.version=.*/static.resource.version=$TIMESTR/g $APP_PROP_FILE
    fi
 
    echo "exec $TOMCAT_HOME/bin/startup.sh"
    $TOMCAT_HOME/bin/startup.sh  

    tail -fn5 $TOMCAT_HOME/logs/catalina.out & sleep $TIMEOUT ; eval 'kill -9 $!' &> /dev/null
    
    chkserv $TOMCAT_HOME

    echo "tail -fn100 $TOMCAT_HOME/logs/catalina.out"
  else
    echo "$NEW_FILE has not found, then exit."
    exit 1
  fi
}

compile "$@"
WAR_DIR="/tmp/$?"
echo "$WAR_DIR"
if [ $WAR_DIR != "/tmp/100" -a $WAR_DIR != "/tmp/101" ];then
  echo "compile failure, then exit"
  exit 7
fi

if [ "-b" == "$1" ];then
  shift
  shift
fi

PROJECTS=$1
shift
LEFT_PARAM=$@
for PROJECT_NAME in $PROJECTS
  do
    echo "redeploy $WAR_DIR $PROJECT_NAME $LEFT_PARAM"
    redeploy $WAR_DIR $PROJECT_NAME $LEFT_PARAM
  done

