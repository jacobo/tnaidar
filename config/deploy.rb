require 'mongrel_cluster/recipes'

set :repository, "http://svn.kupenda.org/radiant/trunk/"
set :application, "kupenda"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

#Configs for slicehost
role :web, "kupenda.org"
role :app, "kupenda.org"
role :db,  "kupenda.org", :primary => true
set :deploy_to, "/var/www/kupenda.org/#{application}"  # defaults to "/u/apps/#{application}"
set :user, "kupenda"  # defaults to the currently logged in user
set :use_sudo, false
set :checkout, "export"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

namespace :deploy do
  
 task :default do
   puts "\n\n -- deploy:default (with migrations) -- \n\n"
   migrations
   run "ln -s #{deploy_to}/shared/UserFiles #{deploy_to}/current/public/UserFiles"
   run "ln -s #{deploy_to}/shared/uploaded_file_page_attributes #{deploy_to}/current/public/uploaded_file_page_attributes"
 end

end


# namespace :post_deploy do
#   
#   task :symlink do
#     run "ln -s #{deploy_to}/shared/UserFiles #{deploy_to}/current/public/UserFiles"
#     run "ln -s #{deploy_to}/shared/uploaded_file_page_attributes #{deploy_to}/current/public/uploaded_file_page_attributes"    
#   end
# 
#   task :restart do
#     run "cd #{deploy_to}/current && mongrel_rails cluster::restart" 
#   end
# 
# end