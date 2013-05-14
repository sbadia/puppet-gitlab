# Puppet-gitlab [![Build Status](https://travis-ci.org/sbadia/puppet-gitlab.png)](https://travis-ci.org/sbadia/puppet-gitlab)

Tested successfully with Gitlab 5.1-stable [b4589a8](https://github.com/gitlabhq/gitlabhq/commit/09b915799d3c06dcf63ebab606f05d81ab4589a8) on debian wheezy with puppet 3

[GitLab](http://gitlabhq.org/) is a free project and repository management application

A [Puppet Module](http://docs.puppetlabs.com/learning/modules1.html#modules) is a collection of related content that can be used to model the configuration of a discrete service.

This module is based on the admin guides for [gitlab](https://github.com/gitlabhq/gitlabhq/wiki), [stable](https://github.com/gitlabhq/gitlabhq/blob/5-1-stable/doc/install/installation.md) version.

## Usage

```
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

### Dependencys
- [puppetlabs/mysql](https://github.com/puppetlabs/mysql) >= 0.5.0
- [puppetlabs/stdlib](https://github.com/puppetlabs/stdlib) >= 2.2.1

## GitLab web interface
- access via your browser under the hostname (e.g. http://gitlab.domain.tld)
- **Login**: admin@local.host
- **Password**: 5iveL!fe

1. Add an ssh key to your account, or create another account
2. Create a project
3. Play !

## Contribute

Want to help - send a pull request.

### Development environment with vagrant

See [vagrant-gitlab](https://github.com/sbadia/vagrant-gitlab).
