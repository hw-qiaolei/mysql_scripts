# -----------------------------------------------------------------------------
# Name		: mysql_auto_backup.sh
# Description	: automatically backup the specified database
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <username> <password> <databases> <schedule>"
  echo "databases are seperated by comma(,), such as db1,db2,db3"
}

if [ $# -ne 4 ]
then
  usage
  exit 1
fi

LOG_FILE=/tmp/mysql_scripts.log
if [ ! -f $LOG_FILE ];then
  touch $LOG_FILE
fi

TIMESTAMP=`date +%Y%m%d%H%M%S`
echo "@$TIMESTAMP: {$0 $*}" | tee -a $LOG_FILE

USERNAME=$1
PASSWORD=$2
DATABASES=$3
SCHEDULE=$4

BACKUP_DIR=/var/lib/mysql/auto_backup
if [ ! -d $BACKUP_DIR ];then
  mkdir -p $BACKUP_DIR
fi

echo "$SCHEDULE  root  /usr/sbin/mysql_backup.sh $USERNAME $PASSWORD $DATABASES" >/etc/cron.d/mysql_auto_backup.cron

service crond status

if [ $? -eq 0 ];then
  # serivce crond is running
  service crond reload
else
  chkconfig --level 235 crond on
  service crond restart
fi

RC=$?

CODE=-1
MSG=""

if [ $RC -eq 0 ];then
  CODE=$RC
  MSG="OK"
else
  CODE=$RC
  MSG="KO"
fi

RESULT=`printf "%s%s%s%s%s%s%s" "{" "\"result\":" "\"$CODE\"" "," "\"msg\":" "\"$MSG\"" "}"`
echo $RESULT

