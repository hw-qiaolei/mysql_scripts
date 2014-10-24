# -----------------------------------------------------------------------------
# Name          : mysql_system_usage.sh
# Description   : get mysql host system usage
# Author        : qiaolei
# Date          : 2014/10/13
# -----------------------------------------------------------------------------

#!/bin/sh

# 返回值格式：
# {
#     "cpu": {
#         "processorNumber": "2",
#         "modelName": "Intel(R) Xeon(R) CPU E5620 @ 2.40GHz"
#     },
#     "memory": {
#             "memoryTotal": "1878",
#             "memoryFree": "111"
#     },
#     "disk": {
#             "diskTotal": "15694",
#             "diskUsed": "6271",
#             "diskAvailable": "8626",
#             "diskUsedPercentage": "43%"
#     }
# }

LOG_FILE=/tmp/itchazuo_rdb.log
if [ ! -f $LOG_FILE ];then
  touch $LOG_FILE
fi

TIMESTAMP=`date +%Y%m%d%H%M%S`
echo "@$TIMESTAMP: {$0 $*}" | tee -a $LOG_FILE

TMP_CPU_INFO=/tmp/cpuinfo.tmp
cat /proc/cpuinfo > $TMP_CPU_INFO

CPU_PROCESSOR_NUM=`cat $TMP_CPU_INFO | grep -v grep | grep processor | wc -l`

CPU_MODEL=`cat $TMP_CPU_INFO | grep -v grep | grep "model name" -m 1`
CPU_MODEL=`echo ${CPU_MODEL#*:}`
rm -f $TMP_CPU_INFO

TMP_MEM_INFO=/tmp/meminfo.tmp
cat /proc/meminfo > $TMP_MEM_INFO

MEM_TOTAL=`cat $TMP_MEM_INFO | grep -v grep | grep MemTotal | awk '{print $2}'`
MEM_TOTAL=`expr $MEM_TOTAL / 1024`

MEM_FREE=`cat $TMP_MEM_INFO | grep -v grep | grep MemFree | awk '{print $2}'`
MEM_FREE=`expr $MEM_FREE / 1024`
rm -f $TMP_MEM_INF

TMP_DISK_INFO=/tmp/diskinfo.tmp
df -m >$TMP_DISK_INFO

DISK_TOTAL_M=`cat $TMP_DISK_INFO | grep -v grep | grep " /" -m 1 | awk '{print $2}'`
DISK_USED_M=`cat $TMP_DISK_INFO | grep -v grep | grep " /" -m 1 | awk '{print $3}'`
DISK_AVAILABLE_M=`cat $TMP_DISK_INFO | grep -v grep | grep " /" -m 1 | awk '{print $4}'`
DISK_USED_PERCENT=`cat $TMP_DISK_INFO | grep -v grep | grep " /" -m 1 | awk '{print $5}'`
rm -f $TMP_DISK_INFO 

# CPU->processros
RESULT=`printf "%s%s%s%s" "$RESULT" "{\"cpu\": {\"processorNumber\": \"" "$CPU_PROCESSOR_NUM" "\","`

# CPU->model
RESULT=`printf "%s%s%s%s" "$RESULT" "\"modelName\": \"" "$CPU_MODEL\"" "},"`

# Memory->MemroryTotal
RESULT=`printf "%s%s%s%s" "$RESULT" "\"memory\": {\"memoryTotal\": \"" "$MEM_TOTAL" "\","`

# Memory->MemoryFree
RESULT=`printf "%s%s%s%s" "$RESULT" "\"memoryFree\": \"" "$MEM_FREE" "\"},"`

# Disk->DiskTotal
RESULT=`printf "%s%s%s%s" "$RESULT" "\"disk\": {\"diskTotal\": \"" "$DISK_TOTAL_M" "\","`

# Disk->DiskUsed
RESULT=`printf "%s%s%s%s" "$RESULT" "\"diskUsed\": \"" "$DISK_USED_M" "\","`

# Disk->DiskAvailable
RESULT=`printf "%s%s%s%s" "$RESULT" "\"diskAvailable\": \"" "$DISK_AVAILABLE_M" "\","`

# Disk->DiskUsedPercentage
RESULT=`printf "%s%s%s%s" "$RESULT" "\"diskUsedPercentage\": \"" "$DISK_USED_PERCENT" "\"}}"`
echo $RESULT


