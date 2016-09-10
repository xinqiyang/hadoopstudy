# Creates kusanagi dev
#
# docker build -t 100intl/kusanagi .
# docker run -i -t -p 10000:2122  -h kusanagi 100intl/kusanagienv /etc/bootstrap.sh -bash
# docker run -i -t -p 10001:2122  -h kusanagi1 100intl/kusanagienv /etc/bootstrap.sh -bash


FROM sequenceiq/pam:centos-6.5
MAINTAINER xinqiyang <yangxinqi@100intl.co.jp>

USER root
ADD mysql-community.repo /etc/yum.repos.d/mysql-community.repo
ADD RPM-GPG-KEY-mysql /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

# install dev tools
RUN yum install -y curl which tar sudo openssh-server openssh-clients rsync wget git mysql-server jq 
# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux

#install redis
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-6.rpm
RUN yum --enablerepo=remi info redis
RUN yum -y install redis

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkmcfL/hibQztkGXWxq+74wCGfvDpD7iub9lblxVV6KRKSbtdpek2/KZscwdN8XXShRHGQgzwjJuPOaWaPir8F7q0NsCMSVyUtNs1PD0RmTPBjtbxy/N8HnlaGnNAhbk9AWqlJmTol1Atf4aqGUWoHp+mAH6HTxBDtEEbcpsNWcU9acVuTLPT5/J7Xz8Lho+cDQZ7WlxzjOdj7WKwy79rJGra94zBWCgTOD9vqN7oS1G3w2ugAyrIqf4R1YlCxR48qt3t0YKqCsJrAxSBtKef3CTnUJZO5340NPGEAQOr8Ax0bwL6TtJIa44mICXgduHcm8S/qWpXy85ddsHpMb0rN kusanagi@kusanagi" >> /root/.ssh/authorized_keys  
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxDNKWLxu+05sz7YI/qLSYpiPP4bOYTc0F00EYAW1n6a9varnUKpJ/Po6/BAW8GOl+plPwnw0k+ROMX71o3yIoXif8r/XV6vBh7atmT6v2786DMDmmlgRIWUnYlthXYvnt5WJsrveuL1juE9Tpz2F16iie7tksWaqnnwpL8fJnkdb6WEWn+8XOXsSzrElXKFHXrrmji4uvgmF6sG1bcgC6DWQxOn2oL8cDEo93vVzjlEVJr1EfYkEt/fbmbDTrBp3QZ5HNE3+pvwhaMet3GlTYLfURQJUKnysbkdRl7H404WgLJxH3UmHqNV5bTaDAhWjjm+D/esgU/Q3McwJnfijh xinqiyang@xinqiyangs-MacBook.local" >> /root/.ssh/authorized_keys

#change timezon
RUN mv /etc/localtime /etc/localtime.bak
RUN ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# java
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-7u71-linux-x64.rpm
RUN rm jdk-7u71-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

#add install maven
ENV MAVEN_VERSION 3.2.5

RUN curl -sSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

# hadoop
ENV HADOOP_VERSION 2.6.0
RUN curl -s http://ftp.jaist.ac.jp/pub/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-$HADOOP_VERSION hadoop
ADD jline-2.11.jar /usr/local/hadoop/share/hadoop/common/lib/

ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
#RUN . $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

RUN mkdir $HADOOP_PREFIX/input
RUN cp $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input

# pseudo distributed
ADD core-site.xml.template $HADOOP_PREFIX/etc/hadoop/core-site.xml.template
RUN sed s/HOSTNAME/localhost/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml

ADD mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml

RUN $HADOOP_PREFIX/bin/hdfs namenode -format

# fixing the libhadoop.so like a boss
RUN rm  /usr/local/hadoop/lib/native/*
RUN curl -Ls http://dl.bintray.com/sequenceiq/sequenceiq-bin/hadoop-native-64-$HADOOP_VERSION.tar | tar -x -C /usr/local/hadoop/lib/native/

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

RUN service sshd start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root
RUN service sshd start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -put $HADOOP_PREFIX/etc/hadoop/ input

# Download and Install HBase
ENV HBASE_VERSION 1.2.2

RUN curl -s http://ftp.jaist.ac.jp/pub/apache/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz | tar -xz -C /usr/local/
RUN ln -s /usr/local/hbase-$HBASE_VERSION /usr/local/hbase
ENV HBASE_SERVER /usr/local/hbase/bin/hbase


# Data will go here (see hbase-site.xml)
RUN mkdir -p /data/hbase /usr/local/hbase/logs

ENV HBASE_SERVER /usr/local/hbase/bin/hbase

ADD ./hbase-site.xml /usr/local/hbase/conf/hbase-site.xml

ADD ./zoo.cfg /usr/local/hbase/conf/zoo.cfg

#install mysql
ADD ./my.cnf /etc/my.cnf

#install hive
ENV HIVE_VERSION 1.2.1
RUN curl -s http://ftp.jaist.ac.jp/pub/apache/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz | tar -xz -C /usr/local/
ADD hive-site.xml /usr/local/apache-hive-$HIVE_VERSION-bin/conf/hive-site.xml
ADD ./mysql-connector-java-5.1.34-bin.jar /usr/local/apache-hive-$HIVE_VERSION-bin/lib/mysql-connector-java-5.1.34-bin.jar
RUN mv /usr/local/apache-hive-$HIVE_VERSION-bin/conf/hive-log4j.properties.template /usr/local/apache-hive-$HIVE_VERSION-bin/conf/hive-log4j.properties

#install spark
ENV SPARK_VERSION 1.6.2
ENV HADOOP_SPARK_VERSION 2.6
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION-bin-hadoop$HADOOP_SPARK_VERSION.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-$SPARK_VERSION-bin-hadoop$HADOOP_SPARK_VERSION spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

#RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-1.6.2-bin-hadoop2.6/lib /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV SPARK_JAR hdfs:///spark/spark-assembly-$SPARK_VERSION-hadoop$HADOOP_VERSION.jar
ENV PATH $PATH:$SPARK_HOME/bin

ENV SPARK_MASTER_IP master
ADD log4j.properties /usr/local/spark/conf/log4j.properties


#VOLUME ["/data"]
#WORKDIR /data

CMD ["/etc/bootstrap.sh", "-d"]

# THRIFT API
EXPOSE 9090
# THRIFT WEB UI
EXPOSE 9095
# HBASE'S ZOOKEEPER - USED TO FIND SERVERS
EXPOSE 2181
# HBASE MASTER API PORT
EXPOSE 60000
# HBASE MASTER WEB UI AT :60010/MASTER-STATUS;  ZK AT :60010/ZK.JSP
EXPOSE 60010
# Region server API port
EXPOSE 60020
# HBase Region server web UI at :60030/rs-status
EXPOSE 60030

EXPOSE 50020 50090 50070 50010 50075 8031 8032 8033 8040 8042 49707 2122 8088 8030 9000 8020 2181 56114 9092 7077 3306
