Installation of OpenStack with Packstack

This includes installing the CentOS with VirtualBox, preparing and planning your environment, and installation of OpenStack step by step.

Step 0. Prerequisites. 

CentOS8 has become EOL(End of Life), so we will use CentOS7, which is the currently available OS version.

0-1. Download VirtualBox and install it.

0-2. Download CentOS7.
  http://ftp.nara.wide.ad.jp/pub/Linux/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso

0-3. Choose one of the virtualization tools to install OpenStack.
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


