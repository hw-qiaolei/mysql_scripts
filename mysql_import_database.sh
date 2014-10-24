# -----------------------------------------------------------------------------
# Name		: mysql_import_database.sh
# Description	: import the specified database file into the specified database
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <username> <password> <database> <database-file>"
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
DATABASE_FILE=$4

echo "importing database file ${DATABASE_FILE} into ${DATABASE}..." | tee -a $LOG_FILE
if [ ! $PASSWORD = "NULL" ];then
  mysql -u $USERNAME -p$PASSWORD $DATABASE <${DATABASE_FILE}
else
  mysql -u $USERNAME $DATABASE <${DATABASE_FILE}
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

