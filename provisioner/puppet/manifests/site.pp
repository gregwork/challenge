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

node default {
  include roles::challenge
}
