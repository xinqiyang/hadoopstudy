#!/bin/bash
$dbrootpwd=100intl
yum -y install mysql-community-server
mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$dbrootpwd\" with grant option;"
mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$dbrootpwd\" with grant option;"
mysql -uroot -p$dbrootpwd -e "delete from mysql.user where Password='';"
mysql -uroot -p$dbrootpwd -e "delete from mysql.db where User='';"
mysql -uroot -p$dbrootpwd -e "delete from mysql.proxies_priv where Host!='localhost';"
mysql -uroot -p$dbrootpwd -e "CREATE USER 'hive'@'localhost' IDENTIFIED BY \"$dbrootpwd\";"
mysql -uroot -p$dbrootpwd -e "GRANT ALL PRIVILEGES ON * . * TO 'hive'@'localhost';"
mysql -uroot -p$dbrootpwd -e "FLUSH PRIVILEGES;"
mysql -uroot -p$dbrootpwd -e "drop database test;"
mysql -uroot -p$dbrootpwd -e "reset master;"

