# -----------------------------------------------------------------------------
# Name		: mysql_change_master.sh
# Description	: on slave change master
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <username> <password> <master_host> <master_user> <master_password> <master_log_file> <master_log_pos>"
}

if [ $# -ne 7 ]
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
MASTER_HOST=$3
MASTER_USER=$4
if [ $MASTER_USER = "NULL" ];then
  MASTER_USER ="repl"
fi

MASTER_PASSWORD=$5
if [ $MASTER_PASSWORD = "NULL" ];then
  MASTER_PASSWORD="slavepass"
fi

MASTER_LOG_FILE=$6
if [ $MASTER_LOG_FILE = "NULL" ];then
  MASTER_LOG_FILE="mysql-bin.000001"
fi

MASTER_LOG_POS=$7
if [ $MASTER_LOG_POS = "NULL" ];then
  MASTER_LOG_POS = "0"
fi

CMD="CHANGE MASTER TO MASTER_HOST='${MASTER_HOST}',MASTER_USER='${MASTER_USER}',MASTER_PASSWORD='${MASTER_PASSWORD}',MASTER_LOG_FILE='${MASTER_LOG_FILE}',MASTER_LOG_POS=${MASTER_LOG_POS}"

CMD_RESULT=""
echo "executing in database{$DATABASE} with command{$CMD}..." | tee -a $LOG_FILE
if [ ! $PASSWORD = "NULL" ];then
  CMD_RESULT=`mysql -u $USERNAME -p$PASSWORD $DATABASE -e "$CMD"`
else
  CMD_RESULT=`mysql -u $USERNAME $DATABASE -e "$CMD"`
fi

CODE=$?
MSG=$CMD_RESULT

RESULT=`printf "%s%s%s%s%s%s%s" "{" "\"result\":" "\"$CODE\"" "," "\"msg\":" "\"$MSG\"" "}"`
echo $RESULT

