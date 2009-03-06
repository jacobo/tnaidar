require File.dirname(__FILE__) + '/../test_helper'

class TinymceExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal RADIANT_ROOT + '/vendor/extensions/tinymce', TinymceExtension.root
    assert_equal 'Tinymce', TinymceExtension.extension_name
  end
  
end
