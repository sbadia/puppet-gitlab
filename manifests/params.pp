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
  $gitlab_sources           = 'git://github.com/gitlabhq/gitlabhq.git'
  $gitlab_branch            = '6-9-stable'
  $gitlabshell_sources      = 'git://github.com/gitlabhq/gitlab-shell.git'
  $gitlabshell_branch       = 'v1.9.4'
  $gitlab_manage_nginx      = true
  $gitlab_http_port         = '80'
  $gitlab_ssl_port          = '443'
  $gitlab_http_timeout      = '60'
  $gitlab_redishost         = '127.0.0.1'
  $gitlab_redisport         = '6379'
  $gitlab_dbtype            = 'mysql'
  $gitlab_dbname            = 'gitlab_db'
  $gitlab_dbuser            = 'gitlab_user'
  $gitlab_dbpwd             = 'changeme'
  $gitlab_dbhost            = 'localhost'
  $gitlab_dbport            = '5432'
  $gitlab_domain            = $::fqdn
  $gitlab_domain_alias      = false
  $gitlab_repodir           = $git_home
  $gitlab_backup            = false
  $gitlab_backup_path       = 'tmp/backups/'
  $gitlab_backup_keep_time  = '0'
  $gitlab_backup_time       = fqdn_rand(5)+1
  $gitlab_backup_postscript = false
  $gitlab_relative_url_root = false
  $gitlab_ssl               = false
  $gitlab_ssl_cert          = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  $gitlab_ssl_key           = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $gitlab_ssl_self_signed   = false
  $gitlab_projects          = '10'
  $gitlab_username_change   = true
  $gitlab_unicorn_listen    = '127.0.0.1'
  $gitlab_unicorn_port      = '8080'
  $gitlab_unicorn_worker    = '2'
  $gitlab_bundler_flags     = '--deployment'
  $gitlab_bundler_jobs      = 1
  $gitlab_ensure_postfix    = true
  $gitlab_ensure_curl       = true
  $gitlab_ruby_version      = '2.1.2'
  $exec_path                = "${git_home}/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  $ldap_enabled             = false
  $ldap_host                = 'ldap.domain.com'
  $ldap_base                = 'dc=domain,dc=com'
  $ldap_uid                 = 'uid'
  $ldap_user_filter         = ''
  $ldap_port                = '636'
  $ldap_method              = 'ssl'
  $ldap_bind_dn             = ''
  $ldap_bind_password       = ''
  $ssh_port                 = '22'
  $google_analytics_id      = ''
  $git_proxy                = undef
  $company_logo_url         = ''
  $company_link             = ''
  $company_name             = ''
  $use_exim                 = false
  $webserver_service_name   = 'nginx'

  # determine pre-requisite packages
  case $::osfamily {
    'Debian': {
      # system packages
      $system_packages = ['libicu-dev', 'python2.7','python-docutils',
                          'libxml2-dev', 'libxslt1-dev','python-dev']
    }
    'RedHat': {
      # system packages
      $system_packages = ['libicu-devel', 'perl-Time-HiRes','libxml2-devel',
                          'libxslt-devel','python-devel','libcurl-devel',
                          'readline-devel','openssl-devel','zlib-devel',
                          'libyaml-devel','patch','gcc-c++']
    }
    default: {
      fail("${::osfamily} not supported yet")
    }
  }

  validate_array($system_packages)

} # Class:: gitlab::params
