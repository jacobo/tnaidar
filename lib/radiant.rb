RADIANT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined? RADIANT_ROOT

unless defined? Radiant::Version
  module Radiant
    module Version
      Major = '0'
      Minor = '6'
      Tiny  = '0'
    
      class << self
        def to_s
          [Major, Minor, Tiny].join('.')
        end
        alias :to_str :to_s
      end
    end
    
    class << self
      def loaded_via_gem?
        !!(__FILE__ =~ %r{/gems/})        
      end
    end
  end
end