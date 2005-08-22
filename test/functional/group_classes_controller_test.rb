require File.dirname(__FILE__) + '/../test_helper'
require 'group_classes_controller'

# Re-raise errors caught by the controller.
class GroupClassesController; def rescue_action(e) raise e end; end

class GroupClassesControllerTest < Test::Unit::TestCase
  def setup
    @controller = GroupClassesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
