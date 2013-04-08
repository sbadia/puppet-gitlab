# Puppet-gitlab [![Build Status](https://travis-ci.org/sbadia/puppet-gitlab.png)](https://travis-ci.org/sbadia/puppet-gitlab)

Tested successfully with Gitlab 5.0-stable [4606380316](https://github.com/gitlabhq/gitlabhq/commit/46063803162064e05973c6c86e7033801266c34c) on debian wheezy with puppet 3

[GitLab](http://gitlabhq.org/) is a free project and repository management application

A [Puppet Module](http://docs.puppetlabs.com/learning/modules1.html#modules)
is a collection of related content that can be used to model the configuration
of a discrete service.

This module is based on the admin guides for [gitlab](https://github.com/gitlabhq/gitlabhq/wiki), [stable](https://github.com/gitlabhq/gitlabhq/blob/5-0-stable/doc/install/installation.md) version.

## Testing with vagrant

### Setup

After cloning this repository, you will have to

    git submodule init

and

    git submodule update

in order to add the modules that puppet-gitlab depends on to your local copy.

### Using Debian Wheezy (the default)

$ vagrant up
or
$ GUEST_OS=debian7 vagrant up

### Using Centos 6

$ GUEST_OS=centos6 vagrant up

### Using Ubuntu Quantal Quetzal (12.10)

$ GUEST_OS=ubuntu vagrant up

## Test gitlab
- add the ip and name to your /etc/hosts file (192.168.111.10 gitlab.localdomain.local)
- access via your browser under the hostname (e.g. http://gitlab.localdomain.local)
- **Login**: admin@local.host
- **Password**: 5iveL!fe

1. Add an ssh key to your account, or create another account
2. Create a project
3. Play !

## Contribute
Want to help - send a pull request.
