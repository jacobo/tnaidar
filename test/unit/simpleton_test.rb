require File.dirname(__FILE__) + '/../test_helper'

class SimpletonTest < Test::Unit::TestCase
  
  class TestObject
    
    include Simpleton
    
    attr_accessor :called
    
    def test
      @called = true
      :test
    end
  end
  
  def setup
    TestObject.instance_variable_set "@instance", nil
  end
  
  def test_instance_class_method
    assert_kind_of TestObject, TestObject.instance
    assert_equal TestObject.instance, TestObject.instance
  end
  def test_instance_class_method_with_block
    var = :unchanged
    TestObject.instance do |i|
      var = i.test
    end
    assert_equal :test, var
  end
  
  def test_method_missing_class_method
    assert_nothing_raised { TestObject.test }
    assert TestObject.called
  end
  def test_method_missing_class_method_only_calls_methods_that_are_defined_on_instance
    e = assert_raises(NoMethodError) { TestObject.quack }
    assert_equal "undefined method `quack' for SimpletonTest::TestObject:Class", e.message
  end
  
end