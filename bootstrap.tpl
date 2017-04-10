#!/bin/bash

#metadata_url=http://169.254.169.254/latest/meta-data
function setHostname() {
   hostname ${HOSTNAME}
   echo "HOSTNAME=${HOSTNAME}" > /etc/hostnmae
   echo "HOSTNAME=${HOSTNAME}" >> /etc/sysconfig/network
   echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
}

function check_internet() {
  retry_frequency=$1
  for i in $(seq 1 $retry_frequency); do
    if ping -c 1 -w 1 google.com >> /dev/null 2>&1; then
      echo "Internet is up, can proceed further now"
      return
    else
      echo "Internet connection timeout, continuing with check..."
    fi
  done
}

function puppet_setup() {
  PUPPET_SERVER="${PUPPET_SERVER}"
  ENVIRONMENT="${ENVIRONMENT}"

  yum makecache fast
  yum install wget -y

  sleep 30
  rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
  yum -y install puppetserver

cat >/etc/puppetlabs/puppet/puppet.conf << EOL
[main]
environment=${ENVIRONMENT}
certname=${HOSTNAME}

[agent]
server=${PUPPET_SERVER}
report=true
EOL

mkdir -p /etc/puppetlabs/puppetserver/code/environment/${ENVIRONMENT}
cd /etc/puppetlabs/puppetserver/code/environment/${ENVIRONMENT}
git clone ${PUPPET_CODE_REPO}  .
git checkout ${ENVIRONMENT}

}

check_internet 500
setHostname
yum -y install wget git
puppet_setup
