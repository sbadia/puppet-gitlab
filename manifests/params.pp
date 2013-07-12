# Class:: gitlab::params
#
#
class gitlab::params {
  $git_comment         = 'GitLab'
  $git_email           = 'git@someserver.net'
  $git_home            = '/home/git'
  $git_user            = 'git'
  $gitlab_branch       = '5-3-stable'
  $gitlab_dbhost       = 'localhost'
  $gitlab_dbname       = 'gitladb'
  $gitlab_dbport       = '3306'
  $gitlab_dbpwd        = 'changeme'
  $gitlab_dbtype       = 'mysql'
  $gitlab_dbuser       = 'gitladbu'
  $gitlab_domain       = $::fqdn
  $gitlab_projects     = '10'
  $gitlab_repodir      = $git_home
  $gitlab_sources      = 'git://github.com/gitlabhq/gitlabhq.git'
  $gitlab_ssl          = false
  $gitlab_ssl_cert     = '/etc/ssl/certs/ss-cert-snakeoil.pem'
  $gitlab_ssl_key      = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $gitlabshell_branch  = 'v1.5.0'
  $gitlabshell_sources = 'git://github.com/gitlabhq/gitlab-shell.git'
  $ldap_base           = 'dc=domain,dc=com'
  $ldap_bind_dn        = ''
  $ldap_bind_password  = ''
  $ldap_enabled        = false
  $ldap_host           = 'ldap.domain.com'
  $ldap_method         = 'ssl'
  $ldap_port           = '636'
  $ldap_uid            = 'uid'
  case $::osfamily {
    RedHat: {
      $mysql_dev_pkg_names = ['mysql-devel']
      $pg_dev_pkg_names    = ['postgresql-devel']
    }
    Debian: {
      $mysql_dev_pkg_names = ['libmysql++-dev','libmysqlclient-dev']
      $pg_dev_pkg_names    = ['libpq-dev', 'postgresql-client']
    }
    default: {}
  }

} # Class:: gitlab::params
