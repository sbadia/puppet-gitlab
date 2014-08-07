require 'gitlab'

Puppet::Type.type(:gitlab_project).provide :gitlab do

  def gitlab()
    Gitlab.configure do |config|
      config.endpoint       = @resource[:endpoint]
      config.private_token  = @resource[:private_token]
    end

    return Gitlab
  end

  private :gitlab

  def create
    Puppet.debug "Creating gitlab project #{@resource[:name]}"
    gitlab.create_project(@resource[:name], @resource[:options])
  end

  def exists?
    gitlab.projects.each do |project|
      if project.name == @resource[:name] and project.namespace.id == @resource[:options]["namespace_id"].to_i
        return true
      end
    end
    return false
  end

  def destroy
    Puppet.debug "Destroying gitlab project #{@resource[:name]}"
    gitlab.projects.each do |project|
      if project.name == @resource[:name] and project.namespace.id == @resource[:options]["namespace_id"].to_i
        gitlab.delete_project(project.id)
      end
    end
  end

end
