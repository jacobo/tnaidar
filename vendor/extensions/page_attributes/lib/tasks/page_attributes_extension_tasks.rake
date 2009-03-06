namespace :radiant do
  namespace :extensions do
    namespace :page_attributes do
      
      desc "Runs the migration of the Page Attributes extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          PageAttributesExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          PageAttributesExtension.migrator.migrate
        end
      end
    
    end
  end
end