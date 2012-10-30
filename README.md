# Module gitlab

* Tested with Gitlab 3.0.3 [7ecfacc]

[GitLab](http://gitlabhq.com) is a free project and repository management application

A ['Puppet Module'](http://docs.puppetlabs.com/learning/modules1.html#modules)
is a collection of related content that can be used to model the configuration
of a discrete service.

This module is based on the admin guides for [gitlab](https://github.com/gitlabhq/gitlabhq/wiki), [stable](https://github.com/gitlabhq/gitlabhq/blob/stable/doc/installation.md) version.

## Testing with vagrant

### Using Debian Wheezy (will start as debian.gitlab.local on 192.168.111.10)

    $ vagrant up debian 

### Using Centos 6 (will start as centos.gitlab.local on 192.168.111.11)

    $ vagrant up centos

## Test gitlab
- add the ip and name to your /etc/hosts file
- access via your browser under the hostname (e.g. http://centos.gitlab.local)
- **Login**: admin@local.host
- **Password**: 5iveL!fe

1. Add an ssh key to your account, or create another account
2. Create a project
3. Play !
