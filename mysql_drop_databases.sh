# -----------------------------------------------------------------------------
# Name		: mysql_drop_databases.sh
# Description	: drop mysql databases
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <username> <password> <databases>"
  echo "databases are seperated by comma(,), such as db1,db2,db3"
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
DATABASES=($(echo $3 | tr ',' ' ' | tr -s ' '))
NUM_OF_DBS=${#DATABASES[@]}

for ((i=0;i<$NUM_OF_DBS;i++));do
  echo "dropping database ${DATABASES[$i]}..." | tee -a $LOG_FILE
  if [ ! $PASSWORD = "NULL" ];then
    mysqladmin -f -u $USERNAME -p$PASSWORD drop ${DATABASES[$i]}
  else
    mysqladmin -f -u $USERNAME drop ${DATABASES[$i]}
  fi
done

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

