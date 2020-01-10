#!/bin/bash


rpm -qa | grep mysql | xargs rpm -e --nodeps
rm -rf /tmp/mysql*
rm -rf /tmp/cluster*
rm -rf /etc/my.cnf*
rm -rf /usr/local/src/rpm
##yum remove keepalived-1.3.5-16.el7.x86_64
rpm -qa | grep keepalived | xargs rpm -e
rm -rf /etc/keepalived/keepalived.*
rm -rf /opt/chk_mysql.sh
