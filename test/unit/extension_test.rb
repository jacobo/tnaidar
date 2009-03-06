require File.dirname(__FILE__) + '/../test_helper'

class ExtensionTest < Test::Unit::TestCase
  
  def test_admin
    assert_equal Radiant::AdminUI.instance, Radiant::Extension.admin
  end
  
  class BasicExtensionObserver < MethodObserver
    cattr_accessor :activate_called, :deactivate_called
    @@activate_called = false
    def before_activate
      @@activate_called = true
    end
    @@deactivate_called = false
    def before_deactivate
      @@deactivate_called = true
    end
  end
  
  def test_activate
    BasicExtension.activate
    assert BasicExtension.active?
    BasicExtensionObserver.new.observe(BasicExtension.instance)
    BasicExtension.activate
    assert BasicExtension.active?
    assert !BasicExtensionObserver.activate_called
  end
  
  def test_deactivate
    assert BasicExtension.active?
    BasicExtensionObserver.new.observe(BasicExtension.instance)
    BasicExtension.deactivate
    assert !BasicExtension.active?
    assert BasicExtensionObserver.deactivate_called
    BasicExtensionObserver.deactivate_called = false
    BasicExtension.deactivate
    assert !BasicExtension.active?
    assert !BasicExtensionObserver.deactivate_called
  end
  
end