#!/bin/bash

## !IMPORTANT ##
#
## This script is tested only in the generic/ubuntu2004 Vagrant box
## If you use a different version of Ubuntu or a different Ubuntu Vagrant box test this again
#

echo "[NODE-TASK 1] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[NODE-TASK 2] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[NODE-TASK 3] Enable and Load Kernel modules"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[NODE-TASK 4] Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

echo "[NODE-TASK 5] Install docker runtime"
apt update -qq >/dev/null 2>&1
apt-get update \
    && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
        "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
        $(lsb_release -cs) \
        stable" \
    && apt-get update \
    && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 20.10 | head -1 | awk '{print $3}')

echo "[NODE-TASK 6] Add apt repo for kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

echo "[NODE-TASK 7] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt install -qq -y kubeadm=1.21.0-00 kubelet=1.21.0-00 kubectl=1.21.0-00 >/dev/null 2>&1

echo "[NODE-TASK 8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[NODE-TASK 9] Set root password"
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[NODE-TASK 10] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.50.2  kubemaster.example.com    kubemaster
192.168.50.3  kubenode01.example.com    kubenode01
192.168.50.4  kubenode02.example.com    kubenode02
192.168.50.5  kubenode03.example.com    kubenode03
EOF
