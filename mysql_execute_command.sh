#!/usr/bin/expect
#-----------------------------------------------------------------------------
# Name          : mysql_execute_command.sh
# Description   : execute a command on remote host
# Author        : qiaolei
# Date          : 2014/10/13
#-----------------------------------------------------------------------------

set timeout 60

if {$argc != 4} {
send_user "usage:$argv0 <remote_host> <remote_user> <remote_password> <command>"
exit
}

set remote_host [lindex $argv 0]
set remote_user [lindex $argv 1]
set remote_password [lindex $argv 2]
set command [lindex $argv 3]

spawn /usr/bin/ssh $remote_user@$remote_host $command

expect {
"*(yes/no)?" {send "yes\r"; exp_continue}
"*password:" {send "$remote_password\r"}
eof {exit 0}
}

expect eof

