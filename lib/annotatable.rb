module Annotatable

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def self.extended(base)
      base.instance_eval do
        alias :inherited_without_annotatable :inherited
        alias :inherited :inherited_with_annotatable
      end
    end
    
    def annotate(*attrs)
      options = {}
      options = attrs.pop if attrs.last.kind_of?(Hash)
      options.symbolize_keys!
      inherit = options[:inherit]
      if inherit
        @inherited_annotations ||= []
        @inherited_annotations += attrs
      end
      attrs.each do |attr|
        class_eval %{
          def self.#{attr}(string = nil)
            @#{attr} = string || @#{attr}
          end
          def #{attr}(string = nil)
            self.class.#{attr}(string)
          end
          def self.#{attr}=(string = nil)
            #{attr}(string)
          end
          def #{attr}=(string = nil)
            self.class.#{attr}=(string)
          end
        }
      end
      attrs
    end

    def inherited_with_annotatable(subclass)
      inherited_without_annotatable(subclass)
      (["inherited_annotations"] + (@inherited_annotations || [])).each do |t|
        ivar = "@#{t}" 
        subclass.instance_variable_set(ivar, instance_variable_get(ivar))
      end
    end
  end

end