require File.dirname(__FILE__) + '/../test_helper'

class GroupCategoryTest < Test::Unit::TestCase
  fixtures :group_classes

  def setup
    @group_class = GroupClass.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of GroupClass,  @group_class
  end
end
