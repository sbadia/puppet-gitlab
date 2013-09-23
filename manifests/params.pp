# Class:: gitlab::params
#
#
class gitlab::params {

  $git_user               = 'git'
  $git_home               = '/home/git'
  $git_email              = 'git@someserver.net'
  $git_comment            = 'GitLab'
  $gitlab_sources         = 'git://github.com/gitlabhq/gitlabhq.git'
  $gitlab_branch          = '6-0-stable'
  $gitlabshell_sources    = 'git://github.com/gitlabhq/gitlab-shell.git'
  $gitlabshell_branch     = 'v1.7.1'
  $gitlab_redishost       = 'localhost'
  $gitlab_redisport       = '6379'
  $gitlab_dbtype          = 'mysql'
  $gitlab_dbname          = 'gitladb'
  $gitlab_dbuser          = 'gitladbu'
  $gitlab_dbpwd           = 'changeme'
  $gitlab_dbhost          = 'localhost'
  $gitlab_dbport          = '3306'
  $gitlab_domain          = $::fqdn
  $gitlab_repodir         = $git_home
  $gitlab_ssl             = false
  $gitlab_ssl_cert        = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  $gitlab_ssl_key         = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $gitlab_ssl_self_signed = false
  $gitlab_projects        = '10'
  $gitlab_username_change = true
  $ldap_enabled           = false
  $ldap_host              = 'ldap.domain.com'
  $ldap_base              = 'dc=domain,dc=com'
  $ldap_uid               = 'uid'
  $ldap_port              = '636'
  $ldap_method            = 'ssl'
  $ldap_bind_dn           = ''
  $ldap_bind_password     = ''

} # Class:: gitlab::params
