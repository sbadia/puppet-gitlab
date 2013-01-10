shared_context "gitlab_shared", :a => :b do

  def global_gitlab_variables
   "$git_user           = 'git'
    $git_home           = '/home/git'
    $git_email          = 'git@someserver.net'
    $git_comment        = 'git version control'
    $git_admin_pubkey   = '#Not configured'
    $git_admin_privkey  = '#Not configured'
    $ssh_key_provider   = 'source'
    $gitlab_user        = 'gitlab'
    $gitlab_home        = '/home/gitlab'
    $gitlab_comment     = 'gitlab system'
    $gitlab_sources     = 'git://github.com/gitlabhq/gitlabhq.git'
    $gitlab_branch      = 'stable'
    $gitolite_sources   = 'git://github.com/gitlabhq/gitolite.git'
    $gitolite_branch    = 'gl-v320'
    $gitlab_dbtype      = 'mysql'
    $gitlab_dbname      = 'gitladb'
    $gitlab_dbuser      = 'gitladbu'
    $gitlab_dbpwd       = 'changeme'
    $ldap_enabled       = false
    $ldap_host          = 'ldap.domain.com'
    $ldap_base          = 'dc=domain,dc=com'
    $ldap_uid           = 'uid'
    $ldap_port          = '636'
    $ldap_method        = 'ssl'
    $ldap_bind_dn       = ''
    $ldap_bind_password = ''"
  end

end
