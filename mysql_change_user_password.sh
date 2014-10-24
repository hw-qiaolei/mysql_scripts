# -----------------------------------------------------------------------------
# Name          : mysql_change_user_password.sh
# Description   : change user password in mysql database
# Author        : qiaolei
# Date          : 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <username> <old_password or NULL> <new_password>"
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
OLD_PASSWORD=$2
NEW_PASSWORD=$3

if [ $OLD_PASSWORD != "NULL" ];then
  /usr/bin/mysqladmin -u $USERNAME -p$OLD_PASSWORD password $NEW_PASSWORD
else
  /usr/bin/mysqladmin -u $USERNAME password $NEW_PASSWORD
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

