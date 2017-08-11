class php {

  contain php::install
  contain php::configure

  Class['php::install'] -> Class['php::configure']
}
