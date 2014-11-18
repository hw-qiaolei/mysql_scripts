# -----------------------------------------------------------------------------
# Name		: mysql_add_slave.sh
# Description	: add a slave, skip master configurations
# Author	: qiaolei
# Date		: 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

usage()
{
  echo "Usage: $0 <master_host> <master_mysql_user> <master_mysql_password> <slave_host> <slave_host_user> <slave_host_password> <slave_mysql_user> <slave_mysql_password> <slave_server_id>"
  echo "<slave_server_id> is an unsigned integer, and is unique to each slave and should not use 1 (1 is used by master)"
}

if [ $# -ne 9 ]
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

MASTER_HOST=$1
MASTER_MYSQL_USER=$2
if [ $MASTER_MYSQL_USER = "NULL" ];then
  MASTER_MYSQL_USER ="root"
fi

MASTER_MYSQL_PASSWORD=$3

SLAVE_HOST=$4
SLAVE_HOST_USER=$5
if [ $SLAVE_HOST_USER = "NULL" ];then
  SLAVE_HOST_USER="root"
fi

SLAVE_HOST_PASSWORD=$6

SLAVE_MYSQL_USER=$7
if [ $SLAVE_MYSQL_USER = "NULL" ];then
  SLAVE_MYSQL_USER ="root"
fi

SLAVE_MYSQL_PASSWORD=$8

SLAVE_SERVER_ID=$9
if [ $SLAVE_SERVER_ID = "NULL" ];then
  SLAVE_SERVER_ID="2"
fi

REPL_USER="repl"
REPL_PASS="slavepass"

MYSQL_SCRIPTS_PATH=/usr/sbin/mysql_scripts

echo "creating slave{$SLAVE_HOST} for mysql master{$MASTER_HOST} with server id {$SLAVE_SERVER_ID}..." | tee -a $LOG_FILE


# STEP 1
echo -n -e "{\033[31m STEP 1/16  \033[0m: @{$MASTER_HOST}}: checking expect and try to install it if does not exist..."

rpm -q expect
if [ $? -ne 0 ];then
  yum install expect -y >/dev/null

  if [ $? -ne 0 ];then
    echo "expect is mandatory and it doest not installed successfully. please install it manually."
    exit 1
  fi
  echo "expect is installed successfully."
fi
echo "expect is already installed."

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 2
echo -n -e "{\033[31m STEP 2/16  \033[0m: @{$MASTER_HOST}}: generating a ssh key pair if does not exist..."

$MYSQL_SCRIPTS_PATH/mysql_ssh_keygen.sh

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 3
echo -n -e "{\033[31m STEP 3/16 \033[0m: @{$MASTER_HOST}}: copying ssh public key id to remote host{$SLAVE_HOST}..." | tee -a $LOG_FILE

$MYSQL_SCRIPTS_PATH/mysql_ssh_copyid.sh $SLAVE_HOST $SLAVE_HOST_USER $SLAVE_HOST_PASSWORD

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 4
echo -n -e "{\033[31m STEP 4/16 \033[0m: @{$MASTER_HOST}}: checking iptables status and try to stop it..." | tee -a $LOG_FILE

service iptables status
if [ $? -eq 0 ];then
  service iptables stop
  chkconfig iptables off
fi

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 5
echo -n -e "{\033[31m STEP 5/16 \033[0m: @{$MASTER_HOST}}: checking mysqld status and try to start it if necessary..." | tee -a $LOG_FILE

$MYSQL_SCRIPTS_PATH/mysql_service_action.sh status
if [ $? -ne 0 ];then
  $MYSQL_SCRIPTS_PATH/mysql_service_action.sh start
fi

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 6
echo -n -e "{\033[31m STEP 6/16 \033[0m: @{$MASTER_HOST}}: dumping mysql databases..." | tee -a $LOG_FILE

DUMPED_FILES=`$MYSQL_SCRIPTS_PATH/mysql_dump_databases.sh $MASTER_MYSQL_USER $MASTER_MYSQL_PASSWORD NULL`

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 7
echo -n -e "{\033[31m STEP 7/16 \033[0m: @{$MASTER_HOST}}: copying database files to remote host{$SLAVE_HOST}..." | tee -a $LOG_FILE

DUMPED_FILES=`$MYSQL_SCRIPTS_PATH/mysql_get_value_by_key.sh dumped_files "$DUMPED_FILES"`
DUMPED_FILES=${DUMPED_FILES//,/ }
for f in $DUMPED_FILES;do
  $MYSQL_SCRIPTS_PATH/mysql_send_file.sh $SLAVE_HOST $SLAVE_HOST_USER $SLAVE_HOST_PASSWORD $f /tmp
done

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 8
echo -n -e "{\033[31m STEP 8/16 \033[0m: @{$MASTER_HOST}}: getting master status..." | tee -a $LOG_FILE

MASTER_STATUS=`$MYSQL_SCRIPTS_PATH/mysql_master_status.sh $MASTER_MYSQL_USER $MASTER_MYSQL_PASSWORD`
MASTER_LOG_FILE=`$MYSQL_SCRIPTS_PATH/mysql_get_value_by_key.sh File "$MASTER_STATUS"`
MASTER_LOG_POS=`$MYSQL_SCRIPTS_PATH/mysql_get_value_by_key.sh Position "$MASTER_STATUS"`

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 9
echo -n -e "{\033[31m STEP 9/16 \033[0m: @{$MASTER_HOST}}: getting all databases..." | tee -a $LOG_FILE

JSON_DATABASES=`$MYSQL_SCRIPTS_PATH/mysql_get_databases.sh $MASTER_MYSQL_USER $MASTER_MYSQL_PASSWORD`
DATABASES=`$MYSQL_SCRIPTS_PATH/mysql_get_value_by_key.sh databases "$JSON_DATABASES"`

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 10
echo -n -e "{\033[31m STEP 10/16 \033[0m: @{$SLAVE_HOST}}: checking iptables status and try to stop it..." | tee -a $LOG_FILE

$MYSQL_SCRIPTS_PATH/mysql_execute_command.sh ${SLAVE_HOST} ${SLAVE_HOST_USER} ${SLAVE_HOST_PASSWORD} "service iptables status;if [ "$?" = "0" ];then service iptables stop;chkconfig iptables off;fi"

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 11
echo -n -e "{\033[31m STEP 11/16 \033[0m: @{$SLAVE_HOST}}: checking mysqld status and try to start it if necessary..." | tee -a $LOG_FILE

$MYSQL_SCRIPTS_PATH/mysql_execute_command.sh ${SLAVE_HOST} ${SLAVE_HOST_USER} ${SLAVE_HOST_PASSWORD} "$MYSQL_SCRIPTS_PATH/mysql_service_action.sh restart"

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 12
echo -n -e "{\033[31m STEP 12/16 \033[0m: @{$SLAVE_HOST}}: creating databases if not exists..." | tee -a $LOG_FILE

$MYSQL_SCRIPTS_PATH/mysql_execute_command.sh ${SLAVE_HOST} ${SLAVE_HOST_USER} ${SLAVE_HOST_PASSWORD} "$MYSQL_SCRIPTS_PATH/mysql_create_databases.sh $SLAVE_MYSQL_USER $SLAVE_MYSQL_PASSWORD $DATABASES"

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 13
echo -n -e "{\033[31m STEP 13/16 \033[0m: @{$SLAVE_HOST}}: importing database files..." | tee -a $LOG_FILE

DB_NAME=""
for f in $DUMPED_FILES;do
  DB_NAME=$f
  DB_NAME=${DB_NAME//\//|}
  DB_NAME=`echo $DB_NAME | awk -F'|' '{print $3}' | awk -F'-' '{print $1}'`
  $MYSQL_SCRIPTS_PATH/mysql_execute_command.sh ${SLAVE_HOST} ${SLAVE_HOST_USER} ${SLAVE_HOST_PASSWORD} "$MYSQL_SCRIPTS_PATH/mysql_import_database.sh $SLAVE_MYSQL_USER $SLAVE_MYSQL_PASSWORD $DB_NAME $f"
done

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 14
echo -n -e "{\033[31m STEP 14/16 \033[0m: @{$SLAVE_HOST}}: adding slave configuration to /etc/my.cnf..." | tee -a $LOG_FILE

$MYSQL_SCRIPTS_PATH/mysql_execute_command.sh ${SLAVE_HOST} ${SLAVE_HOST_USER} ${SLAVE_HOST_PASSWORD} "$MYSQL_SCRIPTS_PATH/mysql_slave_cnf.sh $SLAVE_SERVER_ID"

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 15
echo -n -e "{\033[31m STEP 15/16 \033[0m: @{$SLAVE_HOST}}: restart mysqld service..." | tee -a $LOG_FILE

$MYSQL_SCRIPTS_PATH/mysql_execute_command.sh ${SLAVE_HOST} ${SLAVE_HOST_USER} ${SLAVE_HOST_PASSWORD} "$MYSQL_SCRIPTS_PATH/mysql_service_action.sh restart"

echo -e "[\033[32m DONE \033[0m]"
echo


# STEP 16
echo -n -e "{\033[31m STEP 16/16 \033[0m: @{$SLAVE_HOST}}: changing master and restart slave..." | tee -a $LOG_FILE

$MYSQL_SCRIPTS_PATH/mysql_execute_command.sh ${SLAVE_HOST} ${SLAVE_HOST_USER} ${SLAVE_HOST_PASSWORD} "$MYSQL_SCRIPTS_PATH/mysql_stop_slave.sh $SLAVE_MYSQL_USER $SLAVE_MYSQL_PASSWORD"
$MYSQL_SCRIPTS_PATH/mysql_execute_command.sh ${SLAVE_HOST} ${SLAVE_HOST_USER} ${SLAVE_HOST_PASSWORD} "$MYSQL_SCRIPTS_PATH/mysql_reset_slave.sh $SLAVE_MYSQL_USER $SLAVE_MYSQL_PASSWORD"
$MYSQL_SCRIPTS_PATH/mysql_execute_command.sh ${SLAVE_HOST} ${SLAVE_HOST_USER} ${SLAVE_HOST_PASSWORD} "$MYSQL_SCRIPTS_PATH/mysql_change_master.sh $SLAVE_MYSQL_USER $SLAVE_MYSQL_PASSWORD $MASTER_HOST $REPL_USER $REPL_PASS $MASTER_LOG_FILE $MASTER_LOG_POS"
$MYSQL_SCRIPTS_PATH/mysql_execute_command.sh ${SLAVE_HOST} ${SLAVE_HOST_USER} ${SLAVE_HOST_PASSWORD} "$MYSQL_SCRIPTS_PATH/mysql_start_slave.sh $SLAVE_MYSQL_USER $SLAVE_MYSQL_PASSWORD"

echo -e "[\033[32m DONE \033[0m]"
echo

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

