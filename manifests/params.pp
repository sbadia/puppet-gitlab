# Class:: gitlab::params
#
#
class gitlab::params {

  $ensure                   = 'present'
  $gitlab_manage_user       = true
  $gitlab_manage_home       = true
  $git_user                 = 'git'
  $git_group                = $git_user
  $git_home                 = '/home/git'
  $git_email                = 'git@someserver.net'
  $git_comment              = 'GitLab'
  $git_bin_path             = '/usr/bin/git'
  $git_max_size             = 20971520
  $git_timeout              = 10
  $gitlab_webhook_timeout   = 10
  $gitlab_sources           = 'git://github.com/gitlabhq/gitlabhq.git'
  $gitlab_branch            = '7-12-stable'
  $gitlab_git_http_server_sources = 'https://gitlab.com/gitlab-org/gitlab-git-http-server.git'
  $gitlab_git_http_server_branch = undef # specify a value here when gitlab_branch updated to 8-x
  $gitlabshell_sources      = 'git://github.com/gitlabhq/gitlab-shell.git'
  $gitlabshell_branch       = 'v2.6.3'
  $gitlabshell_log_folder   = undef
  $gitlab_log_folder        = undef
  $gitlab_uploads_folder    = undef
  $gitlab_manage_nginx      = true
  $gitlab_http_port         = '80'
  $gitlab_ssl_port          = '443'
  $gitlab_http_timeout      = '300'
  $gitlab_redishost         = '127.0.0.1'
  $gitlab_redisport         = '6379'
  $gitlab_dbtype            = 'mysql'
  $gitlab_dbname            = 'gitlab_db'
  $gitlab_dbuser            = 'gitlab_user'
  $gitlab_dbpwd             = 'changeme'
  $gitlab_dbhost            = 'localhost'
  $gitlab_dbport            = '3306'
  $gitlab_domain            = $::fqdn
  $gitlab_domain_alias      = false
  $gitlab_repodir           = $git_home
  $gitlab_satellitedir      = $git_home
  $gitlab_setup_status_dir  = $git_home
  $gitlab_backup            = false
  $gitlab_backup_path       = 'tmp/backups/'
  $gitlab_backup_keep_time  = '0'
  $gitlab_backup_time       = fqdn_rand(5)+1
  $gitlab_backup_postscript = false
  $gitlab_relative_url_root = false
  $gitlab_issue_closing_pattern = undef
  $gitlab_repository_downloads_path = 'tmp/repositories'
  $gitlab_default_projects_features_issues = true
  $gitlab_default_projects_features_merge_requests = true
  $gitlab_default_projects_features_wiki = true
  $gitlab_default_projects_features_snippets = false
  $gitlab_time_zone         = false
  $gitlab_email_enabled     = true
  $gitlab_email_reply_to    = "noreply@${gitlab_domain}"
  $gitlab_email_display_name= 'GitLab'
  $gitlab_ssl               = false
  $gitlab_ssl_protocols     = 'TLSv1.2 TLSv1.1 TLSv1'
  $gitlab_ssl_ciphers       = 'ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4'
  $gitlab_ssl_cert          = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  $gitlab_ssl_key           = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $gitlab_ssl_self_signed   = false
  $gitlab_username_change   = true
  $gitlab_unicorn_listen    = '127.0.0.1'
  $gitlab_unicorn_port      = '8080'
  $gitlab_unicorn_worker    = '2'
  $gitlab_bundler_flags     = '--deployment'
  $gitlab_bundler_jobs      = 1
  $gitlab_ensure_postfix    = true
  $gitlab_ensure_curl       = true
  $gitlab_manage_rbenv      = true
  $gitlab_ruby_version      = '2.1.6'
  $gitlab_auth_file         = "${git_home}/.ssh/authorized_keys"
  $gitlab_secret_file       = undef
  $exec_path                = "${git_home}/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  $exec_environment         = undef
  $ldap_enabled             = false
  $ldap_host                = 'ldap.domain.com'
  $ldap_base                = 'dc=domain,dc=com'
  $ldap_uid                 = 'uid'
  $ldap_user_filter         = ''
  $ldap_port                = '636'
  $ldap_method              = 'ssl'
  $ldap_bind_dn             = ''
  $ldap_bind_password       = ''
  $ldap_active_directory    = true
  $ldap_block_auto_created_users = false
  $ldap_sync_time           = 3600
  $ldap_group_base          = ''
  $ldap_sync_ssh_keys       = ''
  $ldap_admin_group         = ''
  $nginx_client_max_body_size = '20m'
  $omniauth                 = undef
  $ssh_port                 = '22'
  $google_analytics_id      = ''
  $git_proxy                = undef
  $gravatar_enabled         = true
  $use_exim                 = false
  $webserver_service_name   = 'nginx'

  # determine pre-requisite packages
  case $::osfamily {
    'Debian': {
      # system packages
      $system_packages = ['libicu-dev', 'python2.7','python-docutils',
                          'libxml2-dev', 'libxslt1-dev','python-dev',
                          'cmake', 'pkg-config', 'libkrb5-dev', 'ruby-execjs']
    }
    'RedHat': {
      # system packages
      $system_packages = ['libicu-devel', 'perl-Time-HiRes','libxml2-devel',
                          'libxslt-devel','python-devel','libcurl-devel',
                          'readline-devel','openssl-devel','zlib-devel',
                          'cmake','libyaml-devel','patch','gcc-c++']
    }
    default: {
      fail("${::osfamily} not supported yet")
    }
  }

  validate_array($system_packages)

} # Class:: gitlab::params
