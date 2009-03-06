require File.dirname(__FILE__) + '/../../test_helper'

#
# This test exercises the AbstractModelController by excercising the Layout
# model and the LayoutController views.
#
class Admin::AbstractModelControllerTest < Test::Unit::TestCase
  
  class TestModelController < Admin::AbstractModelController
    model_class Layout
    
    def rescue_action(e) raise e end
    
    def default_template_name(default_action_name = action_name)
      "#{Admin::LayoutController.controller_path}/#{default_action_name}"
    end
  end
  
  fixtures :users, :layouts
  test_helper :layouts, :caching, :routing
  
  def setup
    @controller = TestModelController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:existing)
    @cache = @controller.cache = FakeResponseCache.new
    
    @layout_name = "Test Layout"
    
    destroy_test_layout
    setup_custom_routes
  end
  
  def teardown
    teardown_custom_routes
  end
  
  def test_initialize
    @controller = TestModelController.new
    assert_kind_of ResponseCache, @controller.cache
  end
  
  def test_index
    get :index
    assert_response :success
    layouts = assigns(:layouts)
    assert_kind_of Array, layouts
    assert_kind_of Layout, layouts.first
  end
  
  def test_new
    get :new, :layout => layout_params
    assert_response :success
    assert_template 'admin/layout/edit'
    
    @layout = assigns(:layout)
    assert_kind_of Layout, @layout
    assert_nil @layout.name
  end
  def test_new__post
    post :new, :layout => layout_params
    assert_redirected_to layout_index_url
    assert_match /saved/, flash[:notice]
    assert_kind_of Layout, get_test_layout
  end
  def test_new__post_with_invalid_layout
    post :new, :layout => layout_params(:name => nil)
    assert_response :success
    assert_match /error/, flash[:error]
    assert_nil get_test_layout
  end
  def test_new__save_and_continue_editing
    post :new, :layout => layout_params, :continue => 'Save and Continue Editing'
    @layout = get_test_layout
    assert_redirected_to layout_edit_url(:id => @layout.id)
  end
  
  def test_edit
    get :edit, :id => '1', :layout => layout_params
    assert_response :success
    
    @layout = assigns(:layout)
    assert_kind_of Layout, @layout
    assert_equal 'Home Page', @layout.name
  end  
  def test_edit__post
    @layout = create_test_layout
    post :edit, :id => @layout.id, :layout => layout_params(:content => 'edited')
    assert_response :redirect
    assert_equal 'edited', get_test_layout.content
    
    # TODO: Test what happens when an invalid page is submitted 
  end
  
  def test_remove
    @layout = create_test_layout
    get :remove, :id => @layout.id 
    assert_response :success
    assert_equal @layout, assigns(:layout)
    assert_not_nil get_test_layout
  end
  def test_remove__post
    @layout = create_test_layout
    post :remove, :id => @layout.id
    assert_nil get_test_layout
    assert_redirected_to layout_index_url
    assert_match /deleted/, flash[:notice]
  end
  
  def test_clears_cache_on_save
    @layout = layouts(:main)
    post :edit, :id => @layout.id, :layout => layout_params(:content => 'edited')
    assert_redirected_to layout_index_url
    assert_equal true, @cache.cleared?
  end
  
  def test_not_cleared_when_invalid
    @layout = layouts(:main)
    post :edit, :id => @layout.id, :layout => layout_params(:name => 'x' * 1000)
    assert_response :success
    assert_equal false, @cache.cleared?
  end
  
end