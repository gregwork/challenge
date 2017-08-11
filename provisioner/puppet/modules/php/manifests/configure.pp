class php::configure {

  $_timezone = 'Australia/Adelaide'

  file { '/etc/php.d/zz-timezone.ini':
    content => "date.timezone=${_timezone}",
  }

}
