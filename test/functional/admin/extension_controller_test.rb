require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/extension_controller'

# Re-raise errors caught by the controller.
class Admin::ExtensionController; def rescue_action(e) raise e end; end

class Admin::ExtensionControllerTest < Test::Unit::TestCase
  
  fixtures :users
  
  def setup
    @controller = Admin::ExtensionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:admin)
  end

  def test_index
    get :index
    assert_response :success
    assert_equal sorted_ext, assigns(:extensions)
  end
  
  def test_update
    all_extensions = Radiant::Extension.descendants.dup
    active_extensions = Radiant::Extension.descendants.select { |e| e.active? }
    assert_equal all_extensions, active_extensions
    
    flagged_extensions = [all_extensions[0]]
    unflagged_extensions = all_extensions - flagged_extensions
    post :update, :enabled_extensions => flagged_extensions.collect { |e| e.extension_name }
    assert_equal unflagged_extensions, Radiant::Extension.descendants.select { |e| !e.active? }
  end
  
  private
  
    def sorted_ext
      Radiant::Extension.descendants.sort_by { |e| e.extension_name }
    end
end
