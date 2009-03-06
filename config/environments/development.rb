#config.cache_classes = true

# Use a different logger for distributed setups
# config.logger        = SyslogLogger.new


# Full error reports are disabled and caching is on
#config.action_controller.consider_all_requests_local = false
#config.action_controller.perform_caching             = true
#ResponseCache.defaults[:perform_caching]             = true

#--------

# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes     = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils        = true

#Dependencies.log_activity = true

# Enable the breakpoint server that script/breakpointer connects to
config.breakpoint_server = true

# Show full error reports and caching is turned off, but ResponseCache caching is on
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
ResponseCache.defaults[:perform_caching]             = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false