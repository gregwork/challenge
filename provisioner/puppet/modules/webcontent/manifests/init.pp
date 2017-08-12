class webcontent {

  file { '/var/www/html/phpinfo.php':
    source => 'puppet:///modules/webcontent/phpinfo.php',
  }
}
