require File.dirname(__FILE__) + '/../test_helper'

class ExternalContentExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal RADIANT_ROOT + '/vendor/extensions/external_content', ExternalContentExtension.root
    assert_equal 'External Content', ExternalContentExtension.extension_name
  end
  
end
