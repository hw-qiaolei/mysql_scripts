# -----------------------------------------------------------------------------
# Name		: mysql_slave_cnf.sh
# Description	: add slave configuration in /etc/my.cnf
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

LOG_FILE=/tmp/mysql_scripts.log
if [ ! -f $LOG_FILE ];then
  touch $LOG_FILE
fi

TIMESTAMP=`date +%Y%m%d%H%M%S`
echo "@$TIMESTAMP: {$0 $*}" | tee -a $LOG_FILE

ID=$1
MY_CNF=/etc/my.cnf
TMP_MY_CNF=/tmp/my.cnf
TMP_MY_CNF_2=/tmp/my.cnf.2
SERVER_ID="server-id=$ID"
LOG_SLAVE_UPDATES="log-slave-updates"
LOG_BIN="log-bin=mysql-bin"
RELAY_LOG="relay-log=slave-relay-bin"
BINGLOG_FORMAT="binlog_format=mixed"

cp -p $MY_CNF /tmp/my.cnf-${TIMESTAMP}

sed "/server-id/d" $MY_CNF | sed "/log-slave-updates/d" | sed "/log-bin/d" | sed "/relay-log/d" | sed "/binlog_format/d" >$TMP_MY_CNF
cat $TMP_MY_CNF | sed "/\[mysqld\]/a ${SERVER_ID}\n${LOG_SLAVE_UPDATES}\n${LOG_BIN}\n${RELAY_LOG}\n${BINGLOG_FORMAT}" >$TMP_MY_CNF_2

mv -f $TMP_MY_CNF_2 $MY_CNF

rm -f $TMP_MY_CNF  $TMP_MY_CNF_2

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

