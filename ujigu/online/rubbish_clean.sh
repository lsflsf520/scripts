#!/bin/sh
home_dir=`dirname $0`
rubbish_dir="/data/logs /data/scripts/bak"
tomcat_log_dir="/data/servers/*/logs"

for DIR in $rubbish_dir $tomcat_log_dir
  do
    if [ -d "$DIR" ];then
      find $DIR  -depth  -type f  -name '*.log'  -mtime +10 -exec rm -rf {} \;
      find $DIR  -depth  -type f  -name '*.txt'  -mtime +10 -exec rm -rf {} \;
      find $DIR  -depth  -type f  -name '*.war_*'  -mtime +10 -exec rm -rf {} \;
      
      echo "$DIR cleanup has been completed!"
    fi
  done

for STDOUT_LOG in `find $tomcat_log_dir -type f | grep "catalina.out"`
  do
    cat /dev/null > $STDOUT_LOG
  done

echo "clean done" `date +%Y%m%d-%T` >> $home_dir/bak/rubbish_clean_data.log
