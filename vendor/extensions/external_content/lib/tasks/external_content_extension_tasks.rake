namespace :radiant do
  namespace :extensions do
    namespace :external_content do
      
      desc "Runs the migration of the External Content extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          ExternalContentExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          ExternalContentExtension.migrator.migrate
        end
      end
    
    end
  end
end