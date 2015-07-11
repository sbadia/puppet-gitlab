# == Class: gitlab::ci
#
# Install and configure a GitLab CI server using puppet.
#
# === Parameters
#
# [*gitlab_server_urls*]
#   Fqdn or hostname of gitlab servers (array style)
#   default: []
#
# [*ensure*]
#   Ensure present, latest. absent is not yet supported
#   default: present
#
# [*ci_user*]
#   Name of gitlab CI user
#   default: gitlab_ci
#
# [*ci_home*]
#   Home directory for gitlab CI
#   default: /home/gitlab_ci
#
# [*ci_email*]
#   Email address for gitlab CI user
#   default: gilab-ci@localhost
#
# [*ci_comment*]
#   Gitlab CI user comment
#   default: GitLab CI
#
# [*gitlabci_sources*]
#   Gitlab CI sources
#   default: git://github.com/gitlabhq/gitlabhq-ci.git
#
# [*gitlabci_branch*]
#   Gitlab CI branch
#   default: 5-0-stable
#
# [*proxy_name*]
#   The name of the Nginx proxy
#   default: 'gitlab-ci'
#
# [*gitlab_ruby_version*]
#   Ruby version to install with rbenv for Gitlab user
#   default: 2.1.6
#
# [*gitlab_manage_nginx*]
#   Whether or not this module should install a templated Nginx
#   configuration; set to false to manage separately
#   default: true
#
# [*exec_path*]
#   The default PATH passed to all exec ressources (this path include rbenv shims)
#   default: '${git_home}/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
#
# [*gitlab_http_port*]
#   Port that NGINX listens on for HTTP traffic
#   default: 80
#
# [*gitlab_ssl_port*]
#   Port that NGINX listens on for HTTPS traffic
#   default: 443
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
# [*gitlab_http_timeout*]
#   HTTP timeout (unicorn and nginx)
#   default: 60
#
# [*gitlab_relative_url_root*]
#   run in a non-root path
#   default: /
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
# [*bundler_flags*]
#   Flags that should be passed to bundler when installing gems
#   default: --deployment
#
# [*bundler_jobs*]
#   Number of jobs to use while installing gems.  Should match number of
#   procs on your system (default: 1)
#
class gitlab::ci(
  $gitlab_server_urls       = [],
  $ensure                   = $gitlab::ci::params::ensure,
  $ci_user                  = $gitlab::ci::params::ci_user,
  $ci_comment               = $gitlab::ci::params::ci_comment,
  $ci_email                 = $gitlab::ci::params::ci_email,
  $ci_home                  = $gitlab::ci::params::ci_home,
  $gitlabci_sources         = $gitlab::ci::params::gitlabci_sources,
  $gitlabci_branch          = $gitlab::ci::params::gitlabci_branch,
  $gitlab_manage_nginx      = $gitlab::ci::params::gitlabci_manage_nginx,
  $proxy_name               = 'gitlab-ci',
  $gitlab_ruby_version      = $gitlab::ci::params::gitlab_ruby_version,
  $exec_path                = $gitlab::ci::params::exec_path,
  $gitlab_http_port         = $gitlab::ci::params::gitlabci_http_port,
  $gitlab_ssl_port          = $gitlab::ci::params::gitlabci_ssl_port,
  $gitlab_ssl               = $gitlab::ci::params::gitlabci_ssl,
  $gitlab_ssl_cert          = $gitlab::ci::params::gitlabci_ssl_cert,
  $gitlab_ssl_key           = $gitlab::ci::params::gitlabci_ssl_key,
  $gitlab_ssl_self_signed   = $gitlab::ci::params::gitlabci_ssl_self_signed,
  $gitlab_http_timeout      = $gitlab::ci::params::gitlabci_http_timeout,
  $gitlab_relative_url_root = $gitlab::ci::params::gitlab_relative_url_root,
  $gitlab_redishost         = $gitlab::ci::params::gitlabci_redishost,
  $gitlab_redisport         = $gitlab::ci::params::gitlabci_redisport,
  $gitlab_dbtype            = $gitlab::ci::params::gitlabci_dbtype,
  $gitlab_dbname            = $gitlab::ci::params::gitlabci_dbname,
  $gitlab_dbuser            = $gitlab::ci::params::gitlabci_dbuser,
  $gitlab_dbpwd             = $gitlab::ci::params::gitlabci_dbpwd,
  $gitlab_dbhost            = $gitlab::ci::params::gitlabci_dbhost,
  $gitlab_dbport            = $gitlab::ci::params::gitlabci_dbport,
  $gitlab_domain            = $gitlab::ci::params::gitlabci_domain,
  $gitlab_domain_alias      = $gitlab::ci::params::gitlab_domain_alias,
  $gitlab_unicorn_listen    = $gitlab::ci::params::gitlabci_unicorn_listen,
  $gitlab_unicorn_port      = $gitlab::ci::params::gitlabci_unicorn_port,
  $gitlab_unicorn_worker    = $gitlab::ci::params::gitlabci_unicorn_worker,
  $bundler_flags            = $gitlab::ci::params::gitlabci_bundler_flags,
  $bundler_jobs             = $gitlab::ci::params::gitlabci_bundler_jobs,
) inherits gitlab::ci::params {

  anchor { 'gitlab::ci::begin': } ->
  class { '::gitlab::ci::setup': } ->
  class { '::gitlab::ci::package': } ->
  class { '::gitlab::ci::install': } ->
  class { '::gitlab::ci::config': } ->
  class { '::gitlab::ci::service': } ->
  anchor { 'gitlab::ci::end': }
}
