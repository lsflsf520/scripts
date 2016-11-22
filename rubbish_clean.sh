#!/bin/bash


function cleanLog(){
  BASE_DIR=$1
  shift 
  for logDir in $@
    do
       rubbishDir="$BASE_DIR/$logDir"
       if [ -d "$rubbishDir" ];then
         for f in `ls -t $rubbishDir | awk '{if (NR > 10) print $0}'`
           do
            echo "rm -f $rubbishDir/$f"
            rm -f $rubbishDir/$f
          done
       else
         echo "$rubbishDir is not a directory"
       fi
    done
}


cleanLog /usr/local/apache tomcat-web-rpc-basedata/logs tomcat-web-teacher/logs tomcat-web-ms/logs tomcat-web-student/logs
cleanLog /home/deployer/bak web-student web-student web-teacher web-ms
cleanLog /usr/local/apache/logs xn oper sys error_report
