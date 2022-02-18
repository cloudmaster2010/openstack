## Introduction
This guide describes how to install openstack with zun and kata on ubuntu 20.04 using devstack.

## Setup OpenStack environment with zun and kaka
```sh
sudo -i
hostnamectl set-hostname zun-kata.test.com
hostnamectl set-hostname zun-kata.test.com --transient


HOST_IP="$(ip -4 -o a | grep brd | head -n1 | awk '{print $4}' | cut -f1 -d'/')"
sudo echo "$HOST_IP  zun-kata.test.com zun-kata" >> /etc/hosts

useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

su - stack

git clone https://github.com/openstack-dev/devstack /opt/stack/devstack
git clone https://github.com/openstack/zun /opt/stack/zun

cp /opt/stack/zun/devstack/local.conf.sample /opt/stack/devstack/local.conf
cd /opt/stack/devstack

HOST_IP="$(ip -4 -o a | grep brd | head -n1 | awk '{print $4}' | cut -f1 -d'/')"
sed -i "s/HOST_IP=.*/HOST_IP=$HOST_IP/" /opt/stack/devstack/local.conf
sed -i "s/\# ENABLE_KATA_CONTAINERS=True/ENABLE_KATA_CONTAINERS=True/" /opt/stack/devstack/local.conf
sed -i "s/\# enable_plugin zun-ui .*/enable_plugin zun-ui https:\/\/opendev.org\/openstack\/zun-ui \$TARGET_BRANCH/" /opt/stack/devstack/local.conf
```




## Adding port(ens4) to the external bridge(br-ex)
```sh
ovs-vsctl --may-exist add-br br-ex -- set bridge br-ex \
  protocols=OpenFlow13
```

## Mapping pubilc:br-ex to go though external.
```sh
ovs-vsctl set open . external-ids:ovn-bridge-mappings=public:br-ex
ovs-vsctl --may-exist add-port br-ex ens4
```
## Creating external network named public 
```sh
openstack network create --external --share \
  --provider-physical-network public --provider-network-type flat \
  public
```
## Creating ip range for external network
```sh
openstack subnet create --network public --subnet-range \
  192.168.103.0/24 --allocation-pool start=192.168.103.151,end=192.168.103.160 \
  --dns-nameserver 8.8.8.8 --gateway 192.168.103.1 public-sub
```  
  
