class zuul::params (
$project_name = '',
$jobs_name = '',
$jenkins_url = '',
$jenkins_username = '',
$jenkins_password = '',
$node = '',
$zuul_cloner_url = '',
)  {

file { ['/etc/jenkins_jobs/','/etc/jenkins_jobs/jobs/']:
    ensure  => directory,
    }
    
file { '/etc/jenkins_jobs/jenkins_jobs.ini':
    ensure  => present,
    mode    => '0644',
    content => template('zuul/jenkins_jobs.ini.erb'),
    require => File['/etc/jenkins_jobs/'],
  }


file { '/etc/jenkins_jobs/jobs/jjb.yaml':
    ensure  => present,
    mode    => '0644',
    content => template('zuul/jjb.yaml.erb'),
    require => File['/etc/jenkins_jobs/jobs'],
  }

file { '/etc/zuul/layout/layout.yaml':
    ensure  => present,
    mode    => '0644',
    content => template('zuul/layout.yaml.erb'),
  }
  
}
