require File.dirname(__FILE__) + '/../test_helper'

class ExtensionInitializationTest < Test::Unit::TestCase
  def setup
    Dependencies.mechanism = :load
    Radiant::ExtensionLoader.reactivate Radiant::Extension.descendants
  end
  
  def teardown
    Dependencies.mechanism = :require
  end
  
  def test_load_paths
    assert_nothing_raised { BasicExtension }
    assert_equal File.join(File.expand_path(RADIANT_ROOT), 'test', 'fixtures', 'extensions', 'basic'), BasicExtension.root
    assert_equal 'Basic', BasicExtension.extension_name
    assert_nothing_raised { BasicExtensionController }
    assert_nothing_raised { BasicExtensionModel }
  end
  
  def test_reloading
    assert_basic_extension_annotations
    assert_view_paths
    assert_admin_tabs "Basic Extension Tab"
    
    BasicExtensionController.instance_variable_set("@action_methods", nil) # ActionController cached no index action
    BasicExtension.version = "should get changed back on clear"
    BasicExtensionController.module_eval do
      def index
        render :text => "should get changed back on clear"
      end
    end
    assert_view_paths :index => /should get changed/
    
    Dependencies.clear
    assert_basic_extension_annotations
    assert_view_paths
    assert_admin_tabs "Basic Extension Tab"
  end
  
  def test_reactivate
    assert_admin_tabs "Basic Extension Tab"
    Radiant::ExtensionLoader.reactivate []
    assert_admin_tabs
  ensure
    Radiant::ExtensionLoader.reactivate Radiant::Extension.descendants
    assert BasicExtension.active?
  end
  
  def test_view_paths
    assert_view_paths
  end
  
  def test_mailer_view_paths
    mail = BasicExtensionMailer.create_message
    assert_match /Hello, Extension Mailer World/, mail.body
  end
  
  def test_basic_extension_annotations
    assert_basic_extension_annotations
  end

  private
  
    def assert_admin_tabs(more_tabs = [])
      default_tabs = %w(Pages Snippets Layouts)
      all_tabs = default_tabs + [more_tabs].flatten
      assert_equal all_tabs.size, Radiant::AdminUI.tabs.size
      Radiant::AdminUI.tabs.each { |tab| assert all_tabs.include?(tab.name) }
    end
    
    def assert_basic_extension_annotations
      assert_equal "1.1", BasicExtension.version
      assert_equal "just a test", BasicExtension.description
      assert_equal "http://test.com", BasicExtension.url
    end
  
    def assert_view_paths(expected = {}, message = nil)
      expected.reverse_merge!({
        :index    => /Hello, Extension World/,
        :override => /Hello, Overridden Extension World/,
        :routing  => /You're routing works/,
      })
        
      @controller = BasicExtensionController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      
      [:index, :override, :routing].each do |action|
        get action
        assert_match expected[action], @response.body, message
      end
    end
end
