require File.dirname(__FILE__) + '/../test_helper'
require 'annotatable'

class AnnotatableTest < Test::Unit::TestCase
  class A
    @@inherited_called = false
    def self.inherited(subclass)
      @@inherited_called = true
    end
    def self.inherited_called
      @@inherited_called
    end
    
    include Annotatable
    annotate :description, :url
    annotate :another, :inherit => true
    
    description "just a test"
    another     "inherit me"
  end
  
  class B < A
    url "http://test.host"
  end
  
  class C < B
    description "something else"
    another     "still inherit me"
  end
  
  class D < C; end
  
  def test_superclass
    assert_equal "just a test",      A.description
    assert_equal nil,                A.url
    assert_equal "inherit me",       A.another

    assert_equal "just a test",      A.new.description
    assert_equal nil,                A.new.url
    assert_equal "inherit me",       A.new.another
  end
  
  def test_subclass_B
    assert_equal nil,                B.description
    assert_equal "http://test.host", B.url
    assert_equal "inherit me",       B.another

    assert_equal nil,                B.new.description
    assert_equal "http://test.host", B.new.url
    assert_equal "inherit me",       B.new.another
  end
  
  def test_subclass_C
    assert_equal "something else",   C.description
    assert_equal nil,                C.url
    assert_equal "still inherit me", C.another

    assert_equal "something else",   C.new.description
    assert_equal nil,                C.new.url
    assert_equal "still inherit me", C.new.another
  end
  
  def test_subclass_D
    assert_equal nil,                D.description
    assert_equal nil,                D.url
    assert_equal "still inherit me", D.another

    assert_equal nil,                D.new.description
    assert_equal nil,                D.new.url
    assert_equal "still inherit me", D.new.another
  end
  
  def test_super_called_in_inherited
    assert A.inherited_called
  end
end