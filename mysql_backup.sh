# -----------------------------------------------------------------------------
# Name		: mysql_backup.sh
# Description	: backup the specified database
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

LOG_FILE=/tmp/mysql_scripts.log
if [ ! -f $LOG_FILE ];then
  touch $LOG_FILE
fi

TIMESTAMP=`date +%Y%m%d%H%M%S`
echo "@$TIMESTAMP: {$0 $*}" | tee -a $LOG_FILE

USERNAME=$1
PASSWORD=$2
DATABASES=($(echo $3 | tr ',' ' ' | tr -s ' ')) 
NUM_OF_DBS=${#DATABASES[@]}

BACKUP_DIR=/var/lib/mysql/auto_backup
if [ ! -d $BACKUP_DIR ];then
  mkdir -p $BACKUP_DIR
fi

for ((i=0;i<$NUM_OF_DBS;i++));do
  echo "backing up databse ${DATABASES[$i]}..." | tee -a $LOG_FILE
  if [ ! $PASSWORD = "NULL" ];then
    mysqldump -u $USERNAME -p$PASSWORD ${DATABASES[$i]} > ${BACKUP_DIR}/${DATABASES[$i]}-${TIMESTAMP}.sql
  else
     mysqldump -u $USERNAME ${DATABASES[$i]} > ${BACKUP_DIR}/${DATABASES[i]}-${TIMESTAMP}.sql
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

