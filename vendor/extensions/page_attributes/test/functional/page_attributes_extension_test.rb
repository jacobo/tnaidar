require File.dirname(__FILE__) + '/../test_helper'

class PageAttributesExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal RADIANT_ROOT + '/vendor/extensions/page_attributes', PageAttributesExtension.root
    assert_equal 'Page Attributes', PageAttributesExtension.extension_name
  end
  
end
