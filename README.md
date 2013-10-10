# Puppet-gitlab [![Build Status](https://travis-ci.org/sbadia/puppet-gitlab.png)](https://travis-ci.org/sbadia/puppet-gitlab)

Tested successfully with Gitlab 6-1-stable on Ubuntu 12.04 and Debian Wheezy (7.1) with Puppet 3.2 or newer.

[GitLab](http://gitlab.org/) is a free project and repository management application

A [Puppet Module](http://docs.puppetlabs.com/learning/modules1.html#modules) is a collection of related content that can be used to model the configuration of a discrete service.

This module is based on the admin guides for [gitlab](https://github.com/gitlabhq/gitlabhq/wiki), [stable](https://github.com/gitlabhq/gitlabhq/blob/5-4-stable/doc/install/installation.md) version.

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
* gitlab\_branch: Gitlab branch (default: 6-1-stable)
* gitlabshell\_sources: Gitlab-shell sources (default: git://github.com/gitlabhq/gitlab-shell.git)
* gitlabshell\_banch: Gitlab-shell branch (default: v1.7.1)
* gitlab\_http\_port Port that NGINX listens on for HTTP traffic (default: 80)
* gitlab\_ssl\_port Port that NGINX listens on for HTTPS traffic (default: 443)
* gitlab\_redishost Redis host used for Sidekiq (default: localhost)
* gitlab\_redisport Redis host used for Sidekiq (default: 6379)
* gitlab\_dbtype: Gitlab database type (default: mysql)
* gitlab\_dbname: Gitlab database name (default: gitlabdb)
* gitlab\_dbuser: Gitlab database user (default: gitlabu)
* gitlab\_dbpwd: Gitlab database password (default: changeme)
* gitlab\_dbhost: Gitlab database host (default: localhost)
* gitlab\_dbport: Gitlab database port (default: 3306)
* gitlab\_domain: Gitlab domain (default $fqdn)
* gitlab\_repodir: Gitlab repository directory (default: $git\_home)
* gitlab\_ssl: Enable SSL for GitLab (default: false)
* gitlab\_ssl\_cert: SSL Certificate location (default: /etc/ssl/certs/ssl-cert-snakeoil.pem)
* gitlab\_ssl\_key: SSL Key location (default: /etc/ssl/private/ssl-cert-snakeoil.key)
* gitlab\_ssl\_self\_signed: Set true if your SSL Cert is self signed (default: false)
* gitlab\_projects: GitLab default number of projects for new users (default: 10)
* gitlab\_username\_change: Manage username changing in GitLab (default: true)
* ldap\_enabled: Enable LDAP backend for gitlab web (see bellow) (default: false)
* ldap\_host: FQDN of LDAP server (default: ldap.domain.com)
* ldap\_base: LDAP base dn (default: dc=domain,dc=com)
* ldap\_uid: Uid for LDAP auth (default: uid)
* ldap\_port: LDAP port (default: 636)
* ldap\_method: Method to use (default: ssl)
* ldap\_bind\_dn: User for LDAP bind auth (default: nil)
* ldap\_bind\_password: Password for LDN bind auth (default: nil)

## Dependencies
- [puppetlabs/puppetlabs-stdlib](https://github.com/puppetlabs/puppetlabs-stdlib) >= 4.1.0
- MySQL ([puppetlabs/puppetlabs-mysql](https://github.com/puppetlabs/puppetlabs-mysql) >= 0.6.1)
- Redis ([fsalum/puppet-redis](https://github.com/fsalum/puppet-redis) >= 0.0.5)
- nginx ([jfryman/puppet-nginx](https://github.com/jfryman/puppet-nginx) >= 0.0.1)
- Ruby >= 1.9.3 ([puppetlabs/puppetlabs-ruby](https://github.com/puppetlabs/puppetlabs-ruby) >= 0.0.2)
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
