require 'simpleton'

module Radiant
  class AdminUI
    
    include Simpleton
    
    class DuplicateTabNameError < StandardError; end
    
    class Tab
      attr_accessor :name, :url, :visibility
      
      def initialize(name, url, options = {})
        @name, @url = name, url
        @visibility = [options[:for], options[:visibility]].flatten.compact
        @visibility = [:all] if @visibility.empty?
      end
      
      def shown_for?(user)
        visibility.include?(:all) or
          visibility.any? { |role| user.send("#{role}?") }
      end  
    end
    
    class TabSet
      def initialize
        @tabs = []
      end
    
      def add(name, url, options = {})
        options.symbolize_keys!
        before = options.delete(:before)
        after = options.delete(:after)
        tab_name = before || after
        if self[name]
          raise DuplicateTabNameError.new("duplicate tab name `#{name}'")
        else
          if tab_name
            index = @tabs.index(self[tab_name])
            index += 1 if before.nil?
            @tabs.insert(index, Tab.new(name, url, options))
          else
            @tabs << Tab.new(name, url, options)
          end
        end
      end
      
      def remove(name)
        @tabs.delete(self[name])
      end
      
      def size
        @tabs.size
      end
      
      def [](index)
        if index.kind_of? Integer
          @tabs[index]
        else
          @tabs.find { |tab| tab.name == index }
        end
      end
      
      def each
        @tabs.each { |t| yield t }
      end
      
      def clear
        @tabs.clear
      end
      
      include Enumerable
    end
        
    attr_accessor :tabs
#    attr_accessor :page_editors
    
    def initialize
      @tabs = TabSet.new
#      @page_editors = Radiant::PageEditorUI.editors;
    end
    
# Note about commented out lines above:
# It would be nice to be able to access the set of Page Editors via "admin.page_editors"
# instead of having to do Radiant::PageEditorUI.editors
# This would also be more consistent with the stype of adding tabs to the admin: admin.tabs
# However, when I do this, it somehow changes how things are loaded
# And it ends up making the page_preview_extension not reload properly. (preview button dissapears)
    
  end
end