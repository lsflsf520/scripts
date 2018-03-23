#!/bin/bash

EXEC_USER="deployer"
SCRIPT_DIR=`dirname $0`
if [ -f $SCRIPT_DIR/exec_user ];then
  EXEC_USER=$(cat $SCRIPT_DIR/exec_user)
fi
if [ `whoami` != "$EXEC_USER" ];then
  echo "only can exec this script in user '$EXEC_USER'"
  exit 5
fi

DIR=`dirname $0`

WORKSPACE="/data/workspace"
DIR_NAME="commons"

cd $WORKSPACE
if [ -d "$DIR_NAME" ];then
  rm -fr $DIR_NAME
fi

CODE_BASE=https://210.73.209.77:8443/svn/commons
svn export $CODE_BASE/trunk $DIR_NAME

cd $WORKSPACE/$DIR_NAME/common-tools
mvn clean deploy -DskipTests=true
if [ $? != 0 ];then
  echo "compile failure"
  exit 7
fi

cd $WORKSPACE/$DIR_NAME/common-acl-intf
mvn clean deploy -DskipTests=true
if [ $? != 0 ];then
  echo "compile failure"
  exit 7
fi

cd $WORKSPACE/$DIR_NAME/common-shareintf
mvn clean deploy -DskipTests=true
if [ $? != 0 ];then
  echo "compile failure"
  exit 7
fi

rm -fr $WORKSPACE/$DIR_NAME
