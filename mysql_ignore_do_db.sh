# -----------------------------------------------------------------------------
# Name		: mysql_ignore_db.sh
# Description	: add a line "binlog-ignore-db=<database>" after server-id in /etc/my.cnf
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <database>"
}

if [ $# -ne 1 ]
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

DATABASE=$1
TMP_My_CNF=/tmp/my.cnf
sed "/server-id/a\binlog-ignore-db=$DATABASE" /etc/my.cnf >$TMP_My_CNF
mv -f $TMP_My_CNF /etc/my.cnf

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

