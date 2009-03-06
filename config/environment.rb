# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'radius'

Radiant::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for when Radiant is running in instance mode
  config.load_paths += %w(
    app/controllers
    app/models
    app/helpers
    lib
  ).map { |path| File.join(RADIANT_ROOT, path) }
  config.controller_paths << File.join(RADIANT_ROOT, 'app', 'controllers')
  config.view_path = File.join(RADIANT_ROOT, 'app', 'views')
  
  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  # config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/fragment_cache"
  config.action_controller.page_cache_directory = "#{RAILS_ROOT}/cache"

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  
  # Activate observers that should always be running
  config.active_record.observers = :user_action_observer
  
  # Make sure plugins are loaded from lib and vendor
  config.plugin_paths = [
    "#{RAILS_ROOT}/vendor/plugins",
    "#{RADIANT_ROOT}/lib/plugins",
    "#{RADIANT_ROOT}/vendor/plugins"
  ]

  # See Rails::Configuration for more options

end

# Add new inflection rules using the following format:
Inflector.inflections do |inflect|
  inflect.uncountable 'config'
  inflect.uncountable 'meta'
end

# Auto-require text filters
Dir["#{RADIANT_ROOT}/app/models/*_filter.rb"].each do |filter|
  filter = $1 if filter =~ %r{/([^/]+)\.rb}
  require_dependency filter
end

# Response Caching Defaults
ResponseCache.defaults[:directory] = ActionController::Base.page_cache_directory
ResponseCache.defaults[:logger]    = ActionController::Base.logger

require "status"

#Engines.start :datebocks
