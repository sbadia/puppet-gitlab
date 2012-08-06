# Module gitlab

[GitLab](http://gitlabhq.com) is a free project and repository management application

A ['Puppet Module'](http://docs.puppetlabs.com/learning/modules1.html#modules)
is a collection of related content that can be used to model the configuration
of a discrete service.

This module is based on the admin guides for [gitlab](https://github.com/gitlabhq/gitlabhq/wiki), [stable](https://github.com/gitlabhq/gitlabhq/blob/stable/doc/installation.md) version.

## Testing with vagrant

    $ vagrant up
    $ vagrant ssh gitlab
    $ mkdir /home/gitlab/.ssh/;cp /home/vagrant-puppet/manifests/id_rsa /home/gitlab/.ssh/; chown -R tig:tig /home/gitlab/.ssh/
    $ sudo su - tig
    $ cd gitlab; bundle exec rails s -e production

## Test gitlab
- **Login**: admin@local.host
- **Password**: 5iveL!fe

1. Add an ssh key to your account, or create another account
2. Create a project
3. Play !
