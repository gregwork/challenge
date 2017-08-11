class apache {

  contain apache::install
  contain apache::service

  Class["apache::install"] ~> Class["apache::service"]

}
