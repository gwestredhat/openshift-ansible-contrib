#!/bin/bash

USERNAME=$1
PASSWORD=$2
HOSTNAME=$3
NODECOUNT=$4
ROUTEREXTIP=$5
RHNUSERNAME=$6
RHNPASSWORD=$7
RHNPOOLID=$8
SSHPUBLICDATA=$9
SSHPRIVATEDATA=$10


mkdir -p /home/$USERNAME/.ssh
echo $SSHPRIVATEDATA > /home/$USERNAME/.ssh/id_rsa
echo $SSHPUBLICDATA > /home/$USERNAME/.ssh/id_rsa.pub
subscription-manager unregister 
subscription-manager register --username $RHNUSERNAME --password $RHNPASSWORD
subscription-manager attach --pool=$RHNPOOLID
subscription-manager repos --disable="*"
subscription-manager repos     --enable="rhel-7-server-rpms"     --enable="rhel-7-server-extras-rpms"
subscription-manager repos     --enable="rhel-7-server-ose-3.2-rpms"
yum -y install atomic-openshift-utils
#yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion httpd-tools
yum -y install https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel install ansible1.9 pyOpenSSL
git clone https://github.com/openshift/openshift-ansible /opt/openshift-ansible
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
nodes

[OSEv3:vars]
rhn_user_name=${RHNUSERNAME}
rhn_password=${RHNPASSWORD}
rhn_pool_id=${RHNPOOLID}
debug_level=2
deployment_type=enterprise
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]

ansible_sudo=true
ansible_ssh_user=${USERNAME}
remote_user=${USERNAME}

openshift_master_default_subdomain=${ROUTEREXTIP}.xip.io 
openshift_use_dnsmasq=False

[masters]
master openshift_public_hostname=${HOSTNAME}

[nodes]
master
node[01:0${NODECOUNT}] openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
infranode openshift_node_labels="{'region': 'infra', 'zone': 'default'}"
EOF

mkdir -p /etc/origin/master
htpasswd -cb /etc/origin/master/htpasswd ${USERNAME} ${PASSWORD}


cat <<EOF > /home/${USERNAME}/openshift-install.sh
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook /opt/openshift-ansible/playbooks/byo/config.yml
oadm registry --selector=region=infra
oadm router --selector=region=infra
EOF

chmod 755 /home/${USERNAME}/openshift-install.sh
/home/${USERNAME}/openshift-install.sh

