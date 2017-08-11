Package {
  ensure => installed
}

Service {
  ensure => running,
  enable => true,
}

node default {
  include roles::challenge
}
