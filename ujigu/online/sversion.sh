#!/bin/bash

source /etc/profile

DIR=`dirname $0`
source $DIR/config.sh

function sversion(){
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

  APP_PROP_FILE="$WORK_DIR/WEB-INF/classes/application.properties"
  if [ -f "$APP_PROP_FILE" ];then
    TIMESTR=`date +%H%M%S`
    echo "sed -i s/static.resource.version=.*/static.resource.version=$TIMESTR/g $APP_PROP_FILE"
    sed -i s/static.resource.version=.*/static.resource.version=$TIMESTR/g $APP_PROP_FILE
  fi


  flushVersion $TOMCAT_HOME

}

checkEnv "$@"

PROJECTS=$1
shift
LEFT_PARAM=$@
for PROJECT_NAME in $PROJECTS
  do
    echo "sversion $PROJECT_NAME $LEFT_PARAM"
    sversion $PROJECT_NAME $LEFT_PARAM
  done

