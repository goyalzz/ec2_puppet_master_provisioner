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

rm -rf /etc/puppetlabs/code/environments/${ENVIRONMENT}
mkdir -p /etc/puppetlabs/code/environments/${ENVIRONMENT}
cd /etc/puppetlabs/code/environments/${ENVIRONMENT}
git clone ${PUPPET_CODE_REPO}  .
git checkout ${ENVIRONMENT}

cat >/etc/puppetlabs/puppet/hiera.yaml << EOL
---
:backends:
  - yaml
:yaml:
  :datadir: "/etc/puppetlabs/code/environments/%{::environment}/hieradata"
:hierarchy:
   - "roles/%{roles}"
   - common
:logger: puppet
:merge_behavior: deeper
EOL

echo "*" >/etc/puppetlabs/puppet/autosign.conf

/opt/puppetlabs/puppet/bin/gem install r10k
mkdir -p /root/.ssh
mkdir -p /etc/puppetlabs/r10k
cat >/root/.ssh/config << EOL
Host *
    StrictHostKeyChecking no
EOL

cat >/etc/puppetlabs/r10k/r10k.yaml << EOL
:cachedir: '/opt/puppetlabs/r10k/cache'
:sources:
  :adtech:
    remote: '${PUPPET_CODE_REPO}'
    basedir: '/etc/puppetlabs/code/environments'
EOL
service puppetserver start
}

check_internet 500
setHostname
yum -y install wget git
puppet_setup
