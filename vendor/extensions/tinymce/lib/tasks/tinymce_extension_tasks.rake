namespace :radiant do
  namespace :extensions do
    namespace :tinymce do
      
      desc "Runs the migration of the Tinymce extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          TinymceExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          TinymceExtension.migrator.migrate
        end
      end
    
    end
  end
end