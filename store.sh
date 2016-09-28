#!/bin/bash

RESOURCEGROUP=${1}
USERNAME=${2}
SSHPRIVATEDATA=${3}
SSHPUBLICDATA=${4}
SSHPUBLICDATA2=${5}
SSHPUBLICDATA3=${6}

export OSEUSERNAME=$2

ps -ef | grep store.sh > cmdline.out

mkdir -p /home/$USERNAME/.ssh
echo $SSHPUBLICDATA $SSHPUBLICDATA2 $SSHPUBLICDATA3 >  /home/$USERNAME/.ssh/id_rsa.pub
echo $SSHPRIVATEDATA | base64 --d > /home/$USERNAME/.ssh/id_rsa
chown $USERNAME /home/$USERNAME/.ssh/id_rsa.pub
chmod 600 /home/$USERNAME/.ssh/id_rsa.pub
chown $USERNAME /home/$USERNAME/.ssh/id_rsa
chmod 600 /home/$USERNAME/.ssh/id_rsa

mkdir -p /root/.ssh
echo $SSHPRIVATEDATA | base64 --d > /root/.ssh/id_rsa
echo $SSHPUBLICDATA $SSHPUBLICDATA2 $SSHPUBLICDATA3   >  /root/.ssh/id_rsa.pub
chown root /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa.pub
chown root /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa


yum -y update
yum -y install targetcli
yum -y install lvm2
systemctl start target
systemctl enable target
systemctl restart target.service
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
cat <<EOF | base64 --decode >  /root/ose_pvcreate_lun
IyEvYmluL2Jhc2gKCiMgJDEgPSB2b2x1bWVncm91cAojICQyID0gc2l6ZQojICMzID0gY291bnQKCmlmIFtbIC16ICR7c3RyaXBzaXplK3h9IF1dOyB0aGVuCiAgIHN0cmlwc2l6ZT04CiAgIGZpCgppZiBbICQjIC1lcSAwIF07IHRoZW4KICAgZWNobyAicHZjcmVhdGVsdW4gdm9sZ3JvdXAgc2l6ZSBjb3VudCIKICAgZWNobyAiICAgIHZvbGdyb3VwIGlzIHRoZSB2b2xncm91cCBhcyBjcmVhdGVkIGJ5IHZnY3JlYXRlIgogICBlY2hvICIgICAgc2l6ZSAtIGV4YW1wbGUgMUciCiAgIGVjaG8gIiAgICBjb3VudCAtIE9wdGlvbmFsIC0gTnVtYmVyIG9mIGx1bnMgdG8gY3JlYXRlIgogICBlY2hvICIgJE9TRVVTRVJOQU1FIHNob3VsZCBiZSBzZXQgdG8gdGhlIE9wZW5zaGlmdCBVc2VyIE5hbWUiCiAgIGV4aXQgMAogICBmaQojIENhbGwgb3Vyc2VsdmVzIHJlY3Vyc2l2ZWx5IHRvIGRvIHJlcGVhdHMKaWYgWyAkIyAtZXEgMyBdOyB0aGVuCiAgIGZvciAoKGk9MDtpIDwgJDM7aSsrKSkKICAgICAgIGRvCiAgICAgIC4vb3NlX3B2Y3JlYXRlX2x1biAkMSAkMgogICAgICBkb25lCiAgICBleGl0IDAKICAgZmkKClNUT1JFSVA9JChob3N0bmFtZSAtLWlwLWFkZHJlc3MpCkxVTkZJTEU9fi8ub3NlbHVuY291bnQuY250ClRBRz0kMAoKaWYgWyAtZSAke0xVTkZJTEV9IF07IHRoZW4KICAgIGNvdW50PSQoY2F0ICR7TFVORklMRX0pCmVsc2UKICAgIHRvdWNoICIkTFVORklMRSIKICAgIGNvdW50PTAKZmkKCmx1bmlkPSR7Y291bnR9CigoY291bnQrKykpCgplY2hvICR7Y291bnR9ID4gJHtMVU5GSUxFfQoKZXhwb3J0IHZvbG5hbWU9b3NlIiRjb3VudCJ4IiQyIgoKbHZjcmVhdGUgLUwgJDIgLWkkc3RyaXBzaXplIC1JNjQgLW4gJHZvbG5hbWUgJDEgfCBsb2dnZXIgLS10YWcgJFRBRwpta2ZzLmV4dDQgLXEgLUYgX0YgL2Rldi92ZzEvJHZvbG5hbWUgMj4mMSB8IGxvZ2dlciAtLXRhZyAkVEFHCmlmIFsgJHtjb3VudH0gLWVxIDEgXTsgdGhlbgogICAgIGVjaG8gIlNldHVwIGRldmljZSIKICAgICB0YXJnZXRjbGkgL2lzY3NpIGNyZWF0ZSBpcW4uMjAxNi0wMi5sb2NhbC5zdG9yZTE6dDEgfCAgbG9nZ2VyIC0tdGFnICRUQUcKICAgICB0YXJnZXRjbGkgL2lzY3NpL2lxbi4yMDE2LTAyLmxvY2FsLnN0b3JlMTp0MS90cGcxL2FjbHMgY3JlYXRlIGlxbi4yMDE2LTAyLmxvY2FsLmF6dXJlLm5vZGVzIHwgbG9nZ2VyIC0tdGFnICRUQUcKICAgICB0YXJnZXRjbGkgL2lzY3NpL2lxbi4yMDE2LTAyLmxvY2FsLnN0b3JlMTp0MS90cGcxLyBzZXQgYXR0cmlidXRlIGF1dGhlbnRpY2F0aW9uPTAgfCBsb2dnZXIgLS10YWcgJFRBRwogICAgIHRhcmdldGNsaSBzYXZlY29uZmlnCmZpCnRhcmdldGNsaSBiYWNrc3RvcmVzL2Jsb2NrLyBjcmVhdGUgIiR2b2xuYW1lIiAvZGV2L3ZnMS8iJHZvbG5hbWUiIHwgIGxvZ2dlciAtLXRhZyAkVEFHCnRhcmdldGNsaSAvaXNjc2kvaXFuLjIwMTYtMDIubG9jYWwuc3RvcmUxOnQxL3RwZzEvbHVucyBjcmVhdGUgL2JhY2tzdG9yZXMvYmxvY2svIiR2b2xuYW1lIiB8IGxvZ2dlciAtLXRhZyAkVEFHCgp0YXJnZXRjbGkgc2F2ZWNvbmZpZyB8IGxvZ2dlciAtLXRhZyAkVEFHCgpjYXQgPDxFT0YgPiAkdm9sbmFtZS55bWwKYXBpVmVyc2lvbjogdjEKa2luZDogUGVyc2lzdGVudFZvbHVtZQptZXRhZGF0YToKICBuYW1lOiBpc2NzaXB2JHtsdW5pZH0Kc3BlYzoKICBjYXBhY2l0eToKICAgIHN0b3JhZ2U6IDFHaQogIGFjY2Vzc01vZGVzOgogICAgLSBSZWFkV3JpdGVPbmNlCiAgaXNjc2k6CiAgICAgdGFyZ2V0UG9ydGFsOiAkU1RPUkVJUAogICAgIGlxbjogaXFuLjIwMTYtMDIubG9jYWwuc3RvcmUxOnQxCiAgICAgbHVuOiAke2x1bmlkfQogICAgIGZzVHlwZTogJ2V4dDQnCiAgICAgcmVhZE9ubHk6IGZhbHNlCgpFT0YKb2MgY3JlYXRlIC1mICR2b2xuYW1lLnltbApybSAtZiAkdm9sbmFtZS55bWwK
EOF
firewall-cmd --permanent --add-port=3260/tcp
firewall-cmd --reload
chmod +x /root/ose_pvcreate_lun
cd ~
while true
do
  STATUS=$(curl -k -s -o /dev/null -w '%{http_code}' https://master1:8443/api)
  if [ $STATUS -eq 200 ]; then
    echo "Got 200! All done!"
    break
  else
    echo "."
  fi
  sleep 10
done

cd /root
mkdir .kube
scp ${USERNAME}@master1:~/.kube/config /tmp/kube-config
cp /tmp/kube-config ~/.kube/config
mkdir /home/${USERNAME}/.kube
cp /tmp/kube-config /home/${USERNAME}/.kube/config
chown --recursive ${USERNAME} /home/${USERNAME}/.kube
rm -f /tmp/kube-config
# ./ose_pvcreate_lun vg1 1G 400 
# ./ose_pvcreate_lun vg1 10G 20 
# ./ose_pvcreate_lun vg1 50G 4 
# systemctl restart target.service
