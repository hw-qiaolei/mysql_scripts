#!/usr/bin/expect
#-----------------------------------------------------------------------------
# Name          : mysql_send_file.sh
# Description   : send the specified local file to a remote host
# Author        : qiaolei
# Date          : 2014/10/13
#-----------------------------------------------------------------------------

set timeout 3600

if {$argc != 5} {
send_user "usage:$argv0 <remote_host> <remote_user> <remote_password> <local_file> <remote_dir>"
exit
}

set remote_host [lindex $argv 0]
set remote_user [lindex $argv 1]
set remote_password [lindex $argv 2]
set local_file [lindex $argv 3]
set remote_dir [lindex $argv 4]

spawn /usr/bin/scp -pr $local_file $remote_user@$remote_host:$remote_dir

expect {
"(yes/no)?" {send "yes\r"; exp_continue}
"*password:" {send "$remote_password\r"}
eof
}

# expect eof

