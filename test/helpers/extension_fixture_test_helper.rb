module ExtensionFixtureTestHelper
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class_inheritable_accessor :extension_fixture_table_names, :extension_fixture_path
      self.extension_fixture_table_names = []
      self.extension_fixture_path = ""
      alias_method_chain :load_fixtures, :extensions
    end
  end

  module ClassMethods
    def extension_fixtures(*table_names)
      table_names = table_names.flatten.map { |n| n.to_s }
      self.extension_fixture_table_names = table_names
      require_fixture_classes(table_names)
      setup_fixture_accessors(table_names)
    end
  end

  def load_fixtures_with_extensions
    load_fixtures_without_extensions
    @loaded_fixtures ||= {}
    unless extension_fixture_table_names.empty? or extension_fixture_path.empty?
      fixtures = Fixtures.create_fixtures(extension_fixture_path, extension_fixture_table_names, fixture_class_names)
      unless fixtures.nil?
        if fixtures.instance_of?(Fixtures)
          @loaded_fixtures[fixtures.table_name] = fixtures
        else
          fixtures.each { |f| @loaded_fixtures[f.table_name] = f }
        end
      end
    end
  end
end