require 'rake/testtask'

namespace :db do
  namespace :migrate do
    desc "Run all Radiant extension migrations"
    task :extensions => :environment do
      require 'radiant/extension_migrator'
      Radiant::ExtensionMigrator.migrate_extensions
    end
  end
end

namespace :test do
  Rake::TestTask.new(:extensions => "db:test:prepare") do |t|
    t.libs << "test"
    t.pattern = 'vendor/extensions/**/test/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task["test:extensions"].comment = "Runs tests on all available Radiant extensions"
end

# Load any custom rakefiles from extensions
[RAILS_ROOT, RADIANT_ROOT].uniq.each do |root|
  Dir[root + '/vendor/extensions/**/tasks/**/*.rake'].sort.each { |ext| load ext }
end