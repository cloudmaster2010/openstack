#!/bin/bash

source /home/stack/stackrc

openstack overcloud deploy --templates /home/stack/templates/rendered \
-r /home/stack/templates/roles_data.yaml \
-n /home/stack/templates/network_data.yaml \
-e /home/stack/templates/node-info.yaml \
-e /home/stack/containers-prepare-parameter.yaml \
-e /home/stack/templates/custom-domain.yaml \
-e /home/stack/templates/network-environment.yaml \
-e /home/stack/templates/network-isolation.yaml \
-e /home/stack/templates/fixed-ip-vips.yaml \
-e /home/stack/templates/ips-from-pool-all.yaml \
-e /home/stack/templates/rendered/environments/disable-swift.yaml \
-e /home/stack/templates/rendered/environments/disable-telemetry.yaml \
-e /home/stack/templates/storage-environment.yaml \
-e /home/stack/templates/ceph-ansible-external.yaml \
--debug

# ewp.co.kr
