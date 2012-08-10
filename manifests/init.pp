# == Class: gitlab
#
# === Parameters
#
# [git_user] Name of the gitolite user (for ssh)
# [git_home] Home directory for gitolite repository
# [git_email] Email address for gitolite user
# [git_comment] Gitolite user comment
# [git_admin_pubkey] Gitolite admin ssh public key (required)
# [git_admin_privkey] Gitolite admin ssh private key (required)
# [ssh_key_provider] Type of provider for ssh keys (source/content)(default source)
# [gitlab_user] Name of gitlab user
# [gitlab_home] Home directory for gitlab installation
# [gitlab_comment] Gitlab comment
# [gitlab_sources] Gitlab sources (github)
# [gitlab_dbtype] Gitlab database type (sqlite/mysql)
# [ldap_enabled] Enable LDAP backend for gitlab web (see bellow)
# [ldap_title] Name of LDAP configuration
# [ldap_host] FQDN of LDAP server
# [ldap_base] LDAP base dn
# [ldap_uid] Uid for LDAP auth
# [ldap_port] LDAP port
# [ldap_method] Method to use (ssl)
# [ldap_bind_dn] User for LDAP bind auth
# [ldap_bind_password] Password for LDN bind auth
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
# Matt Klich (<matt@elementalvoid.com>)
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
    $ssh_key_provider   = $gitlab::params::ssh_key_provider,
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
