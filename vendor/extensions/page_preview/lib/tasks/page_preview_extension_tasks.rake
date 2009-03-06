namespace :radiant do
  namespace :extensions do
    namespace :page_preview do
      
      desc "Runs the migration of the Page Preview extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          PagePreviewExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          PagePreviewExtension.migrator.migrate
        end
      end
    
    end
  end
end