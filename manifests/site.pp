node 'agent1.example.com'{
		class { 'postgresql::server': } ->

		postgresql::server::db { 'jira':
	 			user     => 'jiraadm',
	  		password => postgresql_password('jiraadm', 'mypassword'),
	 	} ->

		file { '/usr/java/':
	  		ensure => 'directory',
	  } ->

		java::oracle { 'jdk8' :
	  		ensure  => 'present',
				version => '8',
	  		java_se => 'jdk',
		} ->

		class { 'jira':
	 			javahome    => '/usr/java/jdk1.8.0_51',
	 	}
}

node 'agent2.example.com'{
	    include jenkins
    	    include jenkins::master
    	    jenkins::plugin { 'gerrit-trigger': }
	    jenkins::plugin { '	build-timeout': }
	    jenkins::plugin { 'jira-trigger	': }
	    jenkins::plugin { 'workflow-aggregator': }
}

node 'agent3.example.com'{
		class { 'jenkins::slave':
    		masterurl => 'http://agent2.example.com:8080',
    		ui_user => 'adminuser',
    		ui_pass => 'adminpass',
		} ->

		class { 'gerrit': }
}

node 'agent4.example.com'{
		class { 'zuul':
				gerrit_server => 'agent3.example.com',
				gerrit_user => 'testuser',
				gerrit_baseurl => 'http://agent3.example.com:8090',
				zuul_ssh_private_key => '/var/lib/zuul/ssh/id_rsa',
		}->

		class { 'zuul::launcher':
				ensure => 'running',
		}->

		class {	'zuul::merger':
				ensure => 'running',
    }->

		class { 'zuul::server':
				ensure => 'running',
				layout_dir => '/etc/zuul/layout/',
		}~>

		exec { 'zuul-restart':
				command => '/etc/init.d/zuul restart && /etc/init.d/zuul-merger restart',
				refreshonly => true,
#				path => ['/usr/local/bin/zuul'],
		}
		class { 'zuul::params':
        		project_name => 'project-one',
        		jobs_name => 'dev-unit-tests-before-merge',
        		jenkins_url => 'http://agent2.example.com:8080',
        		jenkins_username => 'admin',
        		jenkins_password => 'password',
        		node => 'master',
        		zuul_cloner_url => 'http://agent2.example.com:8090',
		}
}

node default{
		user {'test':
				ensure => 'present',
		}
}


