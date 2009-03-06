require File.dirname(__FILE__) + '/../test_helper'

class ExtensionMigratorTest < Test::Unit::TestCase
  
  class Person < ActiveRecord::Base; end
  class Place < ActiveRecord::Base; end
  
  def test_migrate
    BasicExtension.migrator.migrate
    assert_equal(2, BasicExtension.migrator.current_version)
    assert_nothing_raised { Person.find(:all) }
    assert_nothing_raised { Place.find(:all) }
  end

end
