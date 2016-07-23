#!/bin/bash
#This script designed for setup of puppet master in debian jessie#

while getopts ":m:h:a:n:" OPTION
do
	case $OPTION in
		m)
			host1="${OPTARG}"
			;;

		h)
		 	masterIP="${OPTARG}"
			;;
		a)
			agentIP="${OPTARG}"
			;;
	esac
done


hostname1="$host1"
masterhost="$masterIP  $host1.example.com $host1 puppet"
certname="$host1.example.com"
dns_alt_name="puppet,$host1,$host1.example.com"

#setting hostname of server 
echo $hostname1 > /etc/hostname
hostname $hostname1

#Adding hostentries
echo $masterhost >> /etc/hosts

#installing puppetserver
/usr/bin/apt-get -y update
/usr/bin/apt-get -y install puppetmaster

agent_count=1
for agent in ${agentIP}
do
echo "agent${agent_count}.example.com" >> /etc/puppet/autosign.conf
echo "${agent}  agent${agent_count}.example.com" >> /etc/hosts
agent_count=$((agent_count+1))
ping -c 2 agent${agent_count}.example.com
done

chmod 644 /etc/puppet/autosign.conf

#configuring puppet-server
echo "certname = $certname" >> /etc/puppet/puppet.conf
echo "dns_alt_names = $dns_alt_name" >> /etc/puppet/puppet.conf

echo "autosign = /etc/puppet/autosign.conf" >> /etc/puppet/puppet.conf

# Starting puppetserver
service puppetmaster restart

echo 'Pupet server is installed and configured successfully..!!'
