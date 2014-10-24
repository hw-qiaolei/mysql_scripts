# -----------------------------------------------------------------------------
# Name		: mysql_do_everything.sh
# Description	: execute a command in a specified mysql database
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <username> <password> <database> <command>"
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
DATABASE=$3
if [ $DATABASE = "NULL" ];then
  DATABASE=""
fi

CMD=$4

echo "executing in database{$DATABASE} with command{$CMD}..." | tee -a $LOG_FILE
if [ ! $PASSWORD = "NULL" ];then
  echo "$CMD" | mysql -u $USERNAME -p$PASSWORD $DATABASE
else
  echo "$CMD" | mysql -u $USERNAME $DATABASE
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

