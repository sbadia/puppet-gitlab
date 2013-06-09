# Puppet-gitlab [![Build Status](https://travis-ci.org/sbadia/puppet-gitlab.png)](https://travis-ci.org/sbadia/puppet-gitlab)

Tested successfully with Gitlab 5.2-stable on Debian Wheezy with Puppet 3

[GitLab](http://gitlab.org/) is a free project and repository management application

A [Puppet Module](http://docs.puppetlabs.com/learning/modules1.html#modules) is a collection of related content that can be used to model the configuration of a discrete service.

This module is based on the admin guides for [gitlab](https://github.com/gitlabhq/gitlabhq/wiki), [stable](https://github.com/gitlabhq/gitlabhq/blob/5-2-stable/doc/install/installation.md) version.

## Usage

_Note:_ Assume that a database server is already installed on your server/infrastructure (see: [vagrant-gitlab](https://github.com/sbadia/vagrant-gitlab/blob/master/examples/gitlab.pp)).

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
### Other class parameters

* git\_user: Name of the gitlab (default: git)
* git\_home: Home directory for gitlab repository (default: /home/git)
* git\_email: Email address for gitlab user (default: git@someserver.net)
* git\_comment: Gitlab user comment (default: GitLab)
* gitlab\_sources: Gitlab sources (default: git://github.com/gitlabhq/gitlabhq.git)
* gitlab\_branch: Gitlab branch (default: 5-2-stable)
* gitlabshell\_sources: Gitlab-shell sources (default: git://github.com/gitlabhq/gitlab-shell.git)
* gitlabshell\_banch: Gitlab-shell branch (default: v1.3.0)
* gitlab\_dbtype: Gitlab database type (default: mysql)
* gitlab\_dbname: Gitlab database name (default: gitlabdb)
* gitlab\_dbuser: Gitlab database user (default: gitlabu)
* gitlab\_dbpwd: Gitlab database password (default: changeme)
* gitlab\_dbhost: Gitlab database host (default: localhost)
* gitlab\_dbport: Gitlab database port (default: 3306)
* gitlab\_domain: Gitlab domain (default $fqdn)
* ldap\_enabled: Enable LDAP backend for gitlab web (see bellow) (default: false)
* ldap\_host: FQDN of LDAP server (default: ldap.domain.com)
* ldap\_base: LDAP base dn (default: dc=domain,dc=com)
* ldap\_uid: Uid for LDAP auth (default: uid)
* ldap\_port: LDAP port (default: 636)
* ldap\_method: Method to use (default: ssl)
* ldap\_bind\_dn: User for LDAP bind auth (default: nil)
* ldap\_bind\_password: Password for LDN bind auth (default: nil)

## Dependencys
- [puppetlabs/mysql](https://github.com/puppetlabs/mysql) >= 0.6.1
- [puppetlabs/stdlib](https://github.com/puppetlabs/stdlib) >= 4.1.0
- [fsalum/puppet-redis](https://github.com/fsalum/puppet-redis) >= 0.0.5
- [jfryman/puppet-nginx](https://github.com/jfryman/puppet-nginx) >= 0.0.1
- [puppetlabs/puppetlabs-ruby](https://github.com/puppetlabs/puppetlabs-ruby) >= 0.0.2

See [gitlab example](https://github.com/sbadia/vagrant-gitlab/blob/master/examples/gitlab.pp).

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
