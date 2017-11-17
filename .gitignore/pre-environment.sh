#!/bin/bash

### set selinux & firewall
setenforce 0
sed -i '/^SELINUX=.*/ s//SELINUX=disabled/' /etc/selinux/config
systemctl stop firewalld.service
systemctl disable firewalld.service

##set yum 
test -d /etc/yum.repos.d/repo.bak || (mkdir -p /etc/yum.repos.d/repo.bak && mv  /etc/yum.repos.d/*.repo  /etc/yum.repos.d/repo.bak )

test -f /etc/yum.repos.d/CentOS7-Base-163.repo || wget -P /etc/yum.repos.d/ http://mirrors.163.com/.help/CentOS7-Base-163.repo
test -f /etc/yum.repos.d/epel-7.repo || wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/epel-7.repo 
sed -i "/aliyuncs.com/d" /etc/yum.repos.d/epel-7.repo

if [  ! -f /etc/yum.repos.d/CentOS-OpenStack-ocata.repo ]
then
        echo 'Openstack yum not exist'
        echo '[centos-openstack-ocata]' >> /etc/yum.repos.d/CentOS-OpenStack-ocata.repo
        echo 'name=CentOS-7 - OpenStack ocata' >> /etc/yum.repos.d/CentOS-OpenStack-ocata.repo
        echo 'baseurl=http://mirrors.163.com/centos/7/cloud/x86_64/openstack-ocata/' >> /etc/yum.repos.d/CentOS-OpenStack-ocata.repo
        echo 'gpgcheck=0' >> /etc/yum.repos.d/CentOS-OpenStack-ocata.repo
        echo 'enabled=1' >> /etc/yum.repos.d/CentOS-OpenStack-ocata.repo
fi
yum clean all
yum list | grep zmap


### set NTP
rpm -qa | grep chrony || yum -y install chrony
ntpdate 0.centos.pool.ntp.org && hwclock -w &
sed -i "/iburst/d" /etc/chrony.conf && sed -i '1i\server 0.centos.pool.ntp.org iburst' /etc/chrony.conf
cat /etc/chrony.conf | grep -v '^#' | grep '^allow' || sed -i  "/NTP\ client/a allow\ 10.0.0.0\/8" /etc/chrony.conf
systemctl enable chronyd.service
systemctl start chronyd.service

