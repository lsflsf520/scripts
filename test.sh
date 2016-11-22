#!/bin/bash
url=`cat url`
for i in $url
 do
  #wget -nd -b  --directory-prefix=./tmp  $i > /dev/null 2>&1
  webbench -r  -c 20 -t 60 $i &
  sleep 3
done
