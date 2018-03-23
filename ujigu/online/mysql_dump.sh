#!/bin/sh

# Database info
DB_USER="csai_admin"
DB_PASS="$c#s%i&2017"
DB_HOST="192.168.1.53"
DB_NAME="csaimall_insure_api_db"

# Others vars
BIN_DIR="/usr/bin"            #the mysql bin path
BCK_DIR="/data/scripts/bak/mysql"    #the backup file directory
DATE=`date +%F`

# TODO
# /usr/bin/mysqldump --opt -ubatsing -pbatsingpw -hlocalhost timepusher > /mnt/mysqlBackup/db_`date +%F`.sql
$BIN_DIR/mysqldump --opt -u$DB_USER -p$DB_PASS -h$DB_HOST $DB_NAME > $BCK_DIR/db_api_$DATE.sql


DB_USER="csai_agent"
DB_PASS="$a#g@tUE2017"
DB_HOST="192.168.1.53"
DB_NAME="csaimall_insure_db"

$BIN_DIR/mysqldump --opt -u$DB_USER -p$DB_PASS -h$DB_HOST $DB_NAME > $BCK_DIR/db_$DATE.sql
