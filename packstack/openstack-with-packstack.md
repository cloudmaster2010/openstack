# OpenStack installation with Packstack
This includes installing the CentOS with VirtualBox, preparing and planning your environment, and installation of OpenStack step by step.

## Step 0. Prerequisites. 
CentOS8 has become EOL(End of Life), so we will use CentOS7, which is the currently available OS version.

### 0-1. Download VirtualBox and install it.

### 0-2. Download CentOS7.
  http://ftp.nara.wide.ad.jp/pub/Linux/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso

### 0-3. Choose one of the virtualization tools to install OpenStack.
  a. Packstack (O) <-- We chose this installer.
  b. TripleO
  c. devstack

0-4. Design your OpenStack VM spec:
  a.  CPU : 2 Core
  b. Memory : 8196 MB(8 GB)
  c. Disk : 30 GB
  d. Network : 2 NICs, NAT(nic0) for internet and Host only adpater(nic1) for SSH, Dashboard

0-5. Install CentOS with VirtualBox.
Check if the network IP is up and available to access. if interfaces are down, you shoud up them to access to it with SSH. 

0-6. Uncomment "PermitRootLogin yes" to log in to openstack server with root user, and then restart sshd daemon.

# vi /etc/ssh/sshd_config
PermitRootLogin yes
# systemctl restart sshd
 

Step 1. Preparing OpenStack environment.

1-1. Set locale if you are not using English locale, add it to the end of line in /etc/environment file.

 # vi /etc/environment
export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8
1-2. Disable and stop firewalld and NetworkManager, set ONBOOT=yes in /etc/sysconfig/network-scripts/ifcfg-enp0s3, /etc/sysconfig/network-scripts/ifcfg-enp0s8 

# systemctl disable NetworkManager
# systemctl stop NetworkManager
# systemctl disable firewalld
# systemctl stop firewalld
# systemctl enable network

# vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
ONBOOT=yes
# vi /etc/sysconfig/network-scripts/ifcfg-enp0s8
ONBOOT=yes
1-3. Set the hostname with FQDN

#  hostnamectl set-hostname osp-train.exam.com
#  hostnamectl set-hostname osp-train.exam.com --transient
1-4. Check the Add IP address, hostname and FQDN and add them to the end of the line in /etc/hosts file.

# ip -4 -o a 
enp0s3    inet 10.0.2.15/24 
enp0s8    inet 192.168.56.113/24 

# hostname -f
osp-train.exam.com

# vi /etc/hosts
....
192.168.56.113  osp-train.exam.com osp-train
1-5 Disable selinux, and reboot OpenStack server.

# setenforce 0
# vi /etc/selinux/config
  ....
  SELINUX=disabled
  ....
# reboot
 

Step 2. Software repositories  

2-1. Install software repositories

# yum update -y
# yum install -y centos-release-openstack-train
2-2. Install Packstack installer

# yum update -y
# yum install -y openstack-packstack
 

Step 3. Run Packstack to install OpenStack
3-1. Generate the answer file and replace all IPs with the IP available for access to the dashboard.

# packstack --gen-answer-file=ans.txt
# vi ans.txt
:%s/10.0.2.15/192.168.56.113/g 
3-2. Check the IP adrresses and all components to be installed.

# grep -i 192.168.56.113 ans.txt 
CONFIG_CONTROLLER_HOST=192.168.56.113 
CONFIG_COMPUTE_HOSTS=192.168.56.113 
CONFIG_NETWORK_HOSTS=192.168.56.113 
CONFIG_AMQP_HOST=192.168.56.113 
CONFIG_MARIADB_HOST=192.168.56.113 
CONFIG_REDIS_HOST=192.168.56.113

# grep -i =y ans.txt 
CONFIG_MARIADB_INSTALL=y 
CONFIG_GLANCE_INSTALL=y 
CONFIG_CINDER_INSTALL=y 
CONFIG_NOVA_INSTALL=y 
CONFIG_NEUTRON_INSTALL=y 
CONFIG_HORIZON_INSTALL=y 
CONFIG_SWIFT_INSTALL=y 
CONFIG_CEILOMETER_INSTALL=y 
CONFIG_AODH_INSTALL=y 
CONFIG_CLIENT_INSTALL=y 
CONFIG_RH_OPTIONAL=y 
CONFIG_SSL_CACERT_SELFSIGN=y 
CONFIG_CINDER_VOLUMES_CREATE=y 
CONFIG_NOVA_MANAGE_FLAVORS=y 
CONFIG_NEUTRON_METERING_AGENT_INSTALL=y 
CONFIG_HEAT_CFN_INSTALL=y 
CONFIG_PROVISION_DEMO=y 
CONFIG_PROVISION_OVS_BRIDGE=y 

3-3. Install the OpenStack.

# packstack --answer-file=ans.txt
3-4. You can trace the log about what packstack is doing on this openstack server by running the command below in another termnial.

# journalctl -f
3-5. After finall installation, you can see the below results

......

 **** Installation completed successfully ****** 

Additional information: 
 * Parameter CONFIG_NEUTRON_L2_AGENT: You have chosen OVN Neutron backend. Note that this backend does not support the VPNaaS or FWaaS services. Geneve will be used as the encapsulation method for tenant networks 
 * Time synchronization installation was skipped. Please note that unsynchronized time on server instances might be problem for some OpenStack components. 
 * File /root/keystonerc_admin has been created on OpenStack client host 192.168.56.113. To use the command line tools you need to source the file. 
 * To access the OpenStack Dashboard browse to http://192.168.56.113/dashboard . 
Please, find your login credentials stored in the keystonerc_admin in your home directory. 
 * Because of the kernel update the host 192.168.56.113 requires reboot. 
 * The installation log file is available at: /var/tmp/packstack/20220205-141955-AwGLLM/openstack-setup.log 
 * The generated manifests are available at: /var/tmp/packstack/20220205-141955-AwGLLM/manifests
3-6. Let's check the OpenStack service status

# yum install openstack-utils 
# openstack-status


Step 4. Log in to OpenStack Dashboard and take a look at it.
4-1. You can find out the information to connect to the dashboard from /root/keystonerc_admin file.

# cat /root/keystonerc_admin
unset OS_SERVICE_TOKEN
    export OS_USERNAME=admin
    export OS_PASSWORD='c4c37bccb4e34726'
    export OS_REGION_NAME=RegionOne
    export OS_AUTH_URL=http://192.168.56.113:5000/v3
    export PS1='[\u@\h \W(keystone_admin)]\$ '

export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_IDENTITY_API_VERSION=3
4-2. Now, you can log in to the dashboard, enjoy your journey of OpenStack. 

OVN Network Connection Test:
Let's test the Tenant network connection between the same tenant on the same compute. 

Tenant network(Geneve) : 22.22.22.0/24
test1 VM : 22.22.22.44/24
test2 VM : 22.22.22.129/24

Ping from 22.22.22.44 to 22.22.22.129

Hypervisor environment is like below:

# ovs-vsctl show
bf50b171-8a8e-4c25-8646-cb0e75fa7489
    Manager "ptcp:6640:127.0.0.1"
        is_connected: true
    Bridge br-int
        fail_mode: secure
        datapath_type: system
        Port "tap0d8f55c3-40"
            Interface "tap0d8f55c3-40"
        Port "tap25fe9135-a4"
            Interface "tap25fe9135-a4"
        Port "tap90617d84-54"
            Interface "tap90617d84-54"
        Port br-int
            Interface br-int
                type: internal
    Bridge br-ex
        Port br-ex
            Interface br-ex
                type: internal
    ovs_version: "2.12.0"

# ip netns
ovnmeta-0d8f55c3-4dc1-40a3-ac98-0e7b600664df (id: 0)

# ip netns exec ovnmeta-0d8f55c3-4dc1-40a3-ac98-0e7b600664df ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: tap0d8f55c3-41@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether fa:16:3e:0f:99:8c brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 22.22.22.2/24 brd 22.22.22.255 scope global tap0d8f55c3-41
       valid_lft forever preferred_lft forever
    inet 169.254.169.254/16 brd 169.254.255.255 scope global tap0d8f55c3-41
       valid_lft forever preferred_lft forever

# virsh list
----------------------------------------------------
 1     instance-00000001              running
 2     instance-00000002              runnnig
 

Conclusion:

Above, we configured and installed OpenStack through the Packstack installer and have taken a look at the openstack features. Packstack is mainly used for PoC purposes because there are many parts that are insufficient to use in a commercial environment. With the commercial products, like Red Hat OpenStack, which is highly recommended. You can experiance a lot of help from Red Hat Consulting, and you can also trust your service environment when you are with Red Hat together. 
