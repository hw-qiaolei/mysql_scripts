# -----------------------------------------------------------------------------
# Name          : mysql_get_value_by_key.sh
# Description   : get value from a json string by key
# Author        : qiaolei
# Date          : 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "usage: $0 <key> <json_string>"
}

if [ $# -ne 2 ];then
  usage
  exit 1
fi

LOG_FILE=/tmp/itchazuo_rdb.log
if [ ! -f $LOG_FILE ];then
  touch $LOG_FILE
fi

TIMESTAMP=`date +%Y%m%d%H%M%S`
echo "@$TIMESTAMP: {$0 $*}" >$LOG_FILE

KEY=$1
JSON_STRING=$2
VALUE=""

TMP_JSON_STRING=/tmp/json_string.tmp
echo $JSON_STRING >$TMP_JSON_STRING
VALUE=`/usr/sbin/rdb/JSON.sh <$TMP_JSON_STRING | grep "$KEY" | head -n 1 | awk '{print $2}'`
VALUE=${VALUE#\"}
VALUE=${VALUE%\"}

echo $VALUE

