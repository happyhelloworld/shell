#!/usr/bin/expect 
## for example
##      myssh.sh 192.168.1.10 username1 password1  inspect.sh
## Status:
##      Connection refused
##      Login incorrect
##      ftp not found
##      Connection closed


set cmd_path "/usr/local/src/wnh/clusql/src/uninstall"

set ip01 [lindex $argv 0]
set user01 [lindex $argv 1]
set pass01 [lindex $argv 2]
set cmd01 [lindex $argv 3]
set port01 [lindex $argv 4]
set ip02 [lindex $argv 5]
set user02 [lindex $argv 6]
set pass02 [lindex $argv 7]
set cmd01 [lindex $argv 8]
set port02 [lindex $argv 9]
set RET_VALUE 0

set timeout 300

# sftp file to cluster_01
spawn sftp -oPort=$port01 $user01@$ip01
expect {
"*Permission denied*" { exit }
"*yes/no*" {send "yes\r"; exp_continue}
"*assword*" {send "$pass01\r";exp_continue}
"*sftp>*" {send "\r";}
"*refused*"  { exit  }
"*Could not resolve hostname*" { exit }
timeout { puts "Connection timeout !";exit}
}


expect "sftp>"
send "lcd $cmd_path\r"
send "cd /tmp\r"
send "put $cmd01\r"
send "quit\r"
expect eof       

# sftp file to cluster_02
spawn sftp -oPort=$port02 $user02@$ip02
expect {
"*Permission denied*" { exit }
"*yes/no*" {send "yes\r"; exp_continue}
"*assword*" {send "$pass02\r";exp_continue}
"*sftp>*" {send "\r";}
"*refused*"  { exit  }
"*Could not resolve hostname*" { exit }
timeout { puts "Connection timeout !";exit}
}


expect "sftp>"
send "lcd $cmd_path\r"
send "cd /tmp\r"
send "put $cmd01\r"
send "quit\r"
expect eof

#spawn ssh -l $user01 $ip01
spawn ssh $user01@$ip01 -p $port01

expect {
"*Last login*" {send "\r";}
"*Permission denied*"  {exit}
"*yes/no*" {send "yes\r"; exp_continue}
"*assword*" {send "$pass01\r";exp_continue}
"*refused*"  { exit  }
"*Could not resolve hostname*" { exit }
timeout { puts "Connection timeout !";exit}
}
expect  {
"*#*" {send "bash /tmp/$cmd01\r"}
"*#*" {send "exit\r"}
"*$*" {send "bash /tmp/$cmd01\r"}
"*$*" {send "exit\r"}
}
send "exit\r"
expect eof

#spawn ssh -l $user02 $ip02
spawn ssh $user02@$ip02 -p $port02

expect {
"*Last login*" {send "\r";}
"*Permission denied*"  {exit}
"*yes/no*" {send "yes\r"; exp_continue}
"*assword*" {send "$pass02\r";exp_continue}
"*refused*"  { exit  }
"*Could not resolve hostname*" { exit }
timeout { puts "Connection timeout !";exit}
}
expect  {
"*#*" {send "bash /tmp/$cmd01\r"}
"*#*" {send "exit\r"}
"*$*" {send "bash /tmp/$cmd01\r"}
"*$*" {send "exit\r"}
}
send "exit\r"
expect eof

