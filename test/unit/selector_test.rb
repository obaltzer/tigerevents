require File.dirname(__FILE__) + '/../test_helper'

class SelectorTest < Test::Unit::TestCase
  fixtures :selectors

  def setup
    @selector = Selector.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Selector,  @selector
  end
end
