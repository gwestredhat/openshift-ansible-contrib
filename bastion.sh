#!/bin/bash

RESOURCEGROUP=$1
USERNAME=$2
PASSWORD=$3
HOSTNAME=$4
NODECOUNT=$5
ROUTEREXTIP=$6
RHNUSERNAME=$7
RHNPASSWORD=$8
RHNPOOLID=$9
SSHPRIVATEDATA=${10}
SSHPUBLICDATA=${11}
SSHPUBLICDATA2=${12}
SSHPUBLICDATA3=${13}

ps -ef | grep bastion.sh > cmdline.out

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

subscription-manager unregister 
yum -y remove RHEL7
rm -f /etc/yum.repos.d/rh-cloud.repo
subscription-manager register --username $RHNUSERNAME --password $RHNPASSWORD
subscription-manager attach --pool=$RHNPOOLID
subscription-manager repos --disable="*"
subscription-manager repos     --enable="rhel-7-server-rpms"     --enable="rhel-7-server-extras-rpms"
subscription-manager repos     --enable="rhel-7-server-ose-3.2-rpms"
yum -y install atomic-openshift-utils
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion httpd-tools
yum -y install docker
sed -i -e "s#^OPTIONS='--selinux-enabled'#OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0/16'#" /etc/sysconfig/docker
                                                                                         
cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdc
VG=docker-vg
EOF

docker-storage-setup                                                                                                                                    
systemctl enable docker
systemctl start docker


cat <<EOF > /etc/ansible/hosts
[OSEv3:children]
masters
etcd
nodes

[OSEv3:vars]
azure_resource_group=${RESOURCEGROUP}
rhn_user_name=${RHNUSERNAME}
rhn_password=${RHNPASSWORD}
rhn_pool_id=${RHNPOOLID}
debug_level=2
deployment_type=openshift-enterprise
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]

ansible_sudo=true
ansible_ssh_user=${USERNAME}
remote_user=${USERNAME}

openshift_master_default_subdomain=${ROUTEREXTIP}.xip.io 
openshift_use_dnsmasq=False
openshift_public_hostname=${RESOURCEGROUP}.trafficmanager.net

openshift_master_cluster_method=native
openshift_master_cluster_hostname=${RESOURCEGROUP}.trafficmanager.net
openshift_master_cluster_public_hostname=${RESOURCEGROUP}.trafficmanager.net

[masters]
master1 openshift_node_labels="{'role': 'master'}"
master2 openshift_node_labels="{'role': 'master'}"
master3 openshift_node_labels="{'role': 'master'}"

[etcd]
master1
master2
master3

[nodes]
master1 openshift_node_labels="{'region':'infra','zone':'default'}" openshift_schedulable=false
master2 openshift_node_labels="{'region':'infra','zone':'default'}" openshift_schedulable=false
master3 openshift_node_labels="{'region':'infra','zone':'default'}" openshift_schedulable=false
node[01:${NODECOUNT}] openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
infranode openshift_node_labels="{'region': 'infra', 'zone': 'default'}"
EOF

mkdir -p /etc/origin/master
htpasswd -cb /etc/origin/master/htpasswd ${USERNAME} ${PASSWORD}

cat <<EOF > /home/${USERNAME}/subscribe.yml
---
- hosts: nodes
  vars:
    description: "Subscribe OSE"
  tasks:
  - name: check connection
    ping:
  - name: Get rid of rhui repos
    file: path=/etc/yum.repos.d/rh-cloud.repo state=absent
  - name: Get rid of rhui Load balancers
    file: path=/etc/yum.repos.d/rhui-load-balancers state=absent
  - name: remove the RHUI package
    yum: name=RHEL7 state=absent
  - name: Get rid of old subs
    redhat_subscription: state=absent
  - name: register hosts
    redhat_subscription: state=present username=${RHNUSERNAME} password=${RHNPASSWORD} pool=${RHNPOOLID} autosubscribe=true
  - name: disable all repos
    command: subscription-manager repos --disable="*"
  - name: enable selected repos
    command: subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.2-rpms"
  - name: Update all hosts
    command: yum -y update
EOF


cat <<EOF > /home/${USERNAME}/openshift-install.sh
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook /home/${USERNAME}/subscribe.yml
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml
ssh master1 oadm registry --selector=region=infra
ssh master1 oadm router --selector=region=infra
EOF

cat <<EOF > /home/${USERNAME}/.ansible.cfg
[defaults]
host_key_checking = False
EOF
chown ${USERNAME} /home/${USERNAME}/.ansible.cfg
  
cat <<EOF > /root/.ansible.cfg
[defaults]
host_key_checking = False
EOF


cd /home/${USERNAME}

sleep 120
ssh -o StrictHostKeyChecking=no gwest@node01 ps > ps.out
ansible all --module-name=ping > ansible1.out
ansible all --module-name=ping > ansible2.out

chown ${USERNAME} /home/${USERNAME}/openshift-install.sh
chmod 755 /home/${USERNAME}/openshift-install.sh
/home/${USERNAME}/openshift-install.sh &> /home/${USERNAME}/openshift-install.out &
exit 0

