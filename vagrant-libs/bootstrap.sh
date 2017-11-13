#!/usr/bin/env bash

echo '### Install Ansible if not already existing ###'
yum -y install ansible

# echo '### Run Ansible ###'
# cd /vagrant && ansible-playbook site.yml -e "env=vagrant"
