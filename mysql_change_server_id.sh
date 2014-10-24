# -----------------------------------------------------------------------------
# Name		: mysql_change_server_id.sh
# Description	: change the value of server-id in /etc/my.cnf
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <server-id>"
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

ID=$1
TMP_My_CNF=/tmp/my.cnf
sed "s/server-id=[2-9]/server-id=$ID/g" /etc/my.cnf >$TMP_My_CNF
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

