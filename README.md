### Configuration and execution
#### Install   || sh mysql.sh 
#### execute scripts mysql.sh
<br></br>
#### uninstall || sh uninstall.sh
#### uninstall scripts uninstall.sh || Only test, Prod Warning!!!
<br></br>
#### Configuration
#### myssh_sftp_linux.sh || file and rpm exist root dir
#### modify cmd_path and file_path
#### mysql.sh || Input test env user passwd ipaddress port
#### Script execution efficiency depends on network bandwidth and server performance
#### keepalived VIP cluster_0102_mysql.sh and cluster_0202_mysql.sh
<br></br>

### 数据库双主同步加keepalived架构图    
<br></br>
![mysqlcluster](https://github.com/happyhelloworld/shell/blob/master/images/mysql%E9%9B%86%E7%BE%A4%E6%9E%B6%E6%9E%84%E5%9B%BE1.png)
