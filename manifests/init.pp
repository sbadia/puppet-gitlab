# == Class: gitlab
#
# === Parameters
#
# [git_user] Name of the gitolite user (for ssh)
# [git_home] Home directory for gitolite repository
# [git_email] Email address for gitolite user
# [git_comment] Gitolite user comment
# [git_adminkey] Gitolite admin ssh key (required)
# [gitlab_user] Name of gitlab user
# [gitlab_home] Home directory for gitlab installation
# [gitlab_comment] Gitlab comment
# [gitlab_sources] Gitlab sources (github)
# [gitlab_dbtype] Gitlab database type (sqlite/mysql)
#
# === Examples
#
# See examples/gitlab.pp
#
# node /gitlab/ {
#   class {
#     'gitlab':
#       git_adminkey => 'ssh-rsa AAA...'
#   }
# }
#
# === Authors
#
# Sebastien Badia (<seb@sebian.fr>)
#
# === Copyright
#
# Sebastien Badia © 2012
# Tue Jul 03 20:06:33 +0200 2012

# Class:: gitlab
#
#
class gitlab(
    $git_user           = $gitlab::params::git_user,
    $git_home           = $gitlab::params::git_home,
    $git_email          = $gitlab::params::git_email,
    $git_comment        = $gitlab::params::git_comment,
    $git_admin_pubkey   = $gitlab::params::git_admin_pubkey,
    $git_admin_privkey  = $gitlab::params::git_admin_privkey,
    $gitlab_user        = $gitlab::params::gitlab_user,
    $gitlab_home        = $gitlab::params::gitlab_home,
    $gitlab_comment     = $gitlab::params::gitlab_comment,
    $gitlab_sources     = $gitlab::params::gitlab_sources,
    $gitlab_branch      = $gitlab::params::gitlab_branch,
    $gitlab_dbtype      = $gitlab::params::gitlab_dbtype,
    $ldap_enabled       = $gitlab::params::ldap_enabled,
    $ldap_title         = $gitlab::params::ldap_title,
    $ldap_host          = $gitlab::params::ldap_host,
    $ldap_base          = $gitlab::params::ldap_base,
    $ldap_uid           = $gitlab::params::ldap_uid,
    $ldap_port          = $gitlab::params::ldap_port,
    $ldap_method        = $gitlab::params::ldap_method,
    $ldap_bind_dn       = $gitlab::params::ldap_bind_dn,
    $ldap_bind_password = $gitlab::params::ldap_bind_password
  ) inherits gitlab::params {
  case $operatingsystem {
    debian,ubuntu: {
      include "gitlab::gitlab"
    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  } # case
} # Class:: gitlab
