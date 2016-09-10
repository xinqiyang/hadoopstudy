#!/bin/sh

echo "create database amon DEFAULT CHARACTER SET utf8;" | mysql -u root -proot
echo "grant all on amon.* TO 'amon'@'%' IDENTIFIED BY 'ccah'" | mysql -u root -proot

echo "create database rman DEFAULT CHARACTER SET utf8;" | mysql -u root -proot
echo "grant all on rmon.* TO 'rmon'@'%' IDENTIFIED BY 'ccah'" | mysql -u root -proot

echo "create database metastore DEFAULT CHARACTER SET utf8;" | mysql -u root -proot
echo "grant all on metastore.* TO 'hive'@'%' IDENTIFIED BY 'ccah'" | mysql -u root -proot

echo "grant all on *.* TO 'root'@'127.0.0.1' IDENTIFIED BY 'root'" | mysql -u root -proot
echo "flush privileges" | mysql -u root -proot

