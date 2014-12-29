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
# [*git_group*]
#   Name of gitlab group
#   default: $git_user
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
# [*gitlab_manage_user*]
#   Whether to manage the Gitlab user account
#   default: true
#
# [*gitlab_manage_home*]
#   Whether to manage the Gitlab user's home directory
#   default: true
#
# [*gitlab_sources*]
#   Gitlab sources
#   default: git://github.com/gitlabhq/gitlabhq.git
#
# [*gitlab_branch*]
#   Gitlab branch
#   default: 6-9-stable
#
# [*gitlabshell_sources*]
#   Gitlab-shell sources
#   default: git://github.com/gitlabhq/gitlab-shell.git
#
# [*gitlabshell_branch*]
#   Gitlab-shell branch
#   default: v1.9.4
#
# [*proxy_name*]
#   The name of the Nginx proxy
#   default: 'gitlab'
#
# [*gitlab_manage_nginx*]
#   Whether or not this module should install a templated Nginx
#   configuration; set to false to manage separately
#   default: true
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
# [*gitlab_domain_alias*]
#   Gitlab domain aliases for nginx
#   default: false (does not configure any alias)
#   examples: "hostname1" or "hostname1 hostname2 hostname3.example.com"
#
# [*gitlab_repodir*]
#   Gitlab repository directory
#   default: $git_home
#
# [*gitlab_backup*]
#   Whether to enable automatic backups
#   dbackup efault: false
#
# [*gitlab_backup_path*]
#   Path where Gitlab's backup rake task puts its files
#   default: 'tmp/backups' (relative to $git_home)
#
# [*gitlab_backup_keep_time*]
#   Retention time of Gitlab's backups (in seconds)
#   default: 0 (forever)
#
# [*gitlab_backup_time*]
#   Time when the Gitlab backup task is run from cron
#   default: fqdn_rand(5)+1
#
# [*gitlab_backup_postscript*]
#   Path to one or more shell scripts to be executed after the backup
#   default: false
#
# [*gitlab_relative_url_root*]
#   run in a non-root path
#   default: /
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
# [*gitlab_unicorn_listen*]
#   IP address that unicorn listens on
#   default: 127.0.0.1
#
# [*gitlab_unicorn_port*]
#   Port that unicorn listens on 172.0.0.1 for HTTP traffic
#   default: 8080
#
# [*gitlab_unicorn_worker*]
#   The number of unicorn worker
#   default: 2
#
# [*gitlab_bundler_flags*]
#   Flags that should be passed to bundler when installing gems
#   default: --deployment
#
# [*gitlab_ruby_version*]
#   Ruby version to install with rbenv for Gitlab user
#   default: 2.1.2
#
# [*exec_path*]
#   The default PATH passed to all exec ressources (this path include rbenv shims)
#   default: '${git_home}/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
#
# [*gitlab_bundler_jobs*]
#   Number of jobs to use while installing gems.  Should match number of
#   procs on your system (default: 1)
#
# [*gitlab_ensure_postfix*]
#   Whether or not this module should ensure the postfix package is
#   installed (used to manage conflicts with other modules)
#   default: true
#
# [*gitlab_ensure_curl*]
#   Whether or not this module should ensure the curl package is
#   installed (used to manage conflicts with other modules)
#   default: true
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
# [*ldap_user_filter*]
#   RFC 4515 style filter
#   default: ''
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
# [*ssh_port*]
#   Port accepting ssh connections
#   default: 22
#
# [*google_analytics_id*]
#   Google analytics tracking ID
#   default: nil
#
# [*git_proxy*]
#   Proxy for git access
#   default: ''
#
# [*company_logo_url*]
#   Url to the company logo to be diplayed at the bottom of the sign_in page
#   default: ''
#
# [*company_link*]
#   Link to the company displayed under the logo of the company
#   default: ''
#
# [*company_name*]
#   Name of the company displayed under the logo of the company
#   default: ''
#
# [*use_exim*]
#   Apply a fix for compatibility with exim as explained at github.com/gitlabhq/gitlabhq/issues/4866
#   default: false
#
# [*webserver_service_name*]
#   Name of webserver service (nginx, apache2)
#   default: nginx
#
# [*system_packages*]
#   Packages that Gitlab needs to work, and that will be managed by the Gitlab module
#   default: $gitlab::params::system_packages
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
# See https://github.com/sbadia/puppet-gitlab/graphs/contributors
#
# === Copyright
#
# See LICENSE file
#
class gitlab(
    $ensure                   = $gitlab::params::ensure,
    $git_user                 = $gitlab::params::git_user,
    $git_group                = $git_user,
    $git_home                 = $gitlab::params::git_home,
    $git_email                = $gitlab::params::git_email,
    $git_comment              = $gitlab::params::git_comment,
    $gitlab_manage_user       = $gitlab::params::gitlab_manage_user,
    $gitlab_manage_home       = $gitlab::params::gitlab_manage_home,
    $gitlab_sources           = $gitlab::params::gitlab_sources,
    $gitlab_branch            = $gitlab::params::gitlab_branch,
    $gitlabshell_branch       = $gitlab::params::gitlabshell_branch,
    $gitlabshell_sources      = $gitlab::params::gitlabshell_sources,
    $gitlab_manage_nginx      = $gitlab::params::gitlab_manage_nginx,
    $proxy_name               = 'gitlab',
    $gitlab_http_port         = $gitlab::params::gitlab_http_port,
    $gitlab_ssl_port          = $gitlab::params::gitlab_ssl_port,
    $gitlab_http_timeout      = $gitlab::params::gitlab_http_timeout,
    $gitlab_redishost         = $gitlab::params::gitlab_redishost,
    $gitlab_redisport         = $gitlab::params::gitlab_redisport,
    $gitlab_dbtype            = $gitlab::params::gitlab_dbtype,
    $gitlab_dbname            = $gitlab::params::gitlab_dbname,
    $gitlab_dbuser            = $gitlab::params::gitlab_dbuser,
    $gitlab_dbpwd             = $gitlab::params::gitlab_dbpwd,
    $gitlab_dbhost            = $gitlab::params::gitlab_dbhost,
    $gitlab_dbport            = $gitlab::params::gitlab_dbport,
    $gitlab_domain            = $gitlab::params::gitlab_domain,
    $gitlab_domain_alias      = $gitlab::params::gitlab_domain_alias,
    $gitlab_repodir           = $gitlab::params::gitlab_repodir,
    $gitlab_backup            = $gitlab::params::gitlab_backup,
    $gitlab_backup_path       = $gitlab::params::gitlab_backup_path,
    $gitlab_backup_keep_time  = $gitlab::params::gitlab_backup_keep_time,
    $gitlab_backup_time       = $gitlab::params::gitlab_backup_time,
    $gitlab_backup_postscript = $gitlab::params::gitlab_backup_postscript,
    $gitlab_relative_url_root = $gitlab::params::gitlab_relative_url_root,
    $gitlab_ssl               = $gitlab::params::gitlab_ssl,
    $gitlab_ssl_cert          = $gitlab::params::gitlab_ssl_cert,
    $gitlab_ssl_key           = $gitlab::params::gitlab_ssl_key,
    $gitlab_ssl_self_signed   = $gitlab::params::gitlab_ssl_self_signed,
    $gitlab_projects          = $gitlab::params::gitlab_projects,
    $gitlab_username_change   = $gitlab::params::gitlab_username_change,
    $gitlab_unicorn_listen    = $gitlab::params::gitlab_unicorn_listen,
    $gitlab_unicorn_port      = $gitlab::params::gitlab_unicorn_port,
    $gitlab_unicorn_worker    = $gitlab::params::gitlab_unicorn_worker,
    $gitlab_bundler_flags     = $gitlab::params::gitlab_bundler_flags,
    $gitlab_bundler_jobs      = $gitlab::params::gitlab_bundler_jobs,
    $gitlab_ensure_postfix    = $gitlab::params::gitlab_ensure_postfix,
    $gitlab_ensure_curl       = $gitlab::params::gitlab_ensure_curl,
    $gitlab_ruby_version      = $gitlab::params::gitlab_ruby_version,
    $exec_path                = $gitlab::params::exec_path,
    $ldap_enabled             = $gitlab::params::ldap_enabled,
    $ldap_host                = $gitlab::params::ldap_host,
    $ldap_base                = $gitlab::params::ldap_base,
    $ldap_uid                 = $gitlab::params::ldap_uid,
    $ldap_user_filter         = $gitlab::params::ldap_user_filter,
    $ldap_port                = $gitlab::params::ldap_port,
    $ldap_method              = $gitlab::params::ldap_method,
    $ldap_bind_dn             = $gitlab::params::ldap_bind_dn,
    $ldap_bind_password       = $gitlab::params::ldap_bind_password,
    $ssh_port                 = $gitlab::params::ssh_port,
    $google_analytics_id      = $gitlab::params::google_analytics_id,
    $git_proxy                = $gitlab::params::git_proxy,
    $webserver_service_name   = $gitlab::params::webserver_service_name,
    $system_packages          = $gitlab::params::system_packages,
    # Deprecated params
    $git_package_name         = undef,
    $company_logo_url         = $gitlab::params::company_logo_url,
    $company_link             = $gitlab::params::company_link,
    $company_name             = $gitlab::params::company_name,
    $use_exim                 = $gitlab::params::use_exim,
  ) inherits gitlab::params {
  case $::osfamily {
    'Debian','Redhat': {}
    default: {
      fail("${::osfamily} not supported yet")
    }
  } # case

  # Deprecated params
  if $git_package_name {
    warning('The git_package_name parameter is deprecated and has no effect.')
  }

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
  validate_re($gitlab_bundler_jobs, '^\d+$', 'gitlab_bundler_jobs is not valid')
  validate_re($ensure, '(present|latest)', 'ensure is not valid (present|latest)')
  validate_re($ssh_port, '^\d+$', 'ssh_port is not a valid port')

  if !is_ip_address($gitlab_unicorn_listen){
      fail("${gitlab_unicorn_listen} is not a valid IP address")
  }

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
  validate_string($gitlab_bundler_flags)
  validate_string($ldap_base)
  validate_string($ldap_uid)
  validate_string($ldap_host)
  validate_string($google_analytics_id)
  validate_string($company_logo_url)
  validate_string($company_link)
  validate_string($company_name)

  anchor { 'gitlab::begin': } ->
  class { '::gitlab::setup': } ->
  class { '::gitlab::package': } ->
  class { '::gitlab::install': } ->
  class { '::gitlab::config': } ->
  class { '::gitlab::service': } ->
  anchor { 'gitlab::end': }

} # Class:: gitlab
