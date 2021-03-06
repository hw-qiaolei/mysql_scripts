# -----------------------------------------------------------------------------
# Name		: mysql_master_cnf.sh
# Description	: add master configuration in /etc/my.cnf
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
LOG_BIN="log-bin=mysql-bin"
BINGLOG_FORMAT="binlog_format=ROW"
FLUSH_AT_COMMIT="innodb_flush_log_at_trx_commit=1"  
SYNC_BINLOG="sync_binlog=1"
IGNORE_DB_MYSQL="binlog_ignore_db=mysql"
IGNORE_DB_TEST="binlog_ignore_db=test"
IGNORE_DB_INFORMATION="binlog_ignore_db=information_schema"
IGNORE_DB_PERFORMANCE="binlog_ignore_db=performance_schema"

cp -p $MY_CNF /tmp/my.cnf-${TIMESTAMP}

sed "/server-id/d" $MY_CNF | sed "/log-bin/d" | sed "/binlog_format/d" | sed "/innodb_flush_log_at_trx_commit/d" | sed "/sync_binlog/d" | sed "/binlog-ignore-db/d" >$TMP_MY_CNF
cat $TMP_MY_CNF | sed "/\[mysqld\]/a ${SERVER_ID}\n${LOG_BIN}\n${BINGLOG_FORMAT}\n${FLUSH_AT_COMMIT}\n${SYNC_BINLOG}\n${IGNORE_DB_MYSQL}\n${IGNORE_DB_TEST}\n${IGNORE_DB_INFORMATION}\n${IGNORE_DB_PERFORMANCE}" >$TMP_MY_CNF_2

mv -f $TMP_MY_CNF_2 $MY_CNF

rm -f $TMP_MY_CNF

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

