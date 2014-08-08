require 'gitlab'

Puppet::Type.type(:gitlab_project).provide :gitlab do

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
    @client = Gitlab.client(:endpoint => 'https://example-gitlab.org/api/v3', :private_token => 'replaceme')
  end

  def self.symbolize_keys(h)
    h.keys.each do |key|
        if h[key].is_a?(Hash)
          h[key] =self.symbolize_keys(h[key])
        end
        h[(key.to_sym rescue key) || key] = h.delete(key)
    end
    return h
  end

  def self.instances
     Gitlab.configure do |config|
         config.endpoint       = 'https://example-gitlab.org/api/v3' # API endpoint URL, default: ENV['GITLAB_API_ENDPOINT']
         config.private_token  = 'replaceme'           # user's private token, default: ENV['GITLAB_API_PRIVATE_TOKEN']
     end

     Gitlab.projects.collect do |project|
      resource = {}
      resource[:options] = self.symbolize_keys(project.to_h)
      resource[:name] = project.name
      resource[:provider] = :gitlab
      resource[:ensure] = :present
      Puppet.debug resource
      new(resource)
    end
  end

  def self.get_properties(name)
    resource = {}
    resource[:options] = self.symbolize_keys(@client.project(name).to_h)
    resource[:name] = name
    resource[:provider] = :gitlab
    resource[:ensure] = :present
    return properties
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @client.delete_project(resource[:options][:id])
      return
    end

    if (@resource[:options].nil?)
      raise Puppet::Error, "The options hash requires a value."
    end

    @client.create_project(resource[:name], resource[:options])

    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = self.class.get_properties(resource[:name])
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

end
