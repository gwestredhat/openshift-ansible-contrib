#!/bin/bash

yum -y update
yum -y install targetcli
systemctl start target
systemctl enable target
systemctl restart target.service
firewall-cmd --permanent --add-port=3260/tcp
firewall-cmd --reload
sfdisk /dev/sdc << EOF
;
EOF
sfdisk /dev/sdd << EOF
;
EOF
sfdisk /dev/sde << EOF
;
EOF
sfdisk /dev/sdf << EOF
;
EOF
sfdisk /dev/sdg << EOF
;
EOF
sfdisk /dev/sdh << EOF
;
EOF
sfdisk /dev/sdi << EOF
;
EOF
sfdisk /dev/sdj << EOF
;
EOF
pvcreate /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1 /dev/sdg1 /dev/sdh1 /dev/sdi1 /dev/sdj1
vgcreate vg1 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1 /dev/sdg1 /dev/sdh1 /dev/sdi1 /dev/sdj1
cat <<EOF >  ~/ose_pvcreate_lun
#!/bin/bash

# $1 = volumegroup
# $2 = size
# #3 = count

if [ $# -eq 0 ]; then
   echo "pvcreatelun volgroup size count"
   echo "    volgroup is the volgroup as created by vgcreate"
   echo "    size - example 1G"
   echo "    count - Optional - Number of luns to create"
   exit 0
   fi
# Call ourselves recursively to do repeats
if [ $# -eq 3 ]; then
   for ((i=0;i < $3;i++))
       do
      ./ose_pvcreate_lun $1 $2
      done
    exit 0
   fi

LUNFILE=~/.oseluncount.cnt
TAG=$0

if [ -e ${LUNFILE} ]; then
    count=$(cat ${LUNFILE})
else
    touch "$LUNFILE"
    count=0
fi

((count++))

echo ${count} > ${LUNFILE}

export volname=ose"$count"x"$2"

lvcreate -L $2 -n $volname $1 | logger --tag $TAG
mkfs.ext4 -q -F _F /dev/vg1/$volname 2>&1 | logger --tag $TAG
if [ ${count} -eq 1 ]; then
     echo "Setup device"
     targetcli /iscsi create iqn.2016-02.local.store1:t1 |  logger --tag $TAG
     targetcli /iscsi/iqn.2016-02.local.store1:t1/tpg1/acls create iqn.2016-02.local.azure.nodes | logger --tag $TAG
     targetcli /iscsi/iqn.2016-02.local.store1:t1/tpg1/ set attribute authentication=0 | logger --tag $TAG
     targetcli saveconfig
fi
targetcli backstores/block/ create "$volname" /dev/vg1/"$volname" |  logger --tag $TAG
targetcli /iscsi/iqn.2016-02.local.store1:t1/tpg1/luns create /backstores/block/"$volname" | logger --tag $TAG

targetcli saveconfig | logger --tag $TAG
EOF
chmod +x ~/ose_pvcreate_lun
~/ose_pvcreate_lun vg1 1G 400
~/ose_pvcreate_lun vg1 10G 20
~/ose_pvcreate_lun vg1 50G 4
systemctl restart target.service
return 0
