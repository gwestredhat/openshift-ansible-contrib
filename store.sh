#!/bin/bash

yum -y update
yum -y install targetcli
systemctl start target
systemctl enable target
systemctl restart target.service
firewall-cmd --permanent --add-port=3260/tcp
firewall-cmd --reload
pvcreate /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi /dev/sdj
vgcreate vg1 /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi /dev/sdj
return 0
lvcreate -l 100%FREE -n vol1 vg1
targetcli
cd backstore/block
create vol1_server /dev/vg1/vol1
cd /iscsi
create iqn.2016-02.local.store1
cd /iscsi/iqn.2016-02.local.store1/tpg1/acls
create iqn.2016-02.local.azure.nodes
cd /iscsi/iqn.2016-02.local.store1/tpg1/luns
create /backstores/block/vol1_server 
cd /iscsi/iqn.2016-02.local.store1/tpg1/
set attribute authentication=0
cd /
ls
saveconfig
exit
systemctl restart target.service
return 0
