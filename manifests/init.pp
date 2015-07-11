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
# [*git_bin_path*]
#   Path to git binary.
#   default: /usr/bin/git
#
# [*git_max_size*]
#   Maximum memory size grit can use, given in number of bytes per git object (e.g. a commit)
#   default: 5242880 (5MB)
#
# [*git_timeout*]
#   Git timeout to read a commit, in seconds
#   default: 10
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
#   default: 7-12-stable
#
# [*gitlabshell_sources*]
#   Gitlab-shell sources
#   default: git://github.com/gitlabhq/gitlab-shell.git
#
# [*gitlabshell_branch*]
#   Gitlab-shell branch
#   default: v2.6.3
#
# [*gitlabshell_log_folder*]
#   Gitlab-shell log folder
#   default: the gitlab-shell root directory
#
# [*gitlab_log_folder*]
#   Gitlab rails log folder
#   default: ${git_home}/gitlab/log
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
# [*gitlab_webhook_timeout*]
#   Number of seconds to wait for HTTP response after sending webhook
#   HTTP POST request
#   default: 10
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
# [*gitlab_issue_closing_pattern*]
#   If a commit message matches this regular expression, all issues referenced from the matched text will be closed.
#   This happens when the commit is pushed or merged into the default branch of a project.
#   default: '([Cc]lose[sd]|[Ff]ixe[sd]) #(\d+)' on GitLab-CE
#
# [*gitlab_repository_downloads_path*]
#   When a user clicks e.g. 'Download zip' on a project, a temporary zip file is
#   created in the following directory (relative to the root of the Rails app)
#   default: tmp/repositories
#
# [*gitlab_restricted_visibility_levels*]
#   Restrict setting visibility levels for non-admin users.
#   Specify as an array of one or more of "private" | "internal" | "public"
#   default: nil
#
# [*gitlab_default_projects_features_issues*]
#   Default project features setting for issues.
#   default: true
#
# [*gitlab_default_projects_features_merge_requests*]
#   Default project features setting for merge requests.
#   default: true
#
# [*gitlab_default_projects_features_wiki*]
#   Default project features settings for wiki.
#   default: true
#
# [*gitlab_default_projects_features_wall*]
#   Default project features setting for wall.
#   default: false
#
# [*gitlab_default_projects_features_snippets*]
#   Default project features setting for snippets.
#   default: false
#
# [*gitlab_default_projects_features_visibility_level*]
#   Default project features settings for visibility level. ("private" | "internal" | "public")
#   default: private
#
# [*gitlab_email_enabled*]
#   Set to false if you need to disable email sending from GitLab
#   default: true
#
# [*gitlab_email_reply_to*]
#   Reply-to address for emails sent by GitLab
#   default: noreply@<gitlab_domain>
#
# [*gitlab_email_display_name*]
#   Sender display name for emails sent by GitLab
#   default: GitLab
#
# [*gitlab_support_email*]
#   Email address of your support contact
#   default: support@local.host
#
# [*gitlab_time_zone*]
#   Default time zone of GitLab application
#   default: UTC
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
# [*gitlab_ssl_protocols*]
#   Nginx SSL enabled protocols
#   default: 'TLSv1.2 TLSv1.1 TLSv1'
#
# [*gitlab_ssl_ciphers*]
#   Nginx SSL enabled ciphers
#   default: 'AES:HIGH:!aNULL:!RC4:!MD5:!ADH:!MDF'
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
# [*gitlab_satellitedir*]
#   Directory for Gitlab satellites
#   default: $git_home
#
# [*gitlab_setup_status_dir*]
#   Directory where the Puppet module can store a status file to
#   indicate whether the GitLab database has already been initialized.
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
# [*gitlab_manage_rbenv*]
#   Whether this module should use rbenv to install a suitable version of Ruby
#   for the Gitlab user; set to false to use the system Ruby or manage separately
#   default: true
#
# [*gitlab_ruby_version*]
#   Ruby version to install with rbenv for the Gitlab user
#   default: 2.1.6
#
# [*gitlab_secret_file*]
#   File that contains the secret key for verifying access for gitlab-shell.
#   default: '.gitlab_shell_secret' relative to Rails.root (i.e. root of the GitLab app).
#
# [*gitlab_auth_file*]
#   File used as authorized_keys for gitlab user
#   default: ${git_home}/.ssh/authorized_keys
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
# [*ldap_active_directory*]
#   This setting specifies if LDAP server is Active Directory LDAP server.
#   For non AD servers it skips the AD specific queries.
#   If your LDAP server is not AD, set this to false.
#   default: true
#
# [*ldap_block_auto_created_users*]
#   To maintain tight control over the number of active users on your GitLab installation,
#   enable this setting to keep new users blocked until they have been cleared by the admin
#   default: false
#
# [*ldap_sync_time*]
#   This setting controls the amount of time between LDAP permission checks for each user.
#   default: nil
#
# [*ldap_group_base*]
#   Base where we can search for groups.
#   default: nil
#
# [*ldap_sync_ssh_keys*]
#   Name of attribute which holds a ssh public key of the user object.
#   If false or nil, SSH key syncronisation will be disabled.
#   default: nil
#
# [*ldap_admin_group*]
#   LDAP group of users who should be admins in GitLab.
#   default: nil
#
# [*issues_tracker*]
#   External issues trackers. Provide a hash with all issues_tracker configuration as would
#   appear in gitlab.yaml. E.g. { redmine => { title => "Redmine", project_url => ... } }
#   default: nil
#
# [*omniauth*]
#   Omniauth configuration. Provide a hash with all omniauth configuration as would
#   appear in gitlab.yaml. E.g. { enabled => true, providers => [ { name => "github", app_id => ... }]}
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
# [*gravatar_enabled*]
#   Use user avatar image from Gravatar.com
#   default: true
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
    $git_bin_path             = $gitlab::params::git_bin_path,
    $git_max_size             = $gitlab::params::git_max_size,
    $git_timeout              = $gitlab::params::git_timeout,
    $gitlab_webhook_timeout   = $gitlab::params::gitlab_webhook_timeout,
    $gitlab_manage_user       = $gitlab::params::gitlab_manage_user,
    $gitlab_manage_home       = $gitlab::params::gitlab_manage_home,
    $gitlab_sources           = $gitlab::params::gitlab_sources,
    $gitlab_branch            = $gitlab::params::gitlab_branch,
    $gitlabshell_branch       = $gitlab::params::gitlabshell_branch,
    $gitlabshell_sources      = $gitlab::params::gitlabshell_sources,
    $gitlabshell_log_folder   = $gitlab::params::gitlabshell_log_folder,
    $gitlab_log_folder        = $gitlab::params::gitlab_log_folder,
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
    $gitlab_satellitedir      = $git_home,
    $gitlab_setup_status_dir  = $git_home,
    $gitlab_backup            = $gitlab::params::gitlab_backup,
    $gitlab_backup_path       = $gitlab::params::gitlab_backup_path,
    $gitlab_backup_keep_time  = $gitlab::params::gitlab_backup_keep_time,
    $gitlab_backup_time       = $gitlab::params::gitlab_backup_time,
    $gitlab_backup_postscript = $gitlab::params::gitlab_backup_postscript,
    $gitlab_relative_url_root = $gitlab::params::gitlab_relative_url_root,
    $gitlab_issue_closing_pattern = $gitlab::params::gitlab_issue_closing_pattern,
    $gitlab_repository_downloads_path = $gitlab::params::gitlab_repository_downloads_path,
    $gitlab_restricted_visibility_levels = $gitlab::params::gitlab_restricted_visibility_levels,
    $gitlab_default_projects_features_issues = $gitlab::params::gitlab_default_projects_features_issues,
    $gitlab_default_projects_features_merge_requests = $gitlab::params::gitlab_default_projects_features_merge_requests,
    $gitlab_default_projects_features_wiki = $gitlab::params::gitlab_default_projects_features_wiki,
    $gitlab_default_projects_features_wall = $gitlab::params::gitlab_default_projects_features_wall,
    $gitlab_default_projects_features_snippets = $gitlab::params::gitlab_default_projects_features_snippets,
    $gitlab_default_projects_features_visibility_level = $gitlab::params::gitlab_default_projects_features_visibility_level,
    $gitlab_time_zone         = $gitlab::params::gitlab_time_zone,
    $gitlab_email_enabled     = $gitlab::params::gitlab_email_enabled,
    $gitlab_email_reply_to    = "noreply@${gitlab_domain}",
    $gitlab_email_display_name= $gitlab::params::gitlab_email_display_name,
    $gitlab_support_email     = $gitlab::params::gitlab_support_email,
    $gitlab_ssl               = $gitlab::params::gitlab_ssl,
    $gitlab_ssl_cert          = $gitlab::params::gitlab_ssl_cert,
    $gitlab_ssl_key           = $gitlab::params::gitlab_ssl_key,
    $gitlab_ssl_protocols     = $gitlab::params::gitlab_ssl_protocols,
    $gitlab_ssl_ciphers       = $gitlab::params::gitlab_ssl_ciphers,
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
    $gitlab_manage_rbenv      = $gitlab::params::gitlab_manage_rbenv,
    $gitlab_ruby_version      = $gitlab::params::gitlab_ruby_version,
    $gitlab_secret_file       = $gitlab::params::gitlab_secret_file,
    $gitlab_auth_file         = "${git_home}/.ssh/authorized_keys",
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
    $ldap_active_directory    = $gitlab::params::ldap_active_directory,
    $ldap_block_auto_created_users = $gitlab::params::ldap_block_auto_created_users,
    $ldap_sync_time           = $gitlab::params::ldap_sync_time,
    $ldap_group_base          = $gitlab::params::ldap_group_base,
    $ldap_sync_ssh_keys       = $gitlab::params::ldap_sync_ssh_keys,
    $ldap_admin_group         = $gitlab::params::ldap_admin_group,
    $issues_tracker           = $gitlab::params::issues_tracker,
    $omniauth                 = $gitlab::params::omniauth,
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
    $gravatar_enabled         = $gitlab::params::gravatar_enabled,
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
  validate_bool($gitlab_default_projects_features_issues)
  validate_bool($gitlab_default_projects_features_merge_requests)
  validate_bool($gitlab_default_projects_features_wiki)
  validate_bool($gitlab_default_projects_features_wall)
  validate_bool($gitlab_default_projects_features_snippets)

  validate_re($gitlab_dbtype, '(mysql|pgsql)', 'gitlab_dbtype is not supported')
  validate_re("${gitlab_dbport}", '^\d+$', 'gitlab_dbport is not a valid port')
  validate_re("${ldap_port}", '^\d+$', 'ldap_port is not a valid port')
  validate_re("${gitlab_ssl_port}", '^\d+$', 'gitlab_ssl_port is not a valid port')
  validate_re("${gitlab_http_port}", '^\d+$', 'gitlab_http_port is not a valid port')
  validate_re("${gitlab_http_timeout}", '^\d+$', 'gitlab_http_timeout is not a number')
  validate_re("${gitlab_redisport}", '^\d+$', 'gitlab_redisport is not a valid port')
  validate_re($ldap_method, '(ssl|tls|plain)', 'ldap_method is not supported (ssl, tls or plain)')
  validate_re("${gitlab_projects}", '^\d+$', 'gitlab_projects is not valid')
  validate_re("${gitlab_unicorn_port}", '^\d+$', 'gitlab_unicorn_port is not valid')
  validate_re("${gitlab_unicorn_worker}", '^\d+$', 'gitlab_unicorn_worker is not valid')
  validate_re("${gitlab_bundler_jobs}", '^\d+$', 'gitlab_bundler_jobs is not valid')
  validate_re($ensure, '(present|latest)', 'ensure is not valid (present|latest)')
  validate_re("${ssh_port}", '^\d+$', 'ssh_port is not a valid port')
  validate_re($gitlab_default_projects_features_visibility_level, 'private|internal|public','gitlab_default_projects_features_visibility_level is not valid')

  if !is_ip_address($gitlab_unicorn_listen){
      fail("${gitlab_unicorn_listen} is not a valid IP address")
  }

  if $gitlab_restricted_visibility_levels {
    validate_array($gitlab_restricted_visibility_levels)
  }
  if $omniauth {
    validate_hash($omniauth)
  }
  if $issues_tracker {
    validate_hash($issues_tracker)
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
