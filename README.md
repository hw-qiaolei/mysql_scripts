0, mysql_scripts
=============

This a bunch of scripts developed for creating a mysql slave from scratch as well as for monitoring mysql related status, variables and performance.


1, description
=============
This a bunch of scripts developed for creating a mysql slave from scratch as well as for monitoring mysql related status, variables and performance.

For example, using mysql_create_slave.sh you can create a slave from scratch in several seconds.

The word "scratch" means: you have the network(IP address) configured properly for the mysql master and slave host, and installed mysql-server on each host.

You do not need to do any things else, such as,
* establish the trust relationship between the hosts
* dump databases on master, copy them to slave host and import them
* create a replication user grant privileges
* modify master related configuration in /etc/my.cnf
* modify slave related configuration in /etc/my.cnf
* stop, reset and start slave
* change master on slave
* restart mysqld service
* etc

The result returned by each script is in JSON format. In case you call these scripts remotely and want to get the JSON formated result, you should modify these scripts by redirecting the output to standard output to a file, or simply comment these lines. For example,

(1) modify lines like "echo "xxx" | tee -a $LOG_FILE" to "echo "xxx" >$LOG_FILE";

(2) comment lines like "echo "xxx""  EXCEPT the last line "echo $RESULT".

The functionality of each script is self-explanatory.

Note 1: you should use default mysql installation.

Note 2: by default databases except performance_schema and information_schema are replicated. you should modify /etc/my.cnf if you want more fine-grained 
        control over replication.


2, prerequisites
=============
(1) operation system

These scripts are developed on linux, on my testbed the following system is tested:
CentOS release 6.5 (Final)

Theses scripts many also behave correctly on other CentOS/RHEL systems.

(2) mysql

On my testbed, the version of mysql is:

mysql-libs-5.1.73-3.el6_5.x86_64

mysql-server-5.1.73-3.el6_5.x86_64

mysql-5.1.73-3.el6_5.x86_64

Theses scripts many also behave correctly on other mysql versions, like 5.x.

(3) expect

Automatic interaction is done by expect, so you should have expect installed.

On my testbed, the version of expect is:
expect-5.44.1.15-5.el6_4.x86_64

Theses scripts many also behave correctly by using other version of expect.

(4) json parser

I used JSON.sh as the json parser, it is already included in this project. The url of JSON.sh is as following:
https://github.com/dominictarr/JSON.sh



3, how to use
=============

Donwload/Clone the mysql_scripts project, and upload to somewhere(like /tmp) on the mysql master and slave host(they are not master and slave now but you want to configure them to be).

Move the files under mysql_scripts to /usr/sbin/rdb. Like:

mv /tmp/mysql_scripts /usr/sbin/rdb

Or:

mkdir -p /usr/sbin/rdb

cp -p /tmp/mysql_scripts/* /usr/sbin/rdb

Then you can use these scripts. For example, if you want to create a slave, on master host, you can run "/usr/sbin/rdb/mysql_create_slave.sh" to get the usage of this script:

[root@mysql-master ~]# /usr/sbin/rdb/mysql_create_slave.sh

Usage: /usr/sbin/rdb/mysql_create_slave.sh [master_host> [master_mysql_user] [master_mysql_password] [slave_host] [slave_host_user] [slave_host_password] [slave_server_id]

[slave_server_id] is an unsigned integer, it is unique to each slave and should not use 1 (1 is used by master)

Generally you can create a slave host within 20 seconds for an initial mysql installation.


4, contact me
=============

If you have any problems with using these scripts, please feel free to contact me via: qiaolei.eb@gmail.com.

