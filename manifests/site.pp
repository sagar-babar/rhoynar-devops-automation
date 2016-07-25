node 'check1.example.com'{
        include jenkins
        include jenkins::master
}

node 'check2.example.com'{
include gerrit

class { 'jenkins::slave':
                 masterurl => 'http://check1.example.com:8080',
                 ui_user => 'adminuser',
                 ui_pass => 'adminpass',
                }

}

node 'node2.example.com'{

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

node 'node1.example.com'{
include zuul
}
node default{
	user {'test':
		ensure => 'present',
	}
}
