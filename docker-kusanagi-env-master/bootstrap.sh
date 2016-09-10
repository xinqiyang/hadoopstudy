#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml


service sshd start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh

export PATH=/usr/local/hadoop/bin:/usr/local/hbase/bin:/usr/local/apache-hive-1.2.1-bin/bin:/usr/local/spark/bin:$PATH

IP=`ip addr show eth0 | grep 'inet ' | cut -d/ -f1 | awk '{print $2}'`

sed -i "s/HOSTNAME/$HOSTNAME/g" /usr/local/hbase/conf/hbase-site.xml

sed -i "s/HOSTNAME/$HOSTNAME/g" /usr/local/hbase/conf/zoo.cfg

# echo "$IP $HOSTNAME" >> /etc/hosts

# Thrift server (background)
# Ports: 9090 API and 9095 UI
$HBASE_SERVER thrift start > /usr/local/hbase/logs/hbase-thrift.log 2>&1 &

# Master server (Foreground) that also starts the region server
# Ports: Master: 60000 API, 60010 UI; 2181 ZK;  Region: 60020 API, 60030 UI
exec $HBASE_SERVER master start >/dev/null 2>&1 &

# run hive
dbrootpwd=100intl
/etc/init.d/mysqld start
mysqladmin -u root password 100intl

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('100intl') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password='';
create database hive;
DROP USER ''@'%';
flush privileges;
EOF

mysql -u root -p$dbrootpwd -h localhost < /tmp/mysql_sec_script

rm -rf /tmp/mysql_sec_script

/etc/init.d/mysqld restart

mysql -uroot -p$dbrootpwd -e "CREATE USER 'hive'@'127.0.0.1' IDENTIFIED BY \"$dbrootpwd\";"
mysql -uroot -p$dbrootpwd -e "GRANT ALL PRIVILEGES ON * . * TO 'hive'@'127.0.0.1';"
mysql -uroot -p$dbrootpwd -e "FLUSH PRIVILEGES;"

hadoop dfsadmin -safemode leave
hdfs dfs -put /usr/local/spark/lib /spark


#start redis
service redis start


if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
