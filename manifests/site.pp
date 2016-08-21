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
}

node 'agent3.example.com'{
		class { 'jenkins::slave':
    		masterurl => 'http://agent2.example.com:8080',
    		ui_user => 'adminuser',
    		ui_pass => 'adminpass',
		} ->

		class { 'gerrit': }
}

node 'agent5.example.com'{
		class { 'zuul':
				gerrit_server => '54.193.7.210',
				gerrit_user => 'abhi',
				gerrit_baseurl => 'http://54.193.7.210:8090',
				zuul_ssh_private_key => '-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA02xYzcS+FbJAPJkXDMRDHn4ePTI0DSgoc6MzmIWoFqTgsiWH
37VepaGb14vxSpHKTB8TwWOIPnMoS4GAdO8Bzww5B5wMkHLNcxWgu+W0mHKAsVaY
KUhdYu9hoFn8aFf7WfIvq2hNWklTrg4DRp0zqvgQNqOXuaeOBM9PGOBrSWKX0viO
U9QutuD81dyF5rYUyfpwB5MtCtcyfmfePzgP5XwHidM0CPUtQE4PulpZaAXIbUNJ
3nnO65DlZdGnDOY436krOd0x26BtWBsMiYN0SCBq8kYLVyqDDLUs/1IVXpzwM/CT
Q4ax4btwqEoKEygibrmq2+tukb+0gHNrecjrqwIDAQABAoIBAG5Kexj8pVyUHEaA
ZjHWwFzL1eJ+qgCjDlckr+nE76bAZCcKxRLCfplQ8QdEjZ8k5q9HFvsvfQd283JQ
ID7f38WuzqFVmohQGzUJ90uNzOQp91CLp90BTxYpYnhP+QhFvW1ylcOJKbELx4do
7/SKVUW/GlYmiSPkcIW5z71edRlWTmqzyHDKE1yn+C0+jg4bbKk9alhueL4SyLr9
G+xhePydxUH6GowecJEevq+kMcwV6bwYniMMSWmrc/gFNgEjQ6W8HifbnShSsJqw
5Hfi/qvx3cVG9VknrKX1Ebj3E1R2Nv6mPfngvEzBIzENhJuiiCa3X3FJUoUhDv77
d4o2lEECgYEA9MXJxNzwpWQcIjogx09M2jK7pNXAR7Q7XD6LUz2pjNKqYaC6MqIH
o3itEaZ3m0gxF1Z5sd3ejXyPnt/MU++aKqVOgs7YMEuQ57QAK09tWqaz2xVuvFHZ
lPRCyzEN7bzNzfBp6VL/2QdrCskF7G7xhpHsU4G+/BaWkkE7Nlq3xlkCgYEA3R71
MhUi8ZiIQTcDonYnOUxCgslnqKbDj/BTOJjN0gLseJhSY791bOjKej2tW31+NOSR
/G8cfsK+j17ssF4S5ra3euQh30xPbsb853N6euw106aIVeEBsYUwlHB6/qlBb1Lp
gDcpzL2y+HDjNWKBR+XKkcihh/fiU4SKQdagiaMCgYB/qmGwgiQpv2tFFthd3CiT
bf6c3LfrLj//vsdgZTr3rjEbtn8nRYeCZcCvAgpEPYUNTRcwBC690Qf/r26dIM1i
DNJEO6pali9ACoxECqtYqrYIQMd/BZncrQHhhPZk1yLolMpI3fd/tPTJrUufo8Xp
kFaYv4Vjakyif89obCyKEQKBgBSRXJ1b+fQfDA2E4IGsG9nojgc8VLgLSwWIhTUu
gXaXbweIo6FDndiTjsHwGr/33FVvLWUdsLjZxH/xhHKjTX7IYCi+L6hloL3dJIki
5LGqZxdY1jWmyFGK4gnsrIQjmkKQo8eZWfoBazRQy9GbaAsYBM+qqdvL4vGB0ppt
LGGhAoGBAIA0aciEDLo3sJbqjSkjtfQslCeJzk35kKSmk8ayNF4yHiomZFnBU57T
bvk/FZCVxUzaCJJlT1OI6eyO3nJ/XcHOHPy716xHehmM2w/K076Yo1EVg4JCAOyN
/r5UF/Vs6K6qorD5u0yVAdnN10oAWjxMKcrYUrovY+hRk02kLg+9
-----END RSA PRIVATE KEY-----
',
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
}

node default{
		user {'test':
				ensure => 'present',
		}
}
