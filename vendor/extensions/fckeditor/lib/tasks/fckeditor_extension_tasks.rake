namespace :radiant do
  namespace :extensions do
    namespace :fckeditor do
      
      desc "Runs the migration of the Fckeditor extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          FckeditorExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          FckeditorExtension.migrator.migrate
        end
      end
    
    end
  end
end