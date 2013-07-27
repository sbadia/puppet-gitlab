# Class gitlab::input_validation
#
#  This class simply performs input validation on all the class parameters.
#  It helps keep the main init class clean
#
class gitlab::input_validation inherits gitlab {
  #Input Validation
  validate_string($git_user)
  validate_string($git_home)
  validate_string($git_email)
  if $git_email == 'git@someserver.net' {
    fail('$git_email is not set. Please set the email parameter')
  }
  validate_string($git_comment)
  validate_string($gitlab_sources)
  validate_string($gitlab_branch)
  validate_string($gitlabshell_branch)
  validate_string($gitlabshell_sources)
  validate_string($gitlab_dbtype)
  validate_string($gitlab_dbname)
  validate_string($gitlab_dbuser)
  validate_string($gitlab_dbpwd)
  if $gitlab_dbpwd == 'changeme' {
    fail('$gitlab_dbpwd is not set. Please set the gitlab db password')
  }
  validate_string($gitlab_dbhost)
  validate_string($gitlab_dbport)
  validate_string($gitlab_domain)
  validate_string($gitlab_repodir)
  validate_string($gitlab_projects)
  validate_string($nginx_service_name)

  validate_bool($gitlab_ssl)
  validate_bool($ldap_enabled)
  if $gitlab_ssl {
    if $gitlab_ssl_cert { validate_string($gitlab_ssl_cert) }
    else {fail("gitlab_ssl is true, but gitlab_ssl_cert is invalid")}

    if $gitlab_ssl_key  { validate_string($gitlab_ssl_key) }
    else {fail("gitlab_ssl is true, but gitlab_ssl_key is invalid")}
  }

  if $ldap_enabled {
    if $ldap_host { validate_string($ldap_host) }
    if $ldap_base { validate_string($ldap_base) }
    if $ldap_uid { validate_string($ldap_uid) }
    if $ldap_port { validate_string($ldap_port) }
    if $ldap_method { validate_string($ldap_method) }
    if $ldap_bind_dn { validate_string($ldap_bind_dn) }
    if $ldap_bind_password { validate_string($ldap_bind_password) }
  }

  validate_array($mysql_dev_pkg_names)
  validate_array($pg_dev_pkg_names)
} # Class:: gitlab
