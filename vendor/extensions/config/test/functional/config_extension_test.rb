require File.dirname(__FILE__) + '/../test_helper'

class ConfigExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal RADIANT_ROOT + '/vendor/extensions/config', ConfigExtension.root
    assert_equal 'Config', ConfigExtension.extension_name
  end
  
end
