#!/bin/bash

source /etc/profile

DIR=`dirname $0`
source $DIR/config.sh

function tomcatRestart(){
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
  CODE_HOME=/data/www/$PROJECT_NAME
  WORK_DIR=$CODE_HOME/ROOT
  CONF_DIR=$CODE_HOME/conf

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

  echo "cp -r $CONF_DIR/* $WORK_DIR/WEB-INF/classes"
  cp -r $CONF_DIR/* $WORK_DIR/WEB-INF/classes

  APP_PROP_FILE="$WORK_DIR/WEB-INF/classes/application.properties"
  if [ -f "$APP_PROP_FILE" ];then
    TIMESTR=`date +%H%M%S`
    echo "sed -i s/static.resource.version=.*/static.resource.version=$TIMESTR/g $APP_PROP_FILE"
    sed -i s/static.resource.version=.*/static.resource.version=$TIMESTR/g $APP_PROP_FILE
  fi

  $TOMCAT_HOME/bin/startup.sh  

  tail -fn5 $TOMCAT_HOME/logs/catalina.out & sleep $TIMEOUT ; eval 'kill -9 $!' &> /dev/null

  chkserv $TOMCAT_HOME

  echo "tail -fn100 $TOMCAT_HOME/logs/catalina.out"
}

checkEnv "$@"

PROJECTS=$1
shift
LEFT_PARAM=$@
for PROJECT_NAME in $PROJECTS
  do
    echo "tomcatRestart $PROJECT_NAME $LEFT_PARAM"
    tomcatRestart $PROJECT_NAME $LEFT_PARAM
  done

