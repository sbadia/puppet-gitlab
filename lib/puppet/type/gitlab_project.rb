Puppet::Type.newtype(:gitlab_project) do

   ensurable

   newparam(:name, :namevar => true) do
     desc "The name of the gitlab project."
   end

   newproperty(:options) do
    desc "Project options."
   end

end
