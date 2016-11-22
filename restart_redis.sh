#!/bin/bash
d=`date +%Y%m%d-%T`
redis_pc=`ps -ef |grep -w  redis-server|grep -v grep|wc -l`
redis_pid=`ps -ef |grep -w  redis-server|grep -v grep|awk '{print $2}'`
redis_dir='/usr/local/software/redis-stable'
cd $redis_dir
if [ $redis_pc -ge 1 ];then
  for i in $redis_pid
   do
     /usr/bin/kill -9 $i
    sleep 0.5
   done
echo "$d redis server stop!"
./bin/redis-server ./conf/redis_6379.conf
sleep 0.5
 if [ $redis_pc -ge 1 ];then
   echo "$d redis server start!"
 else
  echo "$d redis server start failed!"
 fi

else
echo "$d redis server is not runing!"
./bin/redis-server ./conf/redis_6379.conf
sleep 0.5
echo "$d redis server start!"
fi
