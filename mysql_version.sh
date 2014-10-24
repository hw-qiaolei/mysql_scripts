# -----------------------------------------------------------------------------
# Name          : mysql_version.sh
# Description   : get mysql version
# Author        : qiaolei
# Date          : 2014/10/13
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

LOG_FILE=/tmp/itchazuo_rdb.log
if [ ! -f $LOG_FILE ];then
  touch $LOG_FILE
fi

TIMESTAMP=`date +%Y%m%d%H%M%S`
echo "@$TIMESTAMP: {$0 $*}" | tee -a $LOG_FILE

USERNAME=$1
PASSWORD=$2

VERSION=`mysqladmin -u${USERNAME} -p${PASSWORD} version | grep "Server version" | awk '{print $3}'`

RESULT=`printf "%s%s%s%s" "$RESULT" "{\"version\": " "\"$VERSION\"" "}"`

echo $RESULT
