require File.dirname(__FILE__) + '/../test_helper'

class MethodObserverTest < Test::Unit::TestCase
  
  class TestObject
    cattr_accessor :captures
    @@captures = [:invoked, :before_called, :after_called, :before_result, :after_result]
    
    attr_accessor *captures
    
    def test(result)
      @invoked = true
      result
    end
  end
  
  class TestObserver < MethodObserver    
    def before_test(args, &block)
      target.before_called = true
      target.before_result = result
    end
    
    def after_test(args)
      target.after_called = true
      target.after_result = result
    end
  end
  
  def setup
    @object = TestObject.new
    @observer = TestObserver.new
    @observer.observe(@object)
  end
  
  def test_observe
    TestObject.captures.each do |c|
      assert_nil @object.send(c), "capture: #{c}"
    end
    
    @object.test(:result)
    
    TestObject.captures.reject { |c| c == :before_result }.each do |c|
      assert @object.send(c), "capture: #{c}"
    end
    assert_nil @object.before_result
  end
  
  def test_observe__double
    e = assert_raises(MethodObserver::ObserverCannotObserveTwiceError) { @observer.observe(@object) }
    assert_equal 'observer cannot observe twice', e.message
  end
  
end