# -----------------------------------------------------------------------------
# Name          : mysql_database_status.sh
# Description   : get mysql database status
# Author        : qiaolei
# Date          : 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

# 返回值格式：
# {
#     "ping": "mysqld is alive",
#     "status": {
#             "uptime": "97113",
#             "threads": "1",
#             "questions": "36",
#             "slowQueries": "0",
#             "opens": "15",
#             "flushTables": "1",
#             "openTables": "8", 
#             "queriesPerSecondAvg": "0.0", 
#     }
# }

usage()
{
  echo "Usage: $0 <username> <password>"
}

if [ $# -ne 2 ]
then
  usage
  exit 1
fi

USERNAME=$1
PASSWORD=$2

if [ $PASSWORD != NULL ];then
  PING=`mysqladmin -u ${USERNAME} -p${PASSWORD} ping`

  STATUS=`mysqladmin -u $USERNAME -p$PASSWORD status`

  UPTIME=`echo $STATUS | awk '{print $2}'`
  THREADS=`echo $STATUS | awk '{print $4}'`
  QUESTIONS=`echo $STATUS | awk '{print $6}'`
  SLOWQUERIES=`echo $STATUS  | awk '{print $9}'`
  OPENS=`echo $STATUS | awk '{print $11}'`
  FLUSHTABLES=`echo $STATUS | awk '{print $14}'`
  OPENTABLES=`echo $STATUS | awk '{print $17}'`
  QUERIESPERSECONDAVG=`echo $STATUS | awk '{print $22}'`
else
  PING=`mysqladmin -u ${USERNAME} ping`

  STATUS=`mysqladmin -u $USERNAME status`

  UPTIME=`echo $STATUS | awk '{print $2}'`
  THREADS=`echo $STATUS | awk '{print $4}'`
  QUESTIONS=`echo $STATUS | awk '{print $6}'`
  SLOWQUERIES=`echo $STATUS | awk '{print $9}'`
  OPENS=`echo $STATUS | awk '{print $11}'`
  FLUSHTABLES=`echo $STATUS | awk '{print $14}'`
  OPENTABLES=`echo $STATUS | awk '{print $17}'`
  QUERIESPERSECONDAVG=`echo $STATUS | awk '{print $22}'`
fi

# ping
RESULT=`printf "%s%s%s%s" "$RESULT" "{\"ping\": \"" "$PING" "\","`

# status->uptime
RESULT=`printf "%s%s%s%s" "$RESULT" "\"status\": {\"uptime\": \"" "$UPTIME" "\","`

# status->threads
RESULT=`printf "%s%s%s%s" "$RESULT" "\"threads\": \"" "$THREADS" "\","`

# status->questions
RESULT=`printf "%s%s%s%s" "$RESULT" "\"questions\": \"" "$QUESTIONS" "\","`

# status->slowQueries
RESULT=`printf "%s%s%s%s" "$RESULT" "\"slowQueries\": \"" "$SLOWQUERIES" "\","`

# status->opens
RESULT=`printf "%s%s%s%s" "$RESULT" "\"opens\": \"" "$OPENS" "\","`

# status->flushTables
RESULT=`printf "%s%s%s%s" "$RESULT" "\"flushTables\": \"" "$FLUSHTABLES" "\","`

# status->openTables
RESULT=`printf "%s%s%s%s" "$RESULT" "\"openTables\": \"" "$OPENTABLES" "\","`

# status->queriesPerSecondAvg
RESULT=`printf "%s%s%s%s" "$RESULT" "\"queriesPerSecondAvg\": \"" "$QUERIESPERSECONDAVG" "\"}}"`
echo $RESULT

