1, description
=============
This is a bunch of scripts developed for creating a mysql slave from scratch as well as for monitoring mysql related status, variables and performance.

For example, using mysql_create_slave.sh you can create a slave from scratch in several seconds.

The word "scratch" here means: you ONLY have to configure the network(IP address) properly for the mysql master and slave host, and install related software(mysql-libs, mysql, mysql-server) on each host.

You do NOT need to do any things else, such as:
* establish the trust relationship between the hosts
* dump databases on master, copy them to slave host and import them
* create a replication user and grant privileges
* modify master related configuration in /etc/my.cnf
* modify slave related configuration in /etc/my.cnf
* stop, reset and start slave
* change master on slave
* restart mysqld service
* etc

The result returned by each script is in JSON format. In case you call these scripts remotely and want to get the JSON formated result, you should modify these scripts by redirecting the output from standard output to a file, or simply comment these lines. For example:

(1) modify lines like "echo "xxx" | tee -a $LOG_FILE" to "echo "xxx" >$LOG_FILE";

(2) comment lines like "echo "xxx"" EXCEPT the last line "echo $RESULT".

The functionality of each script is self-explanatory.

Note 1: you should use default mysql installation.

Note 2: by default databases except "performance_schema" and "information_schema" are replicated. you should modify /etc/my.cnf manually if you want have more fine-grained control over replication.


2, prerequisites
=============
(1) operation system

These scripts are developed on linux, on my testbed the following system is tested:

CentOS release 6.5 (Final)

Theses scripts MAY also behave correctly on other CentOS/RHEL systems.

(2) mysql

On my testbed, the version of mysql is:

mysql-libs-5.1.73-3.el6_5.x86_64

mysql-server-5.1.73-3.el6_5.x86_64

mysql-5.1.73-3.el6_5.x86_64

Theses scripts MAY also behave correctly with other mysql versions, such as 5.x.

(3) expect

Automatic interaction is done by expect, so you MUST have expect installed.

On my testbed, the following version of expect is used:

expect-5.44.1.15-5.el6_4.x86_64

Theses scripts MAY also behave correctly by using other version of expect.

(4) json parser

I used JSON.sh as the json parser, it is already included in this project. The url of JSON.sh is:
https://github.com/dominictarr/JSON.sh



3, how to use
=============

First, donwload/clone the mysql_scripts project, and upload to somewhere(like /tmp) on the mysql master and slave host(they are not master and slave yet but you want to configure them to be).

Second, move mysql_scripts to /usr/sbin/. For example:

mv /tmp/mysql_scripts /usr/sbin/

Or:

mkdir -p /usr/sbin/mysql_scripts

cp -p /tmp/mysql_scripts/* /usr/sbin/mysql_scripts

Third, add executable permissions to shell scripts under /usr/sbin/mysql_scripts:

chmod +x /usr/sbin/mysql_scripts/*.sh

Then you can use these scripts. For example, if you want to create a slave, on master host, you can run "/usr/sbin/rdb/mysql_create_slave.sh" to get the usage of this script:

[root@mysql-master ~]# /usr/sbin/rdb/mysql_create_slave.sh

Usage: /usr/sbin/rdb/mysql_create_slave.sh [master_host] [master_mysql_user] [master_mysql_password] [slave_host] [slave_host_user] [slave_host_password] [slave_server_id]

[slave_server_id] is an unsigned integer, and is unique to each slave and should not use 1 (1 is used by master)

Here are some explanation:

* master_host           : ip address of hostname of mysql master host
* master_mysql_user     : mysql user of master host, such as root
* master_mysql_password : mysql user's password of master host, if it is empty, use NULL
* slave_host            : ip address of hostname of mysql slave host
* slave_host_user       : user of slave host, such as root
* slave_host_password   : user's password of slave host
* slave_server_id       : server id of slave, it is an unsigned integer, and is unique to each slave and should not use 1 (1 is used by master)

Generally you can create a mysql slave within 20 seconds for an initial mysql installation.


4, contact me
=============

If you have any problems with using these scripts, please feel free to contact me via: qiaolei.eb@gmail.com.

