require File.dirname(__FILE__) + '/../test_helper'

class FileNotFoundTest < Test::Unit::TestCase
  fixtures :pages
  test_helper :pages, :render
  
  def setup
    @page = pages(:file_not_found)
  end
  
  def test_url
    assert_renders 'http://testhost.tld/gallery/asdf?param=4', '<r:attempted_url />', '/gallery/asdf?param=4'
  end
  
  def test_virtual
    assert_equal true, @page.virtual?
  end
  
  def test_cache
    assert_equal false, @page.cache?
  end
  
  def test_headers
    assert_headers({'Status' => '404 Not Found'}, '/gallery/asdf')
  end
  
end