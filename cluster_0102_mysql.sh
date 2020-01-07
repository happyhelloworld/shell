#!/bin/bash

# wait
# /usr/bin/expect -f /tmp/mysql_$(date "+%Y%m%d%H").exp $1 || zhi
a=`mysql -u repl -h 192.168.1.206 -p1qaz@WSX -e "show master status;" | grep "mysql-bin"`
bin_id=`echo $a | awk '{print $1}'`
position=`echo $a | awk '{print $2}'`
sip=$1
localip=`ip addr | grep inet  | grep -v inet6 | grep -v 127 | awk '{print $2}' | awk -F'/' '{print $1}'`

sql_cmd="change master to master_host='$sip',master_user='repl',master_password='1qaz@WSX',master_log_file='$bin_id',master_log_pos='$position'"
echo $sql_cmd

#set sip [lindex $argv 0]
#set binid [lindex $argv 1]
#set posit [lindex $argv 2]
#send "change master to master_host=$sip,master_user='repl',master_password='1qaz@WSX',master_log_file=$bin_id,master_log_pos=$position;\r"
#/usr/bin/expect -f /tmp/mysql_start_slave_$(date "+%Y%m%d%H").exp $sip $bind_id $position > /dev/null
cat >/tmp/mysql_start_slave_$(date "+%Y%m%d%H").exp<<\!
exec /bin/echo "" > /tmp/mysql_start_slave.log
log_file  /tmp/mysql_slave_cmd.log
set sql_cmd [lindex $argv 0]
set timeout 10

spawn mysql -u root -p
expect "*asswor*"
send "root\r"
expect ">"
send "unlock tables;\r"
expect ">"
send "stop slave;\r"
expect ">"
send "$sql_cmd ;\r"
expect ">"
send "start slave;\r"
expect ">"
send "show slave status \\G;\r"
expect eof
!
/usr/bin/expect -f /tmp/mysql_start_slave_$(date "+%Y%m%d%H").exp "$sql_cmd" > /dev/null

##
## keepalived
##
enstat=`nmcli device status | grep '连接的' | awk '{print $1}'`
keep=`rpm -qa | grep keepalived`
if [ -z "$keep" ];then
    yum -y install keepalived-1.3.5-16.el7.x86_64
fi



cat << EOF > /opt/chk_mysql.sh
#!/bin/bash
counter=$(netstat -na|grep "LISTEN"|grep "3306"|wc -l)
if [ "${counter}" -eq 0 ]; then
    /etc/init.d/keepalived stop
fi
EOF
chmod 755 /opt/chk_mysql.sh

cat << EOF > /etc/keepalived/keepalived.conf
! Configuration File for keepalived
       
global_defs {
    notification_email {
        admin@163.com
        tech@163.com
    }
    notification_email_from ops@wangshibo.cn
    smtp_server 127.0.0.1 
    smtp_connect_timeout 30
    router_id MASTER-HA
}
       
vrrp_script chk_mysql_port {
    script "/opt/chk_mysql.sh"
    interval 2
    weight -5
    fall 2
    rise 1
}
       
vrrp_instance VI_1 {
    state MASTER    
    interface $enstat
    mcast_src_ip $localip
    virtual_router_id 51
    priority 101
    advert_int 1         
    authentication {   
        auth_type PASS 
        auth_pass 1111     
    }
    virtual_ipaddress {    
        192.168.1.209
    }
      
    track_script {               
        chk_mysql_port             
    }
}
EOF

systemctl start keepalived
systemctl enable keepalived
