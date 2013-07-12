# Class:: gitlab::pre
#
#
class gitlab::pre(
  $git_comment         = $gitlab::git_comment,
  $git_home            = $gitlab::git_home,
  $git_user            = $gitlab::git_user,
  $gitlab_dbtype       = $gitlab::gitlab_dbtype,
  $mysql_dev_pkg_names = $gitlab::mysql_dev_pkg_names,
  $pg_dev_pkg_names    = $gitlab::pg_dev_pkg_names
  ) {

  include gitlab



  user {
    $git_user:
      ensure     => present,
      shell      => '/bin/bash',
      password   => '*',
      home       => $git_home,
      comment    => $git_comment,
      system     => true;
  }

  file {
    $git_home:
      ensure  => directory,
      owner   => $git_user,
      group   => $git_user,
      require => User[$git_user],
      mode    => '0755',
  }

  # try and decide about the family here,
  # deal with version/dist specifics within the class
  case $::osfamily {
    'Debian': {
      $db_packages = $gitlab_dbtype ? {
        mysql => $mysql_dev_pkg_names,
        pgsql => $pg_dev_pkg_names,
      }

      file {
        '/usr/bin/python2':
          ensure => link,
          target => '/usr/bin/python';
      }

      package {
        ['libicu-dev','python2.7',
          'libxml2-dev','libxslt1-dev','python-dev']:
            ensure  => installed;
      }

      if !defined(Package['git-core']) {
        package { 'git-core': ensure => present; }
      }
      if !defined(Package['postfix']) {
        package { 'postfix': ensure => present; }
      }
    } # Debian pre-requists
    'Redhat': {
      $db_packages = $gitlab_dbtype ? {
        mysql => $mysql_dev_pkg_names,
        pgsql => $pg_dev_pkg_names,
      }
      $devel_pkgs = [ 'libcurl-devel', 'libicu-devel', 'libxml2-devel', 'libxslt-devel', 'libyaml-devel', 'openssl-devel', 'perl-Time-HiRes', 'python-devel', 'readline-devel', 'zlib-devel' ]
      $compilers  = [ 'gcc', 'gcc-c++' ]
      @package { $devel_pkgs:
        ensure   => 'latest',
        provider => 'yum',
        tag      => 'rhel-dev-pkgs'
      }
      @package { $compilers:
        ensure => 'present',
        provider => 'yum',
        tag      => 'rhel-compiler-pkgs'
      }
      Package <| tag == 'rhel-dev-pkgs' |>
      Package <| tag == 'rhel-compiler-pkgs' |>

      if !defined(Package['postfix']){
        package{ 'postfix': ensure => 'present';}
      }
      #requirements not handled by this module
      #mysql setup (can be satiated with puppetlabs-mysql)
      #redis (can be satiated with )
      #nginx (can be satiated with puppetlabs-nginx)



    } # Redhat pre-requists
    default: {
      err "${::osfamily} not supported yet"
    }
  }

  package {
    $db_packages:
      ensure   => installed;
  }

  if !defined(Package['openssh-server']) {
    package { 'openssh-server': ensure => present; }
  }
  if !defined(Package['git']) {
    package { 'git': ensure => present; }
  }
  if !defined(Package['curl']) {
    package { 'curl': ensure => present; }
  }
} # Class:: gitlab::pre
