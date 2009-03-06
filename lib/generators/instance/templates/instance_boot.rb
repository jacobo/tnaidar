# Don't change this file. Configuration is done in config/environment.rb and config/environments/*.rb

unless defined?(RAILS_ROOT)
  root_path = File.join(File.dirname(__FILE__), '..')
  
  unless RUBY_PLATFORM =~ /mswin32/
    require 'pathname'
    root_path = Pathname.new(root_path).cleanpath(true).to_s
  end
  
  RAILS_ROOT = root_path
end

unless defined? RADIANT_ROOT
  if File.directory?(root_path = "#{RAILS_ROOT}/vendor/radiant")
    RADIANT_ROOT = root_path
  else
    environment = IO.readlines("#{File.dirname(__FILE__)}/environment.rb").reject { |l| l.strip =~ /^#/ }.join
    environment =~ /[^#]\s*RADIANT_GEM_VERSION\s*=\s*(["'])([\d.]+)\1/
    version = $2

    require 'rubygems'
    if version and (radiant_gem = Gem.cache.search('radiant', version).first)
      gem "radiant", "=#{version}"
      require "radiant" # defines RADIANT_ROOT
    else
      STDERR.puts %(
Cannot find gem or source for Radiant #{version}:
  Install the missing gem with 'gem install -v=#{version} radiant', or change
  environment.rb to define RADIANT_GEM_VERSION with your desired version.
)
      exit 1
    end
  end
end

load File.join(RADIANT_ROOT, 'config', 'boot.rb')