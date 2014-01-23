# == Class: gitlab
#
# Install and configure a GitLab server using puppet.
#
# === Parameters
#
# [*ensure*]
#   Ensure present, latest. absent is not yet supported
#   default: present
#
# [*git_user*]
#   Name of gitlab user
#   default: git
#
# [*git_home*]
#   Home directory for gitlab repository
#   default: /home/git
#
# [*git_email*]
#   Email address for gitlab user
#   default: git@someserver.net
#
# [*git_comment*]
#   Gitlab user comment
#   default: GitLab
#
# [*gitlab_sources*]
#   Gitlab sources
#   default: git://github.com/gitlabhq/gitlabhq.git
#
# [*gitlab_branch*]
#   Gitlab branch
#   default: 6-5-stable
#
# [*gitlabshell_sources*]
#   Gitlab-shell sources
#   default: git://github.com/gitlabhq/gitlab-shell.git
#
# [*gitlabshell_banch*]
#   Gitlab-shell branch
#   default: v1.8.0
#
# [*gitlab_http_port*]
#   Port that NGINX listens on for HTTP traffic
#   default: 80
#
# [*gitlab_ssl_port*]
#   Port that NGINX listens on for HTTPS traffic
#   default: 443
#
# [*gitlab_http_timeout*]
#   HTTP timeout (unicorn and nginx)
#   default: 60
#
# [*gitlab_redishost*]
#   Redis host used for Sidekiq
#   default: localhost
#
# [*gitlab_redisport*]
#   Redis host used for Sidekiq
#   default: 6379
#
# [*gitlab_dbtype*]
#   Gitlab database type
#   default: mysql
#
# [*gitlab_dbname*]
#   Gitlab database name
#   default: gitlab_db
#
# [*gitlab_dbuser*]
#   Gitlab database user
#   default: gitlab_user
#
# [*gitlab_dbpwd*]
#   Gitlab database password
#   default: changeme
#
# [*gitlab_dbhost*]
#   Gitlab database host
#   default: localhost
#
# [*gitlab_dbport*]
#   Gitlab database port
#   default: 3306
#
# [*gitlab_domain*]
#   Gitlab domain
#   default: $fqdn
#
# [*gitlab_repodir*]
#   Gitlab repository directory
#   default: $git_home
#
# [*gitlab_ssl*]
#   Enable SSL for GitLab
#   default: false
#
# [*gitlab_ssl_cert*]
#   SSL Certificate location
#   default: /etc/ssl/certs/ssl-cert-snakeoil.pem
#
# [*gitlab_ssl_key*]
#   SSL Key location
#   default: /etc/ssl/private/ssl-cert-snakeoil.key
#
# [*gitlab_ssl_self_signed*]
#   Set true if your SSL Cert is self signed
#   default: false
#
# [*gitlab_projects*]
#   GitLab default number of projects for new users
#   default: 10
#
# [*gitlab_repodir*]
#   Gitlab repository directory
#   default: $git_home
#
# [*gitlab_username_change*]
#   Gitlab username changing
#   default: true
#
# [*gitlab_unicorn_port*]
#   Port that unicorn listens on 172.0.0.1 for HTTP traffic
#   (default: 8080)
#
# [*ldap_enabled*]
#   Enable LDAP backend for gitlab web (see bellow)
#   default: false
#
# [*ldap_host*]
#   FQDN of LDAP server
#   default: ldap.domain.com
#
# [*ldap_base*]
#   LDAP base dn
#   default: dc=domain,dc=com
#
# [*ldap_uid*]
#   Uid for LDAP auth
#   default: uid
#
# [*ldap_port*]
#   LDAP port
#   default: 636
#
# [*ldap_method*]
#   Method to use
#   default: ssl
#
# [*ldap_bind_dn*]
#   User for LDAP bind auth
#   default: nil
#
# [*ldap_bind_password*]
#   Password for LDN bind auth
#   default: nil
#
# [*git_package_name*]
#   Package name for git install
#   default: git-core (Debian)
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
# Steffen Roegner <steffen@sroegner.org>
# Andrew Tomaka <atomaka@gmail.com>
# Uwe Kleinmann <uwe@kleinmann.org>
# Matt Klich <matt@elementalvoid.com>
#
# === Copyright
#
# See LICENSE file
# Andrew Tomaka, Sebastien Badia, Steffen Roegner (c) 2013
#
class gitlab(
    $ensure                 = $gitlab::params::ensure,
    $git_user               = $gitlab::params::git_user,
    $git_home               = $gitlab::params::git_home,
    $git_email              = $gitlab::params::git_email,
    $git_comment            = $gitlab::params::git_comment,
    $gitlab_sources         = $gitlab::params::gitlab_sources,
    $gitlab_branch          = $gitlab::params::gitlab_branch,
    $gitlabshell_branch     = $gitlab::params::gitlabshell_branch,
    $gitlabshell_sources    = $gitlab::params::gitlabshell_sources,
    $gitlab_http_port       = $gitlab::params::gitlab_http_port,
    $gitlab_ssl_port        = $gitlab::params::gitlab_ssl_port,
    $gitlab_http_timeout    = $gitlab::params::gitlab_http_timeout,
    $gitlab_redishost       = $gitlab::params::gitlab_redishost,
    $gitlab_redisport       = $gitlab::params::gitlab_redisport,
    $gitlab_dbtype          = $gitlab::params::gitlab_dbtype,
    $gitlab_dbname          = $gitlab::params::gitlab_dbname,
    $gitlab_dbuser          = $gitlab::params::gitlab_dbuser,
    $gitlab_dbpwd           = $gitlab::params::gitlab_dbpwd,
    $gitlab_dbhost          = $gitlab::params::gitlab_dbhost,
    $gitlab_dbport          = $gitlab::params::gitlab_dbport,
    $gitlab_domain          = $gitlab::params::gitlab_domain,
    $gitlab_repodir         = $gitlab::params::gitlab_repodir,
    $gitlab_ssl             = $gitlab::params::gitlab_ssl,
    $gitlab_ssl_cert        = $gitlab::params::gitlab_ssl_cert,
    $gitlab_ssl_key         = $gitlab::params::gitlab_ssl_key,
    $gitlab_ssl_self_signed = $gitlab::params::gitlab_ssl_self_signed,
    $gitlab_projects        = $gitlab::params::gitlab_projects,
    $gitlab_username_change = $gitlab::params::gitlab_username_change,
    $gitlab_unicorn_port    = $gitlab::params::gitlab_unicorn_port,
    $gitlab_unicorn_worker  = $gitlab::params::gitlab_unicorn_worker,
    $exec_path              = $gitlab::params::exec_path,
    $ldap_enabled           = $gitlab::params::ldap_enabled,
    $ldap_host              = $gitlab::params::ldap_host,
    $ldap_base              = $gitlab::params::ldap_base,
    $ldap_uid               = $gitlab::params::ldap_uid,
    $ldap_port              = $gitlab::params::ldap_port,
    $ldap_method            = $gitlab::params::ldap_method,
    $ldap_bind_dn           = $gitlab::params::ldap_bind_dn,
    $ldap_bind_password     = $gitlab::params::ldap_bind_password,
    $git_package_name       = $gitlab::params::git_package_name,
  ) inherits gitlab::params {
  case $::osfamily {
    Debian: {}
    Redhat: {
      warning("${::osfamily} not fully tested with ${gitlab_branch}")
    }
    default: {
      fail("${::osfamily} not supported yet")
    }
  } # case

  validate_absolute_path($git_home)
  validate_absolute_path($gitlab_ssl_cert)
  validate_absolute_path($gitlab_ssl_key)

  validate_bool($gitlab_ssl)
  validate_bool($gitlab_ssl_self_signed)
  validate_bool($gitlab_username_change)
  validate_bool($ldap_enabled)

  validate_re($gitlab_dbtype, '(mysql|pgsql)', 'gitlab_dbtype is not supported')
  validate_re($gitlab_dbport, '^\d+$', 'gitlab_dbport is not a valid port')
  validate_re($ldap_port, '^\d+$', 'ldap_port is not a valid port')
  validate_re($gitlab_ssl_port, '^\d+$', 'gitlab_ssl_port is not a valid port')
  validate_re($gitlab_http_port, '^\d+$', 'gitlab_http_port is not a valid port')
  validate_re($gitlab_http_timeout, '^\d+$', 'gitlab_http_timeout is not a number')
  validate_re($gitlab_redisport, '^\d+$', 'gitlab_redisport is not a valid port')
  validate_re($ldap_method, '(ssl|tls|plain)', 'ldap_method is not supported (ssl, tls or plain)')
  validate_re($gitlab_projects, '^\d+$', 'gitlab_projects is not valid')
  validate_re($gitlab_unicorn_port, '^\d+$', 'gitlab_unicorn_port is not valid')
  validate_re($gitlab_unicorn_worker, '^\d+$', 'gitlab_unicorn_worker is not valid')
  validate_re($ensure, '(present|latest)', 'ensure is not valid (present|latest)')

  validate_string($git_user)
  validate_string($git_email)
  validate_string($git_comment)
  validate_string($gitlab_sources)
  validate_string($gitlab_branch)
  validate_string($gitlabshell_sources)
  validate_string($gitlabshell_branch)
  validate_string($gitlab_dbname)
  validate_string($gitlab_dbuser)
  validate_string($gitlab_dbpwd)
  validate_string($gitlab_dbhost)
  validate_string($ldap_base)
  validate_string($ldap_uid)
  validate_string($ldap_host)

  anchor { 'gitlab::begin': } ->
  class { '::gitlab::setup': } ->
  class { '::gitlab::package': } ->
  class { '::gitlab::install': } ->
  class { '::gitlab::config': } ->
  class { '::gitlab::service': } ->
  anchor { 'gitlab::end': }

} # Class:: gitlab
