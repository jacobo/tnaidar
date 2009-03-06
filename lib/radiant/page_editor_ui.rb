require 'simpleton'

module Radiant
  class PageEditorUI

    include Simpleton
    
    class DuplicateEditorNameError < StandardError; end

    class DefaultEditor
      attr_reader :regions, :partials
      
      def name
        "default"
      end

      def render_edit_partials(page_helper, output)
        self.each do |partial|
          output << page_helper.render(:partial => partial)
        end
      end
      
      def initialize(options = {})
        @regions = HashWithIndifferentAccess.new
        @partials = []
        
        self << "edit_form"
        self.add "edit_title", :region => :form
        self.add "edit_extended_metadata", :region => :form
        self.add "edit_page_parts", :region => :form
        self.add "edit_layout_and_type", :region => :form
        self.add "edit_timestamp", :region => :form
        self.add "edit_buttons", :region => :form_bottom
        self << "edit_popups"
      end
      
      def [](name_or_index)
        case name_or_index
          when String, Symbol
            @partials.find {|p| p == name_or_index.to_s }
          when Integer
            @partials[name_or_index]
        end
      end

      def <<(partial)
        add partial
      end

      def delete(partial)
        @partials.delete(partial)
      end

      def add(partial, options = {})
        after = options.delete(:after)
        before = options.delete(:before)
        region = options.delete(:region)
        partial_name = before || after
        if region
          @regions[region] ||= []
          if partial_name
            index = @regions[region].empty? ? 0 : (@regions[region].index(partial_name) || @regions[region].size - 1)
            index += 1 if before.nil?
            @regions[region].insert(index, partial)
          else
            @regions[region] << partial
          end
        elsif partial_name
          index = @partials.index(partial_name) || size - 1
          index += 1 if before.nil?
          @partials.insert(index, partial)
        else
          @partials << partial
        end
        return self
      end

      def each(&block)
        @partials.each {|p| yield p }
      end

      def size
        @partials.size
      end

      def clear
        @partials.clear
        @regions.clear
      end
      
      include Enumerable
    end
    
    class EditorSet
      def initialize
        @editors = []
      end
      
      def add(editor, options = {})
        options.symbolize_keys!
        before = options.delete(:before)
        after = options.delete(:after)
        editor_name = before || after
        if self[editor.name]
          raise DuplicateTabNameError.new("duplicate editor name `#{name}'")
        else
          if editor_name
            index = @editors.index(self[editor_name])
            index += 1 if before.nil?
            @editors.insert(index, editor)
          else
            @editors << editor
          end
        end
      end
      
      def remove(name)
        @editors.delete(self[name])
      end
      
      def size
        @editors.size
      end
      
      def [](index)
        if index.kind_of? Integer
          @editors[index]
        else
          @editors.find { |editor| editor.name == index }
        end
      end
      
      def each
        @editors.each { |t| yield t }
      end
      
      def clear
        @editors.clear
      end
      
      def default
        self[0]
      end
      
      include Enumerable
    end
    
  attr_accessor :editors
  
  def initialize
    @editors = EditorSet.new
    @editors.add(DefaultEditor.new)
  end
  
  def self.editors
    instance.editors
  end
  
  def self.each_editor
    self.editors.each{ |t| yield t }
  end
              
  end
end