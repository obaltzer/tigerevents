require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < Test::Unit::TestCase
  fixtures :activities

  def setup
    @activity = Activity.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Activity,  @activity
  end
end
