# == Class: gitlab
#
# === Parameters
#
# [git_user] Name of the gitlab (default: git)
# [git_home] Home directory for gitlab repository (default: /home/git)
# [git_email] Email address for gitlab user (default: git@someserver.net)
# [git_comment] Gitlab user comment (default: GitLab)
# [gitlab_sources] Gitlab sources (default: git://github.com/gitlabhq/gitlabhq.git)
# [gitlab_branch] Gitlab branch (default: 5-2-stable)
# [gitlabshell_sources] Gitlab-shell sources (default: git://github.com/gitlabhq/gitlab-shell.git)
# [gitlabshell_banch] Gitlab-shell branch (default: v1.3.0)
# [gitlab_dbtype] Gitlab database type (default: mysql)
# [gitlab_dbname] Gitlab database name (default: gitlabdb)
# [gitlab_dbuser] Gitlab database user (default: gitlabu)
# [gitlab_dbpwd] Gitlab database password (default: changeme)
# [gitlab_dbhost] Gitlab database host (default: localhost)
# [gitlab_dbport] Gitlab database port (default: 3306)
# [gitlab_domain] Gitlab domain (default $fqdn)
# [ldap_enabled] Enable LDAP backend for gitlab web (see bellow) (default: false)
# [ldap_host] FQDN of LDAP server (default: ldap.domain.com)
# [ldap_base] LDAP base dn (default: dc=domain,dc=com)
# [ldap_uid] Uid for LDAP auth (default: uid)
# [ldap_port] LDAP port (default: 636)
# [ldap_method] Method to use (default: ssl)
# [ldap_bind_dn] User for LDAP bind auth (default: nil)
# [ldap_bind_password] Password for LDN bind auth (default: nil)
#
# === Examples
#
# See examples/gitlab.pp
#
# node /gitlab/ {
#   class {
#     'gitlab':
#       git_email => 'toto@foobar'
#   }
# }
#
# === Authors
#
# Sebastien Badia <seb@sebian.fr>
# Uwe Kleinmann <uwe@kleinmann.org>
# Matt Klich <matt@elementalvoid.com>
# Steffen Roegner <steffen@sroegner.org>
#
# === Copyright
#
# See LICENSE file, Sebastien Badia (c) 2013

# Class:: gitlab
#
#
class gitlab(
    $git_user            = $gitlab::params::git_user,
    $git_home            = $gitlab::params::git_home,
    $git_email           = $gitlab::params::git_email,
    $git_comment         = $gitlab::params::git_comment,
    $gitlab_sources      = $gitlab::params::gitlab_sources,
    $gitlab_branch       = $gitlab::params::gitlab_branch,
    $gitlabshell_branch  = $gitlab::params::gitlabshell_branch,
    $gitlabshell_sources = $gitlab::params::gitlabshell_sources,
    $gitlab_dbtype       = $gitlab::params::gitlab_dbtype,
    $gitlab_dbname       = $gitlab::params::gitlab_dbname,
    $gitlab_dbuser       = $gitlab::params::gitlab_dbuser,
    $gitlab_dbpwd        = $gitlab::params::gitlab_dbpwd,
    $gitlab_dbhost       = $gitlab::params::gitlab_dbhost,
    $gitlab_dbport       = $gitlab::params::gitlab_dbport,
    $gitlab_domain       = $gitlab::params::gitlab_domain,
    $ldap_enabled        = $gitlab::params::ldap_enabled,
    $ldap_host           = $gitlab::params::ldap_host,
    $ldap_base           = $gitlab::params::ldap_base,
    $ldap_uid            = $gitlab::params::ldap_uid,
    $ldap_port           = $gitlab::params::ldap_port,
    $ldap_method         = $gitlab::params::ldap_method,
    $ldap_bind_dn        = $gitlab::params::ldap_bind_dn,
    $ldap_bind_password  = $gitlab::params::ldap_bind_password
  ) inherits gitlab::params {
  # FIXME class inheriting from params class
  case $::osfamily {
    Debian: {
      include gitlab::server
    }
    Redhat: {
      warning("${::osfamily} not fully tested with gitlab 5.0")
      include gitlab::server
    }
    default: {
      fail("${::osfamily} not supported yet")
    }
  } # case
} # Class:: gitlab
