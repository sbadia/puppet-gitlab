Puppet::Type.newtype(:gitlab_project) do

   ensurable

   newparam(:name) do
     desc "The name of the gitlab project."
   end

   newparam(:options) do
    desc "Project options."
   end

   newparam(:endpoint) do
     desc "Gitlab endpoint"
   end

   newparam(:private_token) do
     desc "Private token"
   end

end
