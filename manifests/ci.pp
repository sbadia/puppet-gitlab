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
