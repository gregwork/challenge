Package {
  ensure => installed
}

Service {
  ensure => running,
  enable => true,
}

File {
  ensure => present,
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
}

Exec {
  path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin',
}

node default {
  include roles::challenge
}
