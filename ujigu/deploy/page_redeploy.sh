#!/bin/bash

DIR=`dirname $0`
source $DIR/config.sh

BCH_NAME=""
if [ "-b" == "$1" ];then
  if [ $# -lt 3 ];then
    echo "param illegal"
    echo "for example"
    echo " -b branchName web-p2p-admin"
    echo "or "
    echo " -b branchName 'web-p2p-admin web-p2p-open'"
    exit 10
  else
    BCH_NAME=$2
    shift
    shift
  fi
fi

checkEnv $@
if [ $? != 0 ];then
  exit 2
fi

WORKSPACE="/data/workspace"

DIR_NAME=`basename $CODE_BASE`

cd $WORKSPACE
if [ -d "$DIR_NAME" ];then
  rm -fr $DIR_NAME
fi

if [ -z "$BCH_NAME" ];then
  svn export $CODE_BASE/trunk $DIR_NAME
  TMP_DIR=100
else
  svn export $CODE_BASE/branches/$BCH_NAME $DIR_NAME
  TMP_DIR=101
fi

cd $WORKSPACE/$DIR_NAME

for PROJECT_NAME in $1
  do
    CODE_PROJECT_DIR=$WORKSPACE/$DIR_NAME/${PROJECT_NAME}
    WORK_DIR=/data/www/${PROJECT_NAME}/ROOT
    PROJ_TMP_DIR=/tmp/$TMP_DIR/page_${PROJECT_NAME}
   
    if [ ! -d "$PROJ_TMP_DIR" ];then
      mkdir -p $PROJ_TMP_DIR
    fi

    if [ ! -d "$PROJ_TMP_DIR/WEB-INF" ];then
      mkdir $PROJ_TMP_DIR/WEB-INF
    fi
 
    echo "cp -r $CODE_PROJECT_DIR/src/main/webapp/static $PROJ_TMP_DIR/"
    cp -r $CODE_PROJECT_DIR/src/main/webapp/static $PROJ_TMP_DIR/

    echo "cp -r $CODE_PROJECT_DIR/src/main/webapp/WEB-INF/ftl $PROJ_TMP_DIR/WEB-INF/"
    cp -r $CODE_PROJECT_DIR/src/main/webapp/WEB-INF/ftl $PROJ_TMP_DIR/WEB-INF/


    echo "cp -r $PROJ_TMP_DIR/* $WORK_DIR/"
    cp -r $PROJ_TMP_DIR/* $WORK_DIR/

  done

#rm -fr $WORKSPACE/$DIR_NAME
