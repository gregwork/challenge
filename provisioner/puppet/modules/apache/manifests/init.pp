class apache {

  contain apache::install
  contain apache::service
  contain apache::firewall

  Class['apache::install'] ~> Class['apache::service'] -> Class['apache::firewall']

}
