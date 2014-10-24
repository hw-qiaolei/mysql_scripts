# -----------------------------------------------------------------------------
# Name          : mysql_master_status.sh
# Description   : show master status
# Author        : qiaolei
# Date          : 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "usage: $0 <username> <password>"
}

if [ $# -ne 2 ];then
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

TMP_SHOW_MASTER_STATUS=/tmp/show_master_status.tmp
if [ ! -f $TMP_SHOW_MASTER_STATUS ];then
  touch $TMP_SHOW_MASTER_STATUS
fi

if [ $PASSWORD != "NULL" ]; then
  mysql -u $USERNAME -p$PASSWORD -e "show master status\G" >$TMP_SHOW_MASTER_STATUS
else
  mysql -u $USERNAME -e "show master status\G" >$TMP_SHOW_MASTER_STATUS
fi

TMP_KEYS=/tmp/keys.tmp
cat $TMP_SHOW_MASTER_STATUS | sed '1d'| sed '$d' | tr -d "[|]" | awk '{print $1}' > $TMP_KEYS

TMP_VALUES=/tmp/values.tmp
cat $TMP_SHOW_MASTER_STATUS | sed '1d'| sed '$d' | tr -d "[|]" | awk '{print $2}' > $TMP_VALUES

# keys
declare -a KEYS
i=0
while read LINE
do
  KEYS[$i]=${LINE%%:}
  i=`expr $i + 1`
done < $TMP_KEYS

#values
declare -a VALUES
i=0
while read LINE
do
  VALUES[$i]=$LINE
  i=`expr $i + 1`
done < $TMP_VALUES

rm -f $TMP_SHOW_MASTER_STATUS $TMP_KEYS $TMP_VALUES

# store key-value pair in a map
declare -A KVPS
NUM_OF_KEYS=${#KEYS[@]}
for ((i=0;i<$NUM_OF_KEYS;i++));do
  KVPS[${KEYS[$i]}]=${VALUES[$i]} 
done

# construct a jason string
RESULT=`printf "%s%s" "$RESULT" "{"`

for ((i=0;i<$NUM_OF_KEYS;i++));do
  RESULT=`printf "%s%s%s%s" "$RESULT" "\"${KEYS[$i]}\": \"" "${KVPS[${KEYS[$i]}]}" "\","`
done

RESULT=${RESULT%%,}
RESULT=`printf "%s%s" "$RESULT" "}"`

echo $RESULT


