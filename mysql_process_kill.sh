# -----------------------------------------------------------------------------
# Name		: mysql_process_kill.sh
# Description	: kill process
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <username> <password> <id>"
}

if [ $# -ne 3 ]
then
  usage
  exit 1
fi

LOG_FILE=/tmp/itchazuo_rdb.log
if [ ! -f $LOG_FILE ];then
  touch $LOG_FILE
fi

TIMESTAMP=`date +%Y%m%d%H%M%S`
echo "@$TIMESTAMP: {$0 $*}" | tee -a $LOG_FILE

USERNAME=$1
PASSWORD=$2
ID=$3

if [ ! $PASSWORD = "NULL" ];then
  mysqladmin -u $USERNAME -p$PASSWORD kill $ID
else
  mysqladmin -u $USERNAME kill $ID
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

