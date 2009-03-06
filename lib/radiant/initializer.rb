require 'initializer'
require 'radiant/admin_ui'

module Radiant
  
  class Configuration < Rails::Configuration
    attr_accessor :view_paths
    attr_accessor :extension_paths
    
    def initialize
      self.view_paths = default_view_paths
      self.extension_paths = default_extension_paths
      super
    end
    
    def default_view_paths
      [view_path].compact
    end
    
    def default_extension_paths
      [RADIANT_ROOT + '/vendor/extensions', RAILS_ROOT + '/vendor/extensions'].uniq
    end
    
    def admin
      AdminUI.instance
    end
    
  end
  
  class Initializer < Rails::Initializer
    def self.run(command = :process, configuration = Configuration.new)
      super
    end
    
    def after_initialize
      initialize_extensions
      super
    end
    
    def initialize_extensions
      ActiveRecord::Base.connection.execute("select count(*) from #{ExtensionMeta.table_name}")
      require 'radiant/extension_loader'
      ExtensionLoader.instance { |l| l.initializer = self }.run
    rescue ActiveRecord::StatementInvalid
      $stderr.puts("Extensions cannot be used until Radiant migrations are up to date.")
    end
    
    def initialize_view_paths
      [ActionView::Base, ActionMailer::Base].each do |klass|
        klass.view_paths = configuration.view_paths
      end
    end
    
    def initialize_default_admin_tabs_and_edit_partials
      admin.tabs.clear
      admin.tabs.add "Pages",    "/admin/pages", :visibility => [:admin, :developer]
      admin.tabs.add "Snippets", "/admin/snippets", :visibility => [:admin, :developer]
      admin.tabs.add "Layouts",  "/admin/layouts", :visibility => [:admin, :developer]
    end
    
    def admin
      configuration.admin
    end
  end
  
end