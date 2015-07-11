# Puppet-gitlab

[![Build Status](https://travis-ci.org/sbadia/puppet-gitlab.png?branch=master)](https://travis-ci.org/sbadia/puppet-gitlab)
[![Puppet Forge](http://img.shields.io/puppetforge/v/sbadia/gitlab.svg)](https://forge.puppetlabs.com/sbadia/gitlab)
[![License](http://img.shields.io/:license-gpl3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0.html)

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

## Dependencies
- [alup/puppet-rbenv](https://github.com/alup/puppet-rbenv)
- [puppetlabs/puppetlabs-git](https://github.com/puppetlabs/puppetlabs-git)
- [puppetlabs/puppetlabs-stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)
- [puppetlabs/puppetlabs-vcsrepo](https://github.com/puppetlabs/puppetlabs-vcsrepo)

See [gitlab example](https://github.com/sbadia/vagrant-gitlab/blob/master/examples/gitlab.pp).

## GitLab web interface
- access via your browser under the hostname (e.g. http://gitlab.domain.tld)
- **Login**: admin@local.host
- **Password**: 5iveL!fe

1. Add an ssh key to your account, or create another account
2. Create a project
3. Play !

# Parameters

See [manifest/init.pp](https://github.com/sbadia/puppet-gitlab/blob/master/manifests/init.pp) and [manifests/params.pp](https://github.com/sbadia/puppet-gitlab/blob/master/manifests/params.pp)

# Usage

_Note:_ Assume that a database server is already installed on your server/infrastructure (see: [vagrant-gitlab](https://github.com/sbadia/vagrant-gitlab/blob/master/examples/gitlab.pp)).

## class gitlab

```puppet
class {
  'gitlab':
    git_email         => 'notifs@foobar.fr',
    git_comment       => 'GitLab',
    gitlab_domain     => 'gitlab.foobar.fr',
    gitlab_dbtype     => 'mysql',
    gitlab_dbname     => $gitlab_dbname,
    gitlab_dbuser     => $gitlab_dbuser,
    gitlab_dbpwd      => $gitlab_dbpwd,
    ldap_enabled      => false,
}
```

## class gitlab::ci

```puppet
class { 'gitlab::ci':
  ci_comment         => 'GitLab',
  gitlab_server_urls => ['https://gitlab.example.org']
  gitlab_domain      => $gitlab_domain,
  gitlab_dbtype      => 'mysql',
  gitlab_dbname      => $ci_dbname,
  gitlab_dbuser      => $ci_dbuser,
  gitlab_dbpwd       => $ci_dbpwd,
  gitlab_http_port   => 8081,
}
```

## class gitlab::ci::runner

```puppet
# The registration token can be found at: http://ci.example.com/admin/runners, accessible through Header > Runners.
class { 'gitlab::ci::runner':
  ci_server_url      => 'https://ci.example.com',
  registration_token => 'replaceme',
}
```
## A Complete example

```puppet
include redis
include nginx
include mysql::server
include git
include logrotate

mysql::db {'gitlab': user => 'user', password => 'password' }

class {'gitlab':
  git_user                 => 'git',
  git_home                 => '/home/git',
  git_email                => 'gitlab@fooboozoo.fr',
  git_comment              => 'GitLab',
  gitlab_sources           => 'https://github.com/gitlabhq/gitlabhq.git',
  gitlab_domain            => 'gitlab.localdomain.local',
  gitlab_http_timeout      => '300',
  gitlab_dbtype            => 'mysql',
  gitlab_backup            => true,
  gitlab_dbname            => 'gitlab',
  gitlab_dbuser            => 'user',
  gitlab_dbpwd             => 'password',
  ldap_enabled             => false,
}
```

# Limitations

This module has been built on and tested against Puppet 2.7 and higher.

The module has been tested on:

* RedHat Enterprise Linux 5/6/7
* Debian 6/7
* CentOS 5/6/7
* Ubuntu 12.04/14.04

Testing on other platforms has been light and cannot be guaranteed. 

# Development

Want to help - send a pull request.


# Beaker-Rspec

This module has beaker-rspec tests

To run:

```shell
bundle install
bundle exec rspec spec/acceptance
# or use BEAKER_destroy=no to keep the resulting vm
BEAKER_destroy=no bundle exec rspec spec/acceptance
```
## Development environment with vagrant

See [vagrant-gitlab](https://github.com/sbadia/vagrant-gitlab).
