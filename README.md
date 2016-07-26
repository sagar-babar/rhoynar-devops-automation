# Rhoynar-devops-automation

## Vagrant with puppet node provisioning using shell script and puppet modules for  Gerrit, Zuul, Jenkins and JIRA.


  *Tested with Linux (Debian Jessie)*

**Prerequisite:**
### [Vagrant](https://www.vagrantup.com/downloads.html) >= 1.8.5

Download URL's:
- For [Mac](http://download.virtualbox.org/virtualbox/5.1.2/VirtualBox-5.1.2-108956-OSX.dmg) 
- For [windows](http://download.virtualbox.org/virtualbox/5.1.2/VirtualBox-5.1.2-108956-Win.exe)

### [Virual Box](https://www.virtualbox.org/wiki/Downloads) >= 5.1.2

Download URL's:
- For [Mac](https://releases.hashicorp.com/vagrant/1.8.5/vagrant_1.8.5.dmg)
- For [windows](https://releases.hashicorp.com/vagrant/1.8.5/vagrant_1.8.5.msi)
 
### Provision Three Machines

Here we are provisioning three virtual machines into virtual box using vagrant, follow the below instructions to provisioning.
* Chnage directory where *Vagrantfile* is placed.
* Ensure that both *puppet-master.sh* and *puppet-agent.sh* is present in same location.

Make the below  necessary changes in Vagranfile (if required e.g if you want to change ip addresses for nodes)

#####1. For Master VM:

<pre>

config.vm.define "master" do |master|
master.vm.network "private_network", ip: "192.168.35.1"
master.vm.provision "shell", path: "puppet-master.sh", args: "-m 'master' -h '192.168.35.1' -a '192.168.35.2 192.168.35.3'"

</pre>

**Description:**
- -m : master host name.
- -h : master host IP.
- -a : agent nodes (Required for autosign certificate)

#####2. For Agent VM

<pre>

config.vm.define "agent1" do |agent1|
agent1.vm.network "private_network", ip: "192.168.35.2"
agent1.vm.provision "shell", path: "puppet-agent.sh", args: "agent1 192.168.35.2 master 192.168.35.1"
end

</pre>


### Scripts

- puppet-master.sh : for puppet master installation and configuration while provisioning VM.
- puppetagent.sh   : for puppet agent installation and configuration while provisioning.

###How to run:

Use below command for provision VMs in single shot  with vagrant (first time it will take time because it will need to download the linux box).

<pre>
	vagrant up
</pre>

Once it is finished successfully, check the status using below command 

<pre>
	vagrant global-status
</pre>

Now we can login the VM, using below command

<pre>
	vagrant ssh master
</pre>

we can provide VM id otherwise VM name while login to instance


### Now we will turn to puppet

In puppet we need to make main site.pp into "/etc/puppet/manifiest/site.pp", which will consider module distribution by agent, look into below code for sam.

<pre>

node 'agent1.example.com'{
include gerrit

class { 'jenkins::slave':
   		 masterurl => 'http://agent3.example.com:8080',
   		 ui_user => 'adminuser',
   		 ui_pass => 'adminpass',
		}
}

node 'agent2.example.com'{
	include jenkins
	include jenkins::master
}
</pre>

###Modules
- Gerrit
- Jenkins master and slave
- Zuul
- JIRA
