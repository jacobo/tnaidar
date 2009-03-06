require File.dirname(__FILE__) + '/../test_helper'

class PageContextTest < Test::Unit::TestCase
  fixtures :pages, :page_parts, :layouts, :snippets, :users
  test_helper :pages
  
  def setup
    @page = pages(:radius)
    @context = PageContext.new(@page)
    @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
  end
    
  def test_initialize
    assert_equal(@page, @context.page)
  end
  
  def test_tag_missing
    assert_raises(StandardTags::TagError) { @parser.parse '<r:missing />' }
    def @context.testing?() false end
    assert_parse_output_match "undefined tag `missing'", '<r:missing />'
  end
    
  private
    
    def assert_parse_output_match(regexp, input)
      output = @parser.parse(input)
      assert_match regexp, output
    end
end
