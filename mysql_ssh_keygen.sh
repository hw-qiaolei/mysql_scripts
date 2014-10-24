# -----------------------------------------------------------------------------
# Name		: mysql_ssh_keygen.sh
# Description	: generate a ssh private-public key pair
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

LOG_FILE=/tmp/itchazuo_rdb.log
if [ ! -f $LOG_FILE ];then
  touch $LOG_FILE
fi

TIMESTAMP=`date +%Y%m%d%H%M%S`
echo "@$TIMESTAMP: {$0 $*}" | tee -a $LOG_FILE

if [ ! -f ~/.ssh/id_dsa.pub ];then
  if [ -d ~/.ssh ];then
    mkdir -p ~/ssh-backup
    mv ~/.ssh/* ~/ssh-backup
  fi

  ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
fi

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

