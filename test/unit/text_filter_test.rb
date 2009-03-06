require File.dirname(__FILE__) + '/../test_helper'

class TextFilterTest < Test::Unit::TestCase

  class ReverseFilter < TextFilter
    description %{Reverses text.}
    def filter(text)
      text.reverse
    end
  end

  class CustomFilter < TextFilter
    filter_name "Really Custom"
    description_file File.dirname(__FILE__) + "/../fixtures/sample.txt"
  end

  def test_description
    assert_equal %{Reverses text.}, ReverseFilter.description    
  end
  
  def test_description_file
    assert_equal File.read(File.dirname(__FILE__) + "/../fixtures/sample.txt"), CustomFilter.description
  end

  def test_base_filter
    filter = TextFilter.new
    assert_equal 'test', filter.filter('test')
  end
  
  def test_filter
    assert_equal 'tset', ReverseFilter.filter('test')
  end
  
  def test_filter_name
    assert_equal 'Text Filter Test Reverse', ReverseFilter.filter_name
  end
  
  def test_custom_filter_name
    assert_equal 'Really Custom', CustomFilter.filter_name
  end

end