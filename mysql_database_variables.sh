# -----------------------------------------------------------------------------
# Name          : mysql_database_variables.sh
# Description   : get all variables from mysql
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
echo "@$TIMESTAMP: {$0 $*}" | tee -a $LOG_FILE

USERNAME=$1
PASSWORD=$2

TMP_VARIABLES=/tmp/variables.tmp
if [ ! -f $TMP_VARIABLES ];then
  touch $TMP_VARIABLES
fi

if [ $PASSWORD != "NULL" ]; then
  mysqladmin -u $USERNAME -p$PASSWORD variables > $TMP_VARIABLES
else
  mysqladmin -u $USERNAME variables > $TMP_VARIABLES
fi

TMP_KEYS=/tmp/keys.tmp
cat $TMP_VARIABLES | sed '1,3d'| sed '$d' | tr -d "[|]" | awk '{print $1}' > $TMP_KEYS

TMP_VALUES=/tmp/values.tmp
cat $TMP_VARIABLES | sed '1,3d'| sed '$d' | tr -d "[|]" | awk '{print $2}' > $TMP_VALUES

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

rm -f $TMP_VARIABLES $TMP_KEYS $TMP_VALUES

# store key-value pair in a map
declare -A VARIABLES
NUM_OF_KEYS=${#KEYS[@]}
for ((i=0;i<$NUM_OF_KEYS;i++));do
  VARIABLES[${KEYS[$i]}]=${VALUES[$i]} 
done

# construct a jason string
RESULT=`printf "%s%s" "$RESULT" "{"`

for ((i=0;i<$NUM_OF_KEYS;i++));do
  RESULT=`printf "%s%s%s%s" "$RESULT" "\"${KEYS[$i]}\": \"" "${VARIABLES[${KEYS[$i]}]}" "\","`
#  echo "${KEYS[$i]}: ${VARIABLES[${KEYS[$i]}]}"
done

RESULT=${RESULT%%,}
RESULT=`printf "%s%s" "$RESULT" "}"`

echo $RESULT


