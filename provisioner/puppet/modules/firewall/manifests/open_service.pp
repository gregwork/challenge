define firewall::open_service {

  include firewall::reload

  exec { "firewall-cmd add-service $title":
    command => "firewall-cmd --permanent --zone=public --add-service=${title}",
    unless  => "firewall-cmd --zone=public --query-service=${title}",
    notify  => Class['firewall::reload'],
  }
}
