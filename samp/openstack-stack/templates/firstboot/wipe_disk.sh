#!/bin/bash

if [[ `hostname` = *"sds"* ]]
then
  for DEVICE in `lsblk -no NAME,TYPE,MOUNTPOINT | grep "disk" | awk '{print $1}'`
  do 
    ROOTFOUND=0
    echo "Checking /dev/${DEVICE}..."
    for MOUNTS in `lsblk -n /dev/${DEVICE} | awk '{print $7}'`
    do 
      if [[ "$MOUNTS" = "/" ]]
      then
	ROOTFOUND=1
      fi
    done
    if [[ $ROOTFOUND = 0 ]]
    then
      sgdisk -Z /dev/${DEVICE}
      #sgdisk -g /dev/${DEVICE}
    else
      echo "--------"
    fi
    systemctl disable multipathd
    systemctl stop multipathd
    multipath -F
    rm /etc/multipath.conf
    echo 'ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[b-g]", ATTR{queue/rotational}="0"' > /etc/udev/rules.d/60-force-ssd-rotational.rules
    udevadm control --reload-rules
    udevadm trigger --type=devices --action=change
  done
fi

