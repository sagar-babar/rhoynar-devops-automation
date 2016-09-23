# Rhoynar-DevOps-Automation

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

Here we are provisioning **five** virtual machines into virtual box using vagrant, follow the below instructions to provisioning.
* Chnage directory where *Vagrantfile* is placed.
* Ensure that both *puppet-master.sh* and *puppet-agent.sh* is present in same location.

Make the below  necessary changes in Vagranfile (if required e.g if you want to change ip addresses for nodes)

##### 1. For Master VM:

```
config.vm.define "master" do |master|
master.vm.network "private_network", ip: "192.168.35.1"
master.vm.provision "shell", path: "puppet-master.sh", args: "-m 'master' -H '192.168.35.1' -a 'agent' -h '192.168.35.2 192.168.35.3 192.168.35.4 192.168.35.5'"
```

**Description:**
- -m : master host name.
- -h : master host IP.
- -a : agent nodes (Required for autosign certificate)

##### 2. For Agent VM

```
config.vm.define "agent1" do |agent1|
agent1.vm.network "private_network", ip: "192.168.35.2"
agent1.vm.provision "shell", path: "puppet-agent.sh", args: "-m 'master' -H '192.168.35.1' -a 'agent' -h '192.168.35.2 192.168.35.3 192.168.35.4 192.168.35.5' -i 'agent1'"
end
```

Repeat the same steps in other agents by replacing the agent name.

### Scripts

- [puppet-master.sh][master] : for puppet master installation and configuration while provisioning VM.
- [puppet-agent.sh][agent]   : for puppet agent installation and configuration while provisioning.

[master]: https://raw.githubusercontent.com/sagarinitcron/rhoynar-devops-automation/master/rhoynar-provision-puppetsetup/master-ss.sh
[agent]: https://raw.githubusercontent.com/sagarinitcron/rhoynar-devops-automation/master/rhoynar-provision-puppetsetup/agent-ss.sh

### How to run:

Use below command for provision VMs in single shot  with vagrant (first time it will take time because it will need to download the linux box).

```
	vagrant up
```

Once it is finished successfully, check the status using below command

```
	vagrant global-status
```

Now we can login the VM, using below command

```
	vagrant ssh master
```

we can provide VM id otherwise VM name while login to instance


### Now we will turn to puppet

In puppet we need to make main site.pp into "/etc/puppet/manifiest/site.pp", which will consider module distribution by agent, look into below code for sample.Visit this [link](https://raw.githubusercontent.com/sagarinitcron/rhoynar-devops-automation/master/) to check the complete code.

```

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
```

### Overview

Let us have an overview of our instances,

|Instance|Name|Purpose|Private IP's|
|:---:|:---:|:---:|:---:|
|1|Master|Puppet Master will be Installed|192.168.35.1|
|2|Agent1|Jira|192.168.35.2|
|3|Agent2|Jenkins|192.168.35.3|
|4|Agent3|Gerrit|192.168.35.4|
|5|Agent4|Zuul|192.168.35.5|

---

# MODULES

Let us explore each modules for detailed understanding,

## JIRA

As per our puppet module JIRA will be installed on *Agent1*

* Once puppet agent installs JIRA vist the url on port 8080 [*192.168.35.2:8080*](https://192.168.35.2:8080)

Setup JIRA by using the simple GUI as follows

* Choose Application name and Mode

  ![1](images/1.png)

* Choose how do you want to use JIRA

  ![2](images/2.png)

* Specify your JIRA License Key

  ![3](images/3.png)

* Setup Administrator account

  ![4](images/4.png)

* Configure mail id, avatar and finish installation with basic intro to JIRA. Once you're done with everything you can see JIRA dashboard.

  ![5](images/5.png)

---
## Jenkins master and slave

Puppet Module will install Jenkins on Agent2, visit the instance IP with port 8080 to configure Jenkins [*192.168.35.2:8080*](https://192.168.35.2:8080)

* Initiall password will be automatically generated in the following location */var/lib/jenkins/secrets/initialAdminPassword*

* Login to the instance and copy paste the password.

  ![6](images/6.png)

* Proceed with installing the basic required plugins for Jenkins.

* Manually Setup new administrator *username* and *password* for administrator account.

  ![7](images/7.png)

* Now Jenkins is ready.

  ![8](images/8.png)

---

## Gerrit

Gerrit is a code review tool which will be installed in Agent3 by puppet module.

Visit the following IP with port 8090 to configure Gerrit.

---

## Zuul

Puppet module will install Zuul in Agent4. Zuul is a pipeline oriented project gating and automation system.

---

# SITE.PP

Let us dig deep in each resource of site.pp

## Agent1 - JIRA

In this resource part the *Jira class* for installing JIRA and *postgresql class* for db server is configured along with username and password.

![a1](images/a1.png)

---

## Agent2 - Jenkins

In agent2 resource part Jenkins modules are included along with credentials of JIRA for integration as follows,

![a2](images/a2.png)

---

## Agent3 - Gerrit

Gerrit class is included in agent3 resource part with jenkins slave configuration for integration as shown below,

![a3](images/a3.png)

---

## Agent4 - Zuul

Resource part for agent4 includes Zuul with the following specifications for proper integration,

![a4](images/a4.png)

---
