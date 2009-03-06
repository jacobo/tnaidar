require File.dirname(__FILE__) + '/../test_helper'

class FckeditorExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal RADIANT_ROOT + '/vendor/extensions/fckeditor', FckeditorExtension.root
    assert_equal 'Fckeditor', FckeditorExtension.extension_name
  end
  
end
