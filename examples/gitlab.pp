#
node /gitlab_server/ {
  class {
    'gitlab':
      git_user        => 'git',
      git_home        => '/srv/git',
      git_email       => 'notifs@toto.fr',
      git_comment     => 'GIT control version',
      git_adminkey    => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvmLve9uDO15qZf0xTlk/QK7RH+6oqCXRLy98cAw7IrrTg8AOwVFwfNGhyMv9Q5+dPDKPpsPl60tXN6L6XxYBzp95qM7ykY5KqLD2XvkWBT9iDv5SRmdG1yzlryIo13TKU4xTyKmzRnS4TfsITSckRZwZ/dKenNuHU5P805pZ0sxJ5tRBwSGMK1olOwCm/ZwMdrgdF+dIGtHgaPRJNTby392w01oNKESsXiHNJpMRmqLDOxRj4tx2/ItVpDj7seGorbqhspk0dYjhvcqnpzc1f58eVg6VkzaEgG6E1/SX34Nu6g+D58QjDB8Z0fHcnHrPGzTL0WJGPyT/oMXeyVYzz tig@gitlab',
      gitlab_user     => 'tig',
      gitlab_home     => '/srv/gitlab',
      gitlab_comment  => 'GITLab'
  }
}
