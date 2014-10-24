#!/usr/bin/expect
#-----------------------------------------------------------------------------
# Name          : mysql_ssh_copyid.sh
# Description   : copy dsa public key to remote host
# Author        : qiaolei
# Date          : 2014/10/13
#-----------------------------------------------------------------------------

set timeout 15

if {$argc != 3} {
send_user "usage:$argv0 <remote_host> <remote_user> <remote_password>"
exit
}

set remote_host [lindex $argv 0]
set remote_user [lindex $argv 1]
set remote_password [lindex $argv 2]

spawn /usr/bin/ssh-copy-id -i /root/.ssh/id_dsa.pub $remote_user@$remote_host

expect {
"(yes/no)?" {send "yes\r"; exp_continue}
"*password:" {send "$remote_password\r"}
eof
}

# expect eof

