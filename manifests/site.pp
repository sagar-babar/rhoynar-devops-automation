node 'agent1.example.com'{
        include jenkins
        include jenkins::master
}

node 'agent2.example.com'{

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

node 'agent3.example.com'{
class { 'jenkins::slave':
                 masterurl => 'http://check1.example.com:8080',
                 ui_user => 'adminuser',
                 ui_pass => 'adminpass',
                } ->
class { 'gerrit': }
}
node default{
	user {'test':
		ensure => 'present',
	}
}
