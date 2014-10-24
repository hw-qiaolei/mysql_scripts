# -----------------------------------------------------------------------------
# Name		: mysql_get_databases.sh
# Description	: get all mysql databases except information_schema,performance_schema
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <username> <password>"
}

if [ $# -ne 2 ]
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

DATABASES=""
TMP_DATABASES=/tmp/databases.tmp
if [ ! -f $TMP_DATABASES ];then
  touch $TMP_DATABASES
fi

if [ ! $PASSWORD = "NULL" ];then
  mysql -u $USERNAME -p$PASSWORD -e "show databases" > $TMP_DATABASES
else
  mysql -u root -e "show databases" > $TMP_DATABASES
fi

DBS=`cat $TMP_DATABASES | sed '1d'| tr -d "[|]" | awk '{print $1}' | grep -v "information_schema" | grep -v "performance_schema"`
for i in $DBS;do
  DATABASES=`printf "%s%s%s" "$DATABASES" "," "$i"`
done

DATABASES=${DATABASES#,} 

rm -f $TMP_DATABASES

RESULT=`printf "%s%s%s%s" "{" "\"databases\": " "\"$DATABASES\"" "}"`
echo $RESULT

