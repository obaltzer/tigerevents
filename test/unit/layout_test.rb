require File.dirname(__FILE__) + '/../test_helper'

class LayoutTest < Test::Unit::TestCase
  fixtures :layouts

  def setup
    @layout = Layout.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Layout,  @layout
  end
end
