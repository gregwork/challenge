class timezone (
  $timezone = "Australia/Adelaide",
) {

  exec { 'Set timezone':
    command => "timedatectl set-timezone ${timezone}",
    unless  => "timedatectl | egrep 'Time zone.+${timezone}'",
  }
}
