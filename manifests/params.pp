# Class:: gitlab::params
#
#
class gitlab::params {

  $ensure                 = 'present'
  $git_user               = 'git'
  $git_home               = '/home/git'
  $git_email              = 'git@someserver.net'
  $git_comment            = 'GitLab'
  $gitlab_sources         = 'git://github.com/gitlabhq/gitlabhq.git'
  $gitlab_branch          = '6-5-stable'
  $gitlabshell_sources    = 'git://github.com/gitlabhq/gitlab-shell.git'
  $gitlabshell_branch     = 'v1.8.0'
  $gitlab_http_port       = '80'
  $gitlab_ssl_port        = '443'
  $gitlab_http_timeout    = '60'
  $gitlab_redishost       = '127.0.0.1'
  $gitlab_redisport       = '6379'
  $gitlab_dbtype          = 'mysql'
  $gitlab_dbname          = 'gitlab_db'
  $gitlab_dbuser          = 'gitlab_user'
  $gitlab_dbpwd           = 'changeme'
  $gitlab_dbhost          = 'localhost'
  $gitlab_dbport          = '5432'
  $gitlab_domain          = $::fqdn
  $gitlab_repodir         = $git_home
  $gitlab_ssl             = false
  $gitlab_ssl_cert        = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  $gitlab_ssl_key         = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $gitlab_ssl_self_signed = false
  $gitlab_projects        = '10'
  $gitlab_username_change = true
  $gitlab_unicorn_port    = '8080'
  $gitlab_unicorn_worker  = '2'
  $exec_path              = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
  $ldap_enabled           = false
  $ldap_host              = 'ldap.domain.com'
  $ldap_base              = 'dc=domain,dc=com'
  $ldap_uid               = 'uid'
  $ldap_port              = '636'
  $ldap_method            = 'ssl'
  $ldap_bind_dn           = ''
  $ldap_bind_password     = ''


  # determine pre-requisite packages
  case $::osfamily {
    'Debian': {
      $git_package_name = 'git-core'
      # system packages
      $system_packages = ['libicu-dev', 'python2.7','python-docutils',
                          'libxml2-dev', 'libxslt1-dev','python-dev']
    }
    'RedHat': {
      $git_package_name = 'git'
      # system packages
      $system_packages = ['libicu-devel', 'perl-Time-HiRes','libxml2-devel',
                          'libxslt-devel','python-devel','libcurl-devel',
                          'readline-devel','openssl-devel','zlib-devel',
                          'libyaml-devel','patch','gcc-c++']
    }
    default: {
      fail("${::osfamily} not supported yet")
    }
  }

  validate_array($system_packages)

} # Class:: gitlab::params
