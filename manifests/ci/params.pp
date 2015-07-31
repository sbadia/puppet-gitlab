# Class:: gitlab::ci::params
#
#
class gitlab::ci::params {

  $ensure                     = 'present'
  $ci_user                    = 'gitlab_ci'
  $ci_home                    = '/home/gitlab_ci'
  $ci_comment                 = 'GitLab CI'
  $ci_email                   = 'gitlab-ci@localhost'
  $gitlabci_sources           = 'git://github.com/gitlabhq/gitlab-ci.git'
  $gitlabci_branch            = '5-0-stable'
  $gitlabci_manage_nginx      = true
  $gitlabci_http_port         = '80'
  $gitlabci_ssl_port          = '443'
  $gitlabci_http_timeout      = '60'
  $gitlabci_redishost         = '127.0.0.1'
  $gitlabci_redisport         = '6379'
  $gitlabci_dbtype            = 'mysql'
  $gitlabci_dbname            = 'gitlabci_db'
  $gitlabci_dbuser            = 'gitlabci_user'
  $gitlabci_dbpwd             = 'changeme'
  $gitlabci_dbhost            = 'localhost'
  $gitlabci_dbport            = '5432'
  $gitlabci_domain            = $::fqdn
  $gitlabci_domain_alias      = false
  $gitlabci_repodir           = $ci_home
  $gitlabci_relative_url_root = false
  $gitlabci_ssl               = false
  $gitlabci_ssl_cert          = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  $gitlabci_ssl_key           = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $gitlabci_ssl_self_signed   = false
  $gitlabci_projects          = '10'
  $gitlabci_username_change   = true
  $gitlabci_unicorn_listen    = '127.0.0.1'
  $gitlabci_unicorn_port      = '8081'
  $gitlabci_unicorn_worker    = '2'
  $gitlabci_bundler_flags     = '--deployment'
  $gitlabci_bundler_jobs      = 1
  $exec_path                  = "${ci_home}/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  $gitlab_ruby_version        = '2.1.6'

} # Class:: gitlab::ci::params
