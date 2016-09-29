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
IyEvYmluL2Jhc2gKCiMgJDEgPSB2b2x1bWVncm91cAojICQyID0gc2l6ZQojICMzID0gY291bnQKCmlmIFtbIC16ICR7c3RyaXBzaXplK3h9IF1dOyB0aGVuCiAgIHN0cmlwc2l6ZT04CiAgIGZpCgppZiBbICQjIC1lcSAwIF07IHRoZW4KICAgZWNobyAicHZjcmVhdGVsdW4gdm9sZ3JvdXAgc2l6ZSBjb3VudCIKICAgZWNobyAiICAgIHZvbGdyb3VwIGlzIHRoZSB2b2xncm91cCBhcyBjcmVhdGVkIGJ5IHZnY3JlYXRlIgogICBlY2hvICIgICAgc2l6ZSAtIGV4YW1wbGUgMUciCiAgIGVjaG8gIiAgICBjb3VudCAtIE9wdGlvbmFsIC0gTnVtYmVyIG9mIGx1bnMgdG8gY3JlYXRlIgogICBlY2hvICIgJE9TRVVTRVJOQU1FIHNob3VsZCBiZSBzZXQgdG8gdGhlIE9wZW5zaGlmdCBVc2VyIE5hbWUiCiAgIGV4aXQgMAogICBmaQojIENhbGwgb3Vyc2VsdmVzIHJlY3Vyc2l2ZWx5IHRvIGRvIHJlcGVhdHMKaWYgWyAkIyAtZXEgMyBdOyB0aGVuCiAgIGZvciAoKGk9MDtpIDwgJDM7aSsrKSkKICAgICAgIGRvCiAgICAgIC4vb3NlX3B2Y3JlYXRlX2x1biAkMSAkMgogICAgICBkb25lCiAgICBleGl0IDAKICAgZmkKClNUT1JFSVA9JChob3N0bmFtZSAtLWlwLWFkZHJlc3MpCkxVTkZJTEU9fi8ub3NlbHVuY291bnQuY250CkRFVkZJTEU9fi8ub3NlZGV2Y291bnQuY250ClRBRz0kMAoKaWYgWyAtZSAke0xVTkZJTEV9IF07IHRoZW4KICAgIGNvdW50PSQoY2F0ICR7TFVORklMRX0pCmVsc2UKICAgIHRvdWNoICIkTFVORklMRSIKICAgIGNvdW50PTAKZmkKCmlmIFsgLWUgJHtERVZGSUxFfSBdOyB0aGVuCiAgICBkY291bnQ9JChjYXQgJHtERVZGSUxFfSkKZWxzZQogICAgdG91Y2ggIiRERVZGSUxFIgogICAgZGNvdW50PTEKICAgZWNobyAke2Rjb3VudH0gPiAke0RFVkZJTEV9CmZpCgpsdW5pZD0ke2NvdW50fQooKGNvdW50KyspKQoKZWNobyAke2NvdW50fSA+ICR7TFVORklMRX0KCmV4cG9ydCB2b2xuYW1lPW9zZSIkY291bnQieCIkMiIKcHJpbnRmIC12IHBhZGNudCAiJTAzZCIgJGNvdW50CmV4cG9ydCBwYWRjbnQKCmx2Y3JlYXRlIC1MICQyIC1pJHN0cmlwc2l6ZSAtSTY0IC1uICR2b2xuYW1lICQxIHwgbG9nZ2VyIC0tdGFnICRUQUcKbWtmcy5leHQ0IC1xIC1GIF9GIC9kZXYvdmcxLyR2b2xuYW1lIDI+JjEgfCBsb2dnZXIgLS10YWcgJFRBRwppZiBbICR7Y291bnR9IC1lcSAxIF07IHRoZW4KICAgICBlY2hvICJTZXR1cCBkZXZpY2UiCiAgICAgdGFyZ2V0Y2xpIC9pc2NzaSBjcmVhdGUgaXFuLjIwMTYtMDIubG9jYWwuc3RvcmUke2Rjb3VudH06dDEgfCAgbG9nZ2VyIC0tdGFnICRUQUcKICAgICB0YXJnZXRjbGkgL2lzY3NpL2lxbi4yMDE2LTAyLmxvY2FsLnN0b3JlJHtkY291bnR9OnQxL3RwZzEvYWNscyBjcmVhdGUgaXFuLjIwMTYtMDIubG9jYWwuYXp1cmUubm9kZXMgfCBsb2dnZXIgLS10YWcgJFRBRwogICAgIHRhcmdldGNsaSAvaXNjc2kvaXFuLjIwMTYtMDIubG9jYWwuc3RvcmUke2Rjb3VudH06dDEvdHBnMS8gc2V0IGF0dHJpYnV0ZSBhdXRoZW50aWNhdGlvbj0wIHwgbG9nZ2VyIC0tdGFnICRUQUcKICAgICB0YXJnZXRjbGkgc2F2ZWNvbmZpZwpmaQoKdGFyZ2V0Y2xpIGJhY2tzdG9yZXMvYmxvY2svIGNyZWF0ZSAiJHZvbG5hbWUiIC9kZXYvdmcxLyIkdm9sbmFtZSIgfCAgbG9nZ2VyIC0tdGFnICRUQUcKdGFyZ2V0Y2xpIC9pc2NzaS9pcW4uMjAxNi0wMi5sb2NhbC5zdG9yZSR7ZGNvdW50fTp0MS90cGcxL2x1bnMgY3JlYXRlIC9iYWNrc3RvcmVzL2Jsb2NrLyIkdm9sbmFtZSIgfCBsb2dnZXIgLS10YWcgJFRBRwoKdGFyZ2V0Y2xpIHNhdmVjb25maWcgfCBsb2dnZXIgLS10YWcgJFRBRwoKY2F0IDw8RU9GID4gJHZvbG5hbWUueW1sCmFwaVZlcnNpb246IHYxCmtpbmQ6IFBlcnNpc3RlbnRWb2x1bWUKbWV0YWRhdGE6CiAgbmFtZTogaXNjc2lwdiR7ZGNvdW50fXgke3BhZGNudH0Kc3BlYzoKICBjYXBhY2l0eToKICAgIHN0b3JhZ2U6ICR7Mn1HaQogIGFjY2Vzc01vZGVzOgogICAgLSBSZWFkV3JpdGVPbmNlCiAgaXNjc2k6CiAgICAgdGFyZ2V0UG9ydGFsOiAkU1RPUkVJUAogICAgIGlxbjogaXFuLjIwMTYtMDIubG9jYWwuc3RvcmUke2Rjb3VudH06dDEKICAgICBsdW46ICR7bHVuaWR9CiAgICAgZnNUeXBlOiAnZXh0NCcKICAgICByZWFkT25seTogZmFsc2UKCkVPRgpvYyBjcmVhdGUgLWYgJHZvbG5hbWUueW1sCnJtIC1mICR2b2xuYW1lLnltbAppZiBbICR7Y291bnR9IC1lcSAxMDAgXTsgdGhlbgogICAoKGRjb3VudCsrKSkKICAgY291bnQ9MAogICBlY2hvICR7Y291bnR9ID4gJHtMVU5GSUxFfQogICBlY2hvICR7ZGNvdW50fSA+ICR7REVWRklMRX0KZmkKCg==
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
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${USERNAME}@master1:~/.kube/config /tmp/kube-config
cp /tmp/kube-config /root/.kube/config
mkdir /home/${USERNAME}/.kube
cp /tmp/kube-config /home/${USERNAME}/.kube/config
chown --recursive ${USERNAME} /home/${USERNAME}/.kube
rm -f /tmp/kube-config
./ose_pvcreate_lun vg1 1G 400 
./ose_pvcreate_lun vg1 10G 20 
./ose_pvcreate_lun vg1 50G 4 
systemctl restart target.service
