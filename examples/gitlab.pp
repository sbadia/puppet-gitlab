#
node /gitlab_server/ {
  class {
    'gitlab':
      git_user        => 'git',
      git_home        => '/srv/git',
      git_email       => 'notifs@toto.fr',
      git_comment     => 'GIT control version',
      git_adminkey    => '',
      gitlab_user     => 'tig',
      gitlab_home     => '/srv/gitlab',
      gitlab_comment  => 'GITLab'
  }
}
