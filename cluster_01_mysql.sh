#!/bin/bash


# mkdir direaction include file exist and install
# File_dir=/usr/local/src/wnh/clusql
# Install_dir=



# mkdir -p $File_dir
# Judge OS version than choose rpm you need
# scp rpm package to src server defined dir

# cluster IP 205 206
# Intstall 205
# check mysql wheather exist or not
chk_mysql=`mysql -V`
if [[ "$chk_mysql" != "" ]];then
    echo "OS has already exist mysql, please check"
    exit
fi

chk_mariadb=`rpm -qa | grep mariadb`
if [[ "$chk_mariadb" != "" ]];then
    echo "OS has already exist mariadb, uninstall"
    rpm -qa | grep mariadb | xargs rpm -e --nodeps
    exit
fi


cd /usr/local/src/rpm
rpm -ivh mysql-community-libs-5.7.23-1.el7.x86_64.rpm \
mysql-community-libs-compat-5.7.23-1.el7.x86_64.rpm \
mysql-community-client-5.7.23-1.el7.x86_64.rpm \
mysql-community-common-5.7.23-1.el7.x86_64.rpm \
mysql-community-server-5.7.23-1.el7.x86_64.rpm

systemctl start mysqld
seid=`grep "server-id" /etc/my.cnf`
if [ ! -n "$seid" ];then
cat << EOF > /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd
server-id = 1         
log-bin = mysql-bin     
sync_binlog = 1
binlog_checksum = none
binlog_format = mixed
auto-increment-increment = 2     
auto-increment-offset = 1    
slave-skip-errors = all

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d
EOF

systemctl restart mysqld
init_pwd=`grep 'temporary password' /var/log/mysqld.log |tail -n 1 | awk '{print $NF}'`

cat >/tmp/mysql_$(date "+%Y%m%d%H").exp<<\!
exec /bin/echo "" > /tmp/mysql_cmd.log
log_file  /tmp/mysql_cmd.log
set init_pwd [lindex $argv 0]
set timeout 10

spawn mysql -u root -p
expect "*asswor*"
send "$init_pwd \r"
expect ">"
send "set global validate_password_policy=0;\r"
expect ">"
send "set global validate_password_length=1;\r"
expect ">"
send "set password=password('root');\r"
expect ">"
send "grant replication slave,replication client on *.* to repl@'192.168.1.%' identified by '1qaz@WSX';\r"
expect ">"
send "flush privileges;\r"
expect ">"
send "flush tables with read lock;\r"
expect ">"
send "show master status;\r"
expect eof
!
/usr/bin/expect -f /tmp/mysql_$(date "+%Y%m%d%H").exp $init_pwd > /dev/null

else
echo "Config file already >>"
fi

## scp ./mysql_cmd.log $user@$ip_02:/tmp
## wait
## /usr/bin/expect -f /tmp/mysql_$(date "+%Y%m%d%H").exp $1 || zhi
#a=`mysql -u repl -h 192.168.1.206 -p1qaz@WSX -e "show master status;" | grep "mysql-bin"`
#bin_id=`echo $a | awk '{print $1}`
#position=`echo $a | awk '{print $2}'`
#
#cat >/tmp/mysql_start_slave_$(date "+%Y%m%d%H").exp<<\!
#exec /bin/echo "" > /tmp/mysql_start_slave.log
#log_file  /tmp/mysql_cmd.log
#set user [lindex $argv 0]
#set pass [lindex $argv 1]
#set timeout 10
#
#spawn mysql -u $user -p
#expect "*asswor*"
#send "$pass\r"
#expect ">"
#send "unlock;\r"
#expect ">"
#send "change master to master_host='192.168.1.206',master_user='repl',master_password='1qaz@WSX',master_log_file='mysql-bin.000001',master_log_pos=150;\r"
#expect ">"
#send "start slave;\r"
#expect ">"
#send "show slave status\G;\r"
#expect eof
#!
#/usr/bin/expect -f /tmp/mysql_start_slave_$(date "+%Y%m%d%H").exp $1 $init_pwd > /dev/null

