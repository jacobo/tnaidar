require File.dirname(__FILE__) + '/../../test_helper'
require 'ostruct'
require 'radiant/taggable'
class Radiant::TaggableTest < Test::Unit::TestCase
  
  class TestObject
    include Radiant::Taggable
    
    desc %{This tag renders the text "just a test".}
    tag "test" do
      "just a test"
    end

    desc %{This tag implements "Hello, world!".}    
    tag "hello" do |tag|
      "Hello, #{ tag.attr['name'] || 'world' }!"
    end
  end
  
  module AdditionalTags
    include Radiant::Taggable
    
    desc %{This tag renders the text "another tag".}
    tag "another" do
      "another tag"
    end
    
  end
  
  class AnotherObject < TestObject
    include AdditionalTags
  end
  
  def setup
    @object = TestObject.new
  end
  
  def test_tag_class_method
    assert_equal "just a test", @object.send("tag:test")
  end
  
  def test_tags_class_method
    assert_equal ["hello", "test"], TestObject.tags
  end
  
  def test_tags
    @object.extend AdditionalTags
    assert_equal ["another", "hello", "test"], @object.tags
  end
  
  def test_render_tag
    binding = OpenStruct.new( :attr => { 'name' => 'John' } )
    assert_equal "Hello, John!", @object.render_tag(:hello, binding)
  end
  
  def test_descriptions
    assert @object.respond_to?(:tag_descriptions)
    assert_equal "<p>This tag renders the text &#8220;just a test&#8221;.</p>", @object.tag_descriptions["test"]
    assert_equal "<p>This tag implements &#8220;Hello, world!&#8221;.</p>", @object.tag_descriptions["hello"]    
  end
  
  def test_description_inclusion_and_inheritance
    @object = AnotherObject.new
    assert_not_nil @object.tag_descriptions["another"] 
    assert_equal "<p>This tag renders the text &#8220;another tag&#8221;.</p>", @object.tag_descriptions["another"]
    assert_equal "<p>This tag renders the text &#8220;just a test&#8221;.</p>", @object.tag_descriptions["test"]
    assert_equal "<p>This tag implements &#8220;Hello, world!&#8221;.</p>", @object.tag_descriptions["hello"]
  end

  def test_strip_leading_whitespace
    markup = %{  
  
  I'm a really small paragraph that
  happens to span two lines.
  
  * I'm just
  * a simple
  * list

  Let's try a small code example:
  
    puts "Hello world!"
  
  Nice job! It really, really, really
  works.

}
result = %{

I'm a really small paragraph that
happens to span two lines.

* I'm just
* a simple
* list

Let's try a small code example:

  puts "Hello world!"

Nice job! It really, really, really
works.}
     assert_equal result, Radiant::Taggable::Util.strip_leading_whitespace(markup)
   end  
end