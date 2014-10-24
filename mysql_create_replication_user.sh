# -----------------------------------------------------------------------------
# Name		: mysql_create_replication_user.sh
# Description	: create a replication user
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <username> <password> <replication_user> <replication_password> <scope>"
}

if [ $# -ne 5 ]
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

REPLICATION_USER=$3
if [ $REPLICATION_USER = "NULL" ];then
  REPLICATION_USER ="repl"
fi

REPLICATION_PASSWORD=$4
if [ $REPLICATION_PASSWORD = "NULL" ];then
  REPLICATION_PASSWORD ="slavepass"
fi

SCOPE=$5
if [ $SCOPE = "NULL" ];then
  SCOPE ="%"
fi

CMD_CREATE="create user '$REPLICATION_USER'@'$SCOPE' identified by '$REPLICATION_PASSWORD'"
CMD_GRANT="grant replication slave on *.* to '$REPLICATION_USER'@'$SCOPE'"
CMD_FLUSH="flush privileges"

DEFAULT_REPL_USER="repl"
REPL=""
if [ ! $PASSWORD = "NULL" ];then
  REPL=`mysql -u $USERNAME -p$PASSWORD -e "select User,Host from mysql.user where User='$DEFAULT_REPL_USER'"`
else
  REPL=`mysql -u $USERNAME -e "select User,Host from mysql.user where User='$DEFAULT_REPL_USER'"`
fi

echo $REPL | grep "$DEFAULT_REPL_USER"
RC=$?

if [ $RC -ne 0 ];then
  # user 'repl' does not exist
  if [ ! $PASSWORD = "NULL" ];then
    mysql -u $USERNAME -p$PASSWORD -e "$CMD_FLUSH"
    mysql -u $USERNAME -p$PASSWORD -e "$CMD_CREATE"
    echo "$CMD_GRANT" | mysql -u $USERNAME -p$PASSWORD
    mysql -u $USERNAME -p$PASSWORD -e "$CMD_FLUSH"
  else
    mysql -u $USERNAME -e "$CMD_FLUSH"
    mysql -u $USERNAME -e "$CMD_CREATE"
    echo "$CMD_GRANT" | mysql -u $USERNAME
    mysql -u $USERNAME -e "$CMD_FLUSH"
  fi
fi

CODE=$?
MSG=$CMD_RESULT

RESULT=`printf "%s%s%s%s%s%s%s" "{" "\"result\":" "\"$CODE\"" "," "\"msg\":" "\"$MSG\"" "}"`
echo $RESULT

