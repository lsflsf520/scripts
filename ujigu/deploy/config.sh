#!/bin/bash

declare -A server_dic

function checkEnv(){
  EXEC_USER="deployer"
  SCRIPT_DIR=`dirname $0`
  #echo "SCRIPT_DIR: $SCRIPT_DIR"
  if [ -f $SCRIPT_DIR/exec_user ];then
    EXEC_USER=$(cat $SCRIPT_DIR/exec_user)
  fi
  if [ `whoami` != "$EXEC_USER" ];then
    echo "only can exec this script in user '$EXEC_USER'"
    exit 5
  fi

  if [ -z "$JAVA_HOME" ];then
    echo "JAVA_HOME has not set yet, then exit."
    exit 1
  fi

  if [ -z "$1" ]; then
    echo "Please define a project name,eg:"
    echo "  web-cms-admin web-cms"
    exit 4
  fi
  
  if [[ $1 =~ "-csaicms" ]]; then
     CODE_BASE="https://svn.domain.com/svn/csai.cms.java"
     WHITE_WEB="web-csaicms web-csaicms-admin"
     server_dic=(["web-csaicms"]="77" ["web-csaicms-admin"]="77")
  elif [[ $1 =~ "-card" ]]; then
     CODE_BASE="https://svn.domain.com/svn/creditcard.java"
     WHITE_WEB="web-card web-card-admin"
     server_dic=(["default"]="76")
  elif [[ $1 =~ "-p2p" ]]; then
     CODE_BASE="https://svn.domain.com/svn/p2p.v2"
     WHITE_WEB="web-p2p-admin web-p2p-market web-p2p-archive web-p2p-open"
     server_dic=(["default"]="76")
  elif [[ $1 =~ "-cms" ]]; then
     CODE_BASE="https://svn.domain.com/svn/xicaimao/cms"
     WHITE_WEB="web-cms-admin web-cms-bxadmin web-cms web-cms-api"
     server_dic=(["default"]="54")
  elif [[ $1 =~ "-upfile" ]] || [[ $1 =~ "-acl" ]]; then
     CODE_BASE="https://svn.domain.com/svn/commons"
     WHITE_WEB="web-upfile web-acl"
     server_dic=(["web-upfile"]="75" ["web-acl"]="76")
  else
     echo "not defined CODE_BASE variable for project name $1"
     exit 5 
  fi

  if [ -z "$1" ]; then
    echo "Please give a web prefix , available prefix are follow:"
    echo " $WHITE_WEB"
    echo "or"
    MULTI_WEB=""
    CNT=0
    for w in $WHITE_WEB
      do
        MULTI_WEB="$MULTI_WEB $w"
        let "CNT+=1"
        if [ $CNT -ge 3 ];then
          break;
        fi
      done
    echo " \"$MULTI_WEB\" to redeploy multi web projects"
    exit 1
  else
    for w in $1
     do
       if [[ !($WHITE_WEB =~ $w) ]];then
         echo "$w is not a white project of \"$WHITE_WEB\""
         exit 2
       fi
     done 
  fi
}

function compile(){
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
    let TMP_DIR=100
  else
    svn export $CODE_BASE/branches/$BCH_NAME $DIR_NAME
    let TMP_DIR=101
  fi

  if [ ! -d "/tmp/$TMP_DIR" ];then
    mkdir /tmp/$TMP_DIR
  fi

  cd $WORKSPACE/$DIR_NAME

  for PROJECT_NAME in $1
    do

      mvn clean package -pl $PROJECT_NAME -am -U -DskipTests=true

      if [ $? != 0 ];then
        echo "compile failure"
        exit 8
      fi

      if [ -f "/tmp/$TMP_DIR/${PROJECT_NAME}.war" ];then
        echo "rm -f /tmp/$TMP_DIR/${PROJECT_NAME}.war"
        rm -f /tmp/$TMP_DIR/${PROJECT_NAME}.war
      fi

      echo "cp $WORKSPACE/$DIR_NAME/${PROJECT_NAME}/target/${PROJECT_NAME}.war /tmp/$TMP_DIR"
      cp $WORKSPACE/$DIR_NAME/${PROJECT_NAME}/target/${PROJECT_NAME}.war /tmp/$TMP_DIR
    done

  rm -fr $WORKSPACE/$DIR_NAME
  return $(($TMP_DIR + 0))
}

function chkserv(){
  TOMCAT_HOME=$1
  PORT=`cat $TOMCAT_HOME/conf/server.xml | grep Connector | grep "HTTP/1.1" | grep "port=" | awk '{print $2}'`
  PORT=${PORT#*"\""}
  PORT=${PORT%"\""*}

  echo "curl http://127.0.0.1:$PORT/ping/pang.do"
  for i in {1..100}
    do
      RET=`curl http://127.0.0.1:$PORT/ping/pang.do`
      if [ "PONG" == "$RET" ];then
        echo "$TOMCAT_HOME has start success."
        return
      fi
      sleep 1
    done
  
  echo "$TOMCAT_HOME service cannot access so far, please check it later(curl http://127.0.0.1:$PORT/ping/pang.do). "
}

function flushVersion(){
  TOMCAT_HOME=$1
  PORT=`cat $TOMCAT_HOME/conf/server.xml | grep Connector | grep "HTTP/1.1" | grep "port=" | awk '{print $2}'`
  PORT=${PORT#*"\""}
  PORT=${PORT%"\""*}

  echo "curl http://127.0.0.1:$PORT/_mgr/reloadconfig.do"
  curl http://127.0.0.1:$PORT/_mgr/reloadconfig.do
}

function split(){
  if [ $# != 2 ];then
    echo "param length should be equal to 2"
    exit 1
  fi
  echo $1 | awk '{split($0, arr, $2); for(i in arr) print arr[i]}'
}

