## 2015-07-11 - 1.0.0

### features:
* Install mariadb-devel on EL7 platforms
* Add extra parameters for Gitlab configuration
* Add new config options for GitLab 7.12
* add variables for SSL ciphers/protocol
* Fix spec tests, lint and acceptance

### bugfix:
* Offer a coherent gitlab_dbport default value
* Missing System Package: 'cmake', 'pkg-config', 'libkrb5-dev', 'ruby-execjs'.
* create ${git_home].gitlab_setup_done with ensure => file
* gitlab should not fix the system

## 2015-03-19 - 0.2.0

### features:
* Add a parameter to make rbenv configuration optional
* Introduce modulesync \o/
* Explicitly support rhel distro
* Added parameter to enable Unicorn to listen on give IP address
* Add flexibility to system packages that are controller by the Gitlab module
* Add ability to manage git user and/or home directory separately, and to manually specify the group for the git user.
* Bumping Ruby version to 2.1.2
* Parameterizing ruby version
* Updating to Ruby 2.0.0-p353 (from 1.9.3-p484)
* Using rbenv instead of managing system ruby
* Add Gitlab CI Runner Support
* Add gitlab::ci class to manage a gitlab-ci instance
* Abstract config files into reusuable defines
* Allowing management of curl elsewhere

### bugfix:
* Fix the jobs flag to not break with older bundler

## 2014-06-18 - 0.1.5

### features:
* Use puppetlabs/git module for git package declaration
* Add parameter for company link and logo support (thx Ludovic)
* Fix compatibility issue with exim (thx Ludovic) [gitlabhq#4866](https://github.com/gitlabhq/gitlabhq/issues/4866)

### bugfix:
* Fix gitlab-satellites permissions (should be 0750)
* Fix rspec output formatter (documentation)
* Lock rspec version to 2.14.1 (puppet rspec not yet ready for RSpec +3.0, see https://github.com/rodjek/rspec-puppet/pull/204 )

## 2014-05-26 - 0.1.4

### features:
* added `ldap_user_filter` parameter (RFC 4515 style filter for the user) (thanks Igor)
* added nginx to listen ipv6 also
* allow end users to disable nginx (with the param. `manage_nginx`) (thanks Andrew)
* added support for nginx domain aliases (thanks Leonardo)
* added `gitlab_ensure_postfix` parameter (to manage or not postfix package)
* disable gzip compression if SSL enabled (nginx)
 * and enable it for static assets
* bump to gitlab 6.9 + gitlab-shell 1.9.4 (6.7 → 6.8 → 6.9)
* allow adjustment of number of bundler threads
* simplify backup task

### bugfix:
* Fix travis gate (ruby1.8 and rake > 10.1.0)
* remove MySQL `reaping_frequency`

## 2014-03-25 - 0.1.3

### features:
* added `ssh_port` parameter (thanks Kalman)
* added `git_proxy` parameter (thanks Stefan)
* added `google_analytics_id` parameter (thanks Andrew)
* internals unit-tests refactoring, better coverage and regexp
* bump to GitLab 6.7 and GitLab Shell 1.9.1

### bugfix:
* allow special characters in db passwords (thanks Thomas)
* fixed asset compilation and db migrations (thanks Thomas)

## 2014-02-22 - 0.1.2

### features:
* manage gitlab relative URL (thanks Vincent)
* add backups support + external script (thanks Igor)
* bump to gitlab 6.6 (6.3 → 6.4 → 6.5 → 6.6)
* securing SSL configuration (thanks Andrew, Igor)
* allow « plain » for `ldap_method` (thanks sven)
* manage http timeout and unicorn workers as parameter
* manage `exec_path` as a parameter
* replace git exec by vcsrepo module (thanks Igor)

### bugfix:
* internals: fix spec tests and travis config (thanks Lee)
* fix git package name in RedHat (thanks Stefan)
* allow users to use non-stable GitLab branchs

## 2013-12-03 - 0.1.1

### features:
* improve documentation (typos)

### bugfix:
* fix params in gitlab.yml (http/https with non-default port)
* fix stdlib dependency (librarian require a version number)

## 2013-11-27 - 0.1.0

### features:
* bump to GitLab 6.3 and gitlab-shell v1.7.9
* add `rack_attack` and logrotate configurations

## 2013-11-17 - 0.0.10

### features:
* bump gitlab-shell to 1.7.8 (multiple security fix)

### bugfix:
* bugfix https://github.com/sbadia/puppet-gitlab/pull/80

## 2013-11-08 - 0.0.9

### features:
* huge changes/re-factorization by atomaka ! (many thanks !!)
* Use anchors and refactoring of args/class
* Add ssl support for nginx
* Add extra params (repodir,`username_changing`,redis,unicorn)
* Better management of extra packages (thx stdlib)
* Bump to gitlab 6.2.3
* Add spec and travis testing

## 2013-06-10 - 0.0.8

### features:
* Use nginx,ruby,redis,mysql external modules
* Clean pre.pp file

## 2013-04-27 - 0.0.6

### features:
* Remove apt and mysql setting from core module
* Bump to GitLab 5.1 (switch from unicorn to puma)

### bugfix:

* Fix packaging issue (https://github.com/sbadia/puppet-gitlab/issues/33) wait for a cleaner way to do that (http://projects.puppetlabs.com/issues/14651)
* Fix timeouts issue, and others bugs

## 2013-04-07 - 0.0.5

### features:
* up to GitLab 5.0
* remove gitolite (use gitlab-shell)

## 2012-11-02 - 0.0.4

### features:
* up to GitLab 4.1

## 2013-01-01 - 0.0.3

### features:
* up to GitLab 3.2
* add dependency to mysql, stdlib

## 2012-08-12 - 0.0.1

### features:
* initial release
