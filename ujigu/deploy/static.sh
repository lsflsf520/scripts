#!/bin/bash

DIR=`dirname $0`
#source $DIR/config.sh

if [ `whoami` != "deployer" ];then
    echo "only can exec this script in user 'deployer'"
    exit 5
fi

WORKSPACE="/data/workspace"
SERV_DIR="/data/www/static/svn"

if [ ! -d "$WORKSPACE" ];then
  mkdir -p $WORKSPACE
fi

if [ -d "$WORKSPACE/static" ];then
  rm -fr $WORKSPACE/static
fi

svn co https://210.73.209.77:8443/svn/Insure.Open/doc/static $WORKSPACE/static

if [ -d "$SERV_DIR" ];then
  rm -fr $SERV_DIR/*
else
  mkdir -p $SERV_DIR
fi

cp -r $WORKSPACE/static/* $SERV_DIR

rm -fr  $WORKSPACE/static
