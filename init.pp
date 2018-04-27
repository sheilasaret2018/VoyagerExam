class voyagerexam::exercise {
	package { 'vim':
		ensure => 'installed',
		allow_virtual => 'true',
		before => Package['curl'],
	}
	package { 'curl':
		ensure => 'installed',
		require => Package['vim'],
	}
	package { 'git':
		ensure => 'installed',
		require => Package['curl'],
	}
	user { 'monitor':
		ensure => 'present',
		home => '/home/monitor',
		shell => '/bin/bash',
		managehome => true,
	}
	file { '/home/monitor/scripts':
		ensure => 'directory',
		require => User['monitor'],
	}
	exec { 'memory_check_file':
        	command => 'wget https://raw.githubusercontent.com/sheilasaret2018/VoyagerExam/master/memory_check',
        	path => '/usr/bin:/usr/sbin:/bin',
        	creates => '/home/monitor/scripts/memory_check',
        	cwd => '/home/monitor/scripts/',
        	logoutput => 'true',
		require => File['/home/monitor/scripts'],
	}
	file { '/home/monitor/src':
        	ensure => 'directory',
		before => Exec['symlink_creation'],
	}
	exec { 'symlink_creation':
	        command => 'ln -s /home/monitor/scripts/memory_check my_memory_check',
        	path => '/usr/bin:/usr/sbin:/bin',
        	cwd => '/home/monitor/src',
        	logoutput => 'true',
		require => [
			File['/home/monitor/src'],
			Exec['memory_check_file'],
		],
	}
        cron { 'my_memory_check':
                ensure => 'present',
                command => '/home/monitor/src/my_memory_check',
                minute => '*/10',
                hour => '*',
                user => 'root',
		require => Exec['symlink_creation'],
        }
        file { '/etc/localtime':
                ensure => 'link',
                target => '/usr/share/zoneinfo/Asia/Manila',
        }
}

