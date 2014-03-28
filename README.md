# Puppet-gitlab [![Build Status](https://travis-ci.org/sbadia/puppet-gitlab.png?branch=master)](https://travis-ci.org/sbadia/puppet-gitlab)

Tested successfully with Gitlab 6-7-stable on Ubuntu 12.04 and Debian Wheezy (7.2) with Puppet 3.2 or newer.

#### Table of contents

1. [Overview](#overview)
2. [Module description](#module-description)
3. [Parameters](#parameters)
4. [Usage](#usage)
    * [Basic usage](#basic-usage)
    * [With LDAP](#with-ldap)
5. [Limitation](#limitation)
6. [Development](#development)

# Overview

[GitLab](http://gitlab.org/) is a free project and repository management application

A [Puppet Module](http://docs.puppetlabs.com/learning/modules1.html#modules) is a collection of related content that can be used to model the configuration of a discrete service.

# Module description

This module is based on the admin guides for [gitlab](https://github.com/gitlabhq/gitlabhq/wiki), stable version.

- [puppet-gitlab](http://forge.puppetlabs.com/sbadia/gitlab) on puppet forge.

# Usage

## Use-cases

### Use-case 1

I deploy puppet-gitlab on a bare server/vm and I want that puppet-gitlab manage all things (I have no other class in my node declaration)

```puppet
node 'gitlab.fooboozoo.fr' {
  class {
    'gitlab':
      git_email         => 'notifs@foobar.fr',
      git_comment       => 'GitLab',
      gitlab_domain     => 'gitlab.foobar.fr',
      gitlab_preinstall => 'gitlab::preinstall',
      gitlab_dbtype     => 'mysql',
      gitlab_dbname     => 'gitlab_production',
      gitlab_dbuser     => 'gitlab_user',
      gitlab_dbpwd      => 'Ve4Yßtr0ngPa€w0rd',
      ldap_enabled      => false,
  }
}
```

### Use-case 2

I manage my database server and my redis server on another node (not on gitlab server)

```puppet
node 'gitlab.fooboozoo.fr' {
  class {'nginx': }

  class {
    'gitlab':
      git_email         => 'notifs@foobar.fr',
      git_comment       => 'GitLab',
      gitlab_domain     => 'gitlab.foobar.fr',
      gitlab_preinstall => 'gitlab::dummy',
      gitlab_dbtype     => 'mysql',
      gitlab_dbname     => 'gitlab_production',
      gitlab_dbuser     => 'gitlab_user',
      gitlab_dbpwd      => 'Ve4Yßtr0ngPa€w0rd',
      gitlab_dbhost     => 'db.fooboozoo.fr',
      gitlab_redishost  => 'redis.fooboozoo.fr',
      ldap_enabled      => false,
  }
}

node 'db.fooboozoo.fr' {
  class {'mysql::server':
    root_password => 'ChangeMe42',
  }

  mysql::db {'gitlab_production':
    user     => 'gitlab_user',
    password => 'Ve4Yßtr0ngPa€w0rd',
  }
}

node 'redis.fooboozoo.fr' {
  class {'redis': }
}
```

### Use-case 3

I want to manage dependency and preinstall things outside puppet-gitlab

```puppet
node 'gitlab.fooboozoo.fr' {
  class {
    'gitlab':
      git_email         => 'notifs@foobar.fr',
      git_comment       => 'GitLab',
      gitlab_domain     => 'gitlab.foobar.fr',
      gitlab_dependency => 'gitlab::dummy'
      gitlab_dbtype     => 'mysql',
      gitlab_dbname     => 'gitlab_production',
      gitlab_dbuser     => 'gitlab_user',
      gitlab_dbpwd      => 'Ve4Yßtr0ngPa€w0rd',
      ldap_enabled      => false,
  }

  class {'myrubyclass':
    ruby_version => '2.0.0',
  }

  class {'mysql::dev': }
  class {'postfix': }
}
```

## Dependencies
- [puppetlabs/puppetlabs-stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)
See [gitlab example](https://github.com/sbadia/vagrant-gitlab/blob/master/examples/gitlab.pp).

TODO

## GitLab web interface
- access via your browser under the hostname (e.g. http://gitlab.domain.tld)
- **Login**: admin@local.host
- **Password**: 5iveL!fe

1. Add an ssh key to your account, or create another account
2. Create a project
3. Play !

# Parameters

* `ensure`:  Ensure gitlab/gitlab-shell repo are present, latest. absent is not yet supported (default: present)
* `git_user`: Name of the gitlab (default: git)
* `git_home`: Home directory for gitlab repository (default: /home/git)
* `git_email`: Email address for gitlab user (default: git@someserver.net)
* `git_comment`: Gitlab user comment (default: GitLab)
* `gitlab_sources`: Gitlab sources (default: git://github.com/gitlabhq/gitlabhq.git)
* `gitlab_branch`: Gitlab branch (default: 6-7-stable)
* `gitlabshell_sources`: Gitlab-shell sources (default: git://github.com/gitlabhq/gitlab-shell.git)
* `gitlabshell_branch`: Gitlab-shell branch (default: v1.9.1)
* `gitlab_http_port`: Port that NGINX listens on for HTTP traffic (default: 80)
* `gitlab_ssl_port`: Port that NGINX listens on for HTTPS traffic (default: 443)
* `gitlab_http_timeout`: HTTP timeout in seconds (unicorn/nginx) (default: 60)
* `gitlab_redishost`: Redis host used for Sidekiq (default: localhost)
* `gitlab_redisport`: Redis host used for Sidekiq (default: 6379)
* `gitlab_dbtype`: Gitlab database type (default: mysql)
* `gitlab_dbname`: Gitlab database name (default: gitlab\_db)
* `gitlab_dbuser`: Gitlab database user (default: gitlab\_user)
* `gitlab_dbpwd`: Gitlab database password (default: changeme)
* `gitlab_dbhost`: Gitlab database host (default: localhost)
* `gitlab_dbport`: Gitlab database port (default: 3306)
* `gitlab_domain`: Gitlab domain (default $fqdn)
* `gitlab_repodir`: Gitlab repository directory (default: $git\_home)
* `gitlab_backup`: Whether to enable automatic backups (default: false)
* `gitlab_backup_path`: Path where Gitlab's backup rake task puts its files (default: tmp/backups)
* `gitlab_backup_keep_time`: Retention time of Gitlab's backups (in seconds) (default: 0 == forever)
* `gitlab_backup_time`: Time (hour) when the Gitlab backup task is run from cron (default: fqdn\_rand(5)+1)
* `gitlab_backup_postscript`: Path to one or more shell scripts to be executed after the backup (default: false)
* `gitlab_relative_url_root`: Run GitLab in a non-root path (default: false, dont't forget the first slash)
* `gitlab_ssl`: Enable SSL for GitLab (default: false)
* `gitlab_ssl_cert`: SSL Certificate location (default: /etc/ssl/certs/ssl-cert-snakeoil.pem)
* `gitlab_ssl_key`: SSL Key location (default: /etc/ssl/private/ssl-cert-snakeoil.key)
* `gitlab_ssl_self_signed`: Set true if your SSL Cert is self signed (default: false)
* `gitlab_projects`: GitLab default number of projects for new users (default: 10)
* `gitlab_username_change`: Manage username changing in GitLab (default: true)
* `gitlab_unicorn_port`: Port that unicorn listens on 172.0.0.1 for HTTP traffic (default: 8080)
* `gitlab_unicorn_worker`: Number of unicorn workers (default: 2)
* `gitlab_bundler_flags`: Flags to be passed to bundler when installing gems (default: --deployment)
* `exec_path`: PATH of executtion (default: `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`)
* `ldap_enabled`: Enable LDAP backend for gitlab web (see bellow) (default: false)
* `ldap_host`: FQDN of LDAP server (default: ldap.domain.com)
* `ldap_base`: LDAP base dn (default: dc=domain,dc=com)
* `ldap_uid`: Uid for LDAP auth (default: uid)
* `ldap_user_filter`: RFC 4515 style filter for the user (default: '')
* `ldap_port`: LDAP port (default: 636)
* `ldap_method`: Method to use (default: ssl)
* `ldap_bind_dn`: User for LDAP bind auth (default: nil)
* `ldap_bind_password`: Password for LDN bind auth (default: nil)
* `git_package_name`: Package name for git (default: git-core)
* `git_proxy`: Proxy for GIT access (default: undef)
* `ssh_port`: Port accepting SSH connections (default: 22)
* `google_analytics_id`: Google Analytics tracking ID (default: nil)

# Limitations

This module has been built on and tested against Puppet 2.7 and higher.

# Development

Want to help - send a pull request.

## Contributors

The list of contributors can be found at: [https://github.com/sbadia/puppet-gitlab/graphs/contributors](https://github.com/sbadia/puppet-gitlab/graphs/contributors)

## Development environment with vagrant

See [vagrant-gitlab](https://github.com/sbadia/vagrant-gitlab).
