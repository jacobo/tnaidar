namespace :radiant do
  namespace :extensions do
    namespace :<%= file_name %> do
      
      desc "Runs the migration of the <%= extension_name %> extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          <%= class_name %>.migrator.migrate(ENV["VERSION"].to_i)
        else
          <%= class_name %>.migrator.migrate
        end
      end
    
    end
  end
end