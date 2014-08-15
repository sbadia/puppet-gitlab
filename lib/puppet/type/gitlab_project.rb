Puppet::Type.newtype(:gitlab_project) do

   ensurable

   newparam(:name, :namevar => true) do
     desc "The name of the gitlab project."
   end

   newproperty(:options) do
     desc "Project options."
     validate do |v|
       raise(Puppet::Error, 'gitlab_project options value should be a hash') unless v.is_a? Hash
     end
   end

end
