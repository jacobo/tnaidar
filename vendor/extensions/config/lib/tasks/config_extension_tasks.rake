namespace :radiant do
  namespace :extensions do
    namespace :config do
      
      desc "Runs the migration of the Config extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          ConfigExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          ConfigExtension.migrator.migrate
        end
      end
    
    end
  end
end