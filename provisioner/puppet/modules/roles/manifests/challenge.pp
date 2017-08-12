class roles::challenge {

  include profiles::timezone
  include profiles::webserver
  include profiles::challenge_web_content

}
