# -----------------------------------------------------------------------------
# Name		: mysql_change_password.sh
# Description	: change mysql user's password
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <mysql_priv_user> <mysql_priv_password> <mysql_user> <new_password>"
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

MYSQL_USERMYSQL_USER=$1
if [ $MYSQL_PRIV_USER = "NULL" ];then
  MYSQL_PRIV_USER = "root"
fi

MYSQL_PRIV_PASSWORD=$2

MYSQL_USER=$3
if [ $MYSQL_USER = "NULL" ];then
  MYSQL_USER = "root"
fi

NEW_PASSWORD=$4
if [ $NEW_PASSWORD = "NULL" ];then
  NEW_PASSWORD = ""
fi

CMD_UPDATE="UPDATE mysql.user SET password=PASSWORD("$NEW_PASSWORD") WHERE user='$MYSQL_USER'"
CMD_FLUSH="FLUSH PRIVILEGES"

DEFAULT_REPL_USER="repl"
REPL=""
if [ ! $MYSQL_PRIV_PASSWORD = "NULL" ];then
  mysql -u $MYSQL_USERMYSQL_USER -p$MYSQL_PRIV_PASSWORD -e "$CMD_UPDATE"
  mysql -u $MYSQL_USERMYSQL_USER -p$MYSQL_PRIV_PASSWORD -e "$CMD_FLUSH"
else
  mysql -u $MYSQL_USERMYSQL_USER -e "$CMD_UPDATE"
  mysql -u $MYSQL_USERMYSQL_USER -e "$CMD_FLUSH"
fi

RC=$?
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

