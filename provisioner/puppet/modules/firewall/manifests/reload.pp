class firewall::reload {

  exec { "firewall-cmd reload":
    command     => "firewall-cmd --reload",
    refreshonly => true,
  }
}
