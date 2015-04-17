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

* `ensure`:  Ensure gitlab/gitlab-shell repo are present, latest. absent is not yet supported (default: present)
* `git_user`: Name of the gitlab (default: git)
* `git_group`: Name of the group for the gitlab user (default: $git_user)
* `git_home`: Home directory for gitlab repository (default: /home/git)
* `git_email`: Email address for gitlab user (default: git@someserver.net)
* `git_comment`: Gitlab user comment (default: GitLab)
* `gitlab_manage_user`: Whether to manage the user account for gitlab (default: true)
* `gitlab_manage_home`: Whether to manage the home directory for gitlab (default: true)
* `gitlab_sources`: Gitlab sources (default: git://github.com/gitlabhq/gitlabhq.git)
* `gitlab_branch`: Gitlab branch (default: 7-3-stable)
* `gitlabshell_sources`: Gitlab-shell sources (default: git://github.com/gitlabhq/gitlab-shell.git)
* `gitlabshell_branch`: Gitlab-shell branch (default: v2.0.1)
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
* `gitlab_bundler_jobs`: The number of jobs to use while installing gems. Should match number of CPUs on machine (default: 1)
* `gitlab_ensure_postfix`: Whether or not this module should ensure the postfix
  package is installed (used to manage conflicts with other modules) (default:
true)
* `gitlab_manage_rbenv`: Whether this module should use rbenv to install a suitable version of Ruby for the Gitlab user (default: true)
* `gitlab_ruby_version`: Ruby version to install with rbenv for the Gitlab user (default: 2.1.2)
* `exec_path`: PATH of execution (default: ${git\_home}/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin)
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
* `company_logo_url`: Url to the company logo to be displayed at the bottom of the sign_in page (default: '')
* `company_link`: Link to the company displayed under the logo of the company (default: '')
* `company_name`: Name of the company displayed under the logo of the company (default: '')
* `use_exim` : Apply a fix for compatibility with exim as explained at [gitlabhq/gitlabhq#4866](https://github.com/gitlabhq/gitlabhq/issues/486) (default: false)

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

And test on http://10.255.127.206/

## Development environment with vagrant

See [vagrant-gitlab](https://github.com/sbadia/vagrant-gitlab).
