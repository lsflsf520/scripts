#!/bin/sh
home_dir="/home/deployer"
clear_dir="/usr/local/apache/logs"

if [ ! -d "$clear_dir"  ];then
  echo "$clear_dir is not exists, then exit."
  break
 else
  find $clear_dir  -depth  -type f  -name '*.log'  -mtime +2 -exec rm -rf {} \;
  #find $previewWord_dir  -depth  -type f  -name '*.docx'  -mtime +7 -exec rm -rf {} \;
  #find $previewWord_dir  -depth  -type f  -name '*.html'  -mtime +7 -exec rm -rf {} \;
  echo "$clear_dir,cleanup has been completed!"
fi
echo "clear done" `date +%Y%m%d-%T` >> $home_dir/scripts/clear_data.log
