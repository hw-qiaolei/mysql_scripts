# -----------------------------------------------------------------------------
# Name		: mysql_databases.sh
# Description	: dump the specified databases,except information_schema,performance_schema
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <mysql_user> <mysql_password> <databases>"
  echo "databases are seperated by comma(,), such as db1,db2,db3. NULL will dump all databases."
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
echo "@$TIMESTAMP: {$0 $*}" >$LOG_FILE

USERNAME=$1
PASSWORD=$2
DATABASES=$3
declare -a DATABASE_ARRAY

if [ $DATABASES != "NULL" ];then
  DATABASE_ARRAY=($(echo $3 | tr ',' ' ' | tr -s ' ')) 
else
  DATABASES=""
  TMP_DATABASES=/tmp/databases.tmp
  if [ ! -f $TMP_DATABASES ];then
    touch $TMP_DATABASES
  fi

  mysql -u root -e "show databases" > $TMP_DATABASES

  DBS=`cat $TMP_DATABASES | sed '1d'| tr -d "[|]" | awk '{print $1}' | grep -v "information_schema" | grep -v "performance_schema"`
   
  for i in $DBS;do
    DATABASES=`printf "%s%s%s" "$DATABASES" "," "$i"`
  done
  
  DATABASES=${DATABASES#,}   
  DATABASE_ARRAY=(${DATABASES//,/ })
fi

NUM_OF_DBS=${#DATABASE_ARRAY[@]}

BACKUP_DIR=/tmp
if [ ! -d $BACKUP_DIR ];then
  mkdir -p $BACKUP_DIR
fi

echo "flushing tables with read lock..." >$LOG_FILE
if [ ! $PASSWORD = "NULL" ];then
  mysql -u $USERNAME -p$PASSWORD -e "flush tables with read lock"
else
  mysql -u $USERNAME -e "flush tables with read lock"
fi

DUMPS=""
for ((i=0;i<$NUM_OF_DBS;i++));do
  echo "dumping database ${DATABASE_ARRAY[$i]}..." >$LOG_FILE
  if [ ! $PASSWORD = "NULL" ];then
    mysqldump -u $USERNAME -p$PASSWORD ${DATABASE_ARRAY[$i]} > ${BACKUP_DIR}/${DATABASE_ARRAY[$i]}-${TIMESTAMP}.sql
  else
     mysqldump -u $USERNAME ${DATABASE_ARRAY[$i]} > ${BACKUP_DIR}/${DATABASE_ARRAY[i]}-${TIMESTAMP}.sql
  fi  
  DUMPS=`printf "%s%s%s" "$DUMPS" "," "${BACKUP_DIR}/${DATABASE_ARRAY[i]}-${TIMESTAMP}.sql"`
done

DUMPS=${DUMPS#*,}

echo "unlocking tables..." >$LOG_FILE
if [ ! $PASSWORD = "NULL" ];then
  mysql -u $USERNAME -p$PASSWORD -e "unlock tables"
else
  mysql -u $USERNAME -e "unlock tables"
fi

RESULT=`printf "%s%s%s%s" "{" "\"dumped_files\": " "\"$DUMPS\"" "}"`
echo $RESULT

