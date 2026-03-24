
class web {

exec { "apt-update":
	command => "/usr/bin/apt-get update"
}

package {[
	  "php7.4",
          "php-pear",
          "php7.4-curl",
          "php7.4-gd",
          "php7.4-intl",
          "php7.4-xmlrpc",
          "php7.4-mysql",
          "apache2",
          "python3-mysqldb",
          "wget",
          "zip",
          "curl",
          "vim",
	]:
	ensure => installed,
	require => Exec["apt-update"],
}

file { '/etc/apache2/conf-available/direxpress.conf':
	ensure => present,
	owner => root,
	group => root,
	mode => '0664',
	replace => true,
	content => template('/vagrant/manifests/direxpress.conf'),
	require => Package["apache2"],
	notify => Service['apache2'],
}

file { "/etc/apache2/sites-available/express.conf":
        ensure => present,
        owner => root,
        group => root,
        mode => '0664',
        replace => true,
        content => template("/vagrant/manifests/express.conf"),
        require => Package["apache2"],
        notify => Service['apache2'],
}

file { "/etc/hosts":
        ensure => present,
        owner => root,
        group => root,
        mode => '0664',
        replace => true,
        content => template("/vagrant/manifests/hosts.conf"),
}

file { '/srv/www':
	ensure => 'directory',
	owner => 'root',
	group => 'www-data',
	mode => '2750',
}

#exec {"wget-express.zip":
#	cwd => '/tmp',
#	command => "/usr/bin/wget --no-check-certificate http://forceclass-00.linuxforce.com.br/express/express.zip",
#	creates => "/tmp/express.zip",
#	require => Package["wget"],
#	refreshonly => true,
#}


archive { '/tmp/express.zip':
	source => 'http://forceclass-00.linuxforce.com.br/express/express.zip',
	extract => true,
	extract_path => '/srv/www',
	user => 'root',
	group => 'www-data',
	cleanup => false,
}

#exec {"unzip":
#        cwd => '/srv/www',
#        command => "/usr/bin/unzip /tmp/express.zip -d /srv/www",
#        require => Package["zip"],
#        creates => "/tmp/express.zip",
#        refreshonly => true,
#}

service { 'apache2':
	ensure => running,
	enable => true,
	hasrestart => true,
	restart => true,
	require => Package['apache2'],
}

exec { 'a2ensite express':
	path => ['/usr/bin', '/usr/sbin' ,],
	provider => shell,
	require => Service["apache2"],
}


exec { 'a2enconf direxpress':
        path => ['/usr/bin', '/usr/sbin', ],
        provider => shell,
        require => Service["apache2"],
}

exec { 'a2enmod vhost_alias':
        path => ['/usr/bin', '/usr/sbin', ],
        provider => shell,
        require => Service["apache2"],
}

exec { 'a2enmod php7.4':
        path => ['/usr/bin', '/usr/sbin', ],
        provider => shell,
        require => Service["apache2"],
}

}

include web
