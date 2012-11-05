# Class:: gitlab::params
#
#
class gitlab::params {
  $git_user           = 'git'
  $git_home           = '/home/git'
  $git_email          = 'git@someserver.net'
  $git_comment        = 'git version control'
  $git_admin_pubkey   = '#Not configured'
  $git_admin_privkey  = '#Not configured'
  $ssh_key_provider   = 'source'
  $gitlab_user        = 'gitlab'
  $gitlab_home        = '/home/gitlab'
  $gitlab_comment     = 'gitlab system'
  $gitlab_sources     = 'git://github.com/gitlabhq/gitlabhq.git'
  $gitlab_branch      = 'stable'
  $gitlab_dbtype      = 'sqlite'
  $ldap_enabled       = false
  $ldap_host          = 'ldap.domain.com'
  $ldap_base          = 'dc=domain,dc=com'
  $ldap_uid           = 'uid'
  $ldap_port          = '636'
  $ldap_method        = 'ssl'
  $ldap_bind_dn       = ''
  $ldap_bind_password = ''
} # Class:: gitlab::params
