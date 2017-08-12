class profiles::webserver {

  include apache
  include php

  Class['php'] ~> Class['apache']

}
