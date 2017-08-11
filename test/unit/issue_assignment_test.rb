require 'test_helper'

class IssueAssignmentTest < ActiveSupport::TestCase
  test "validates presence of relevant ids" do
    ia = IssueAssignment.new
    ia.valid?
    assert_equal ["can't be blank"], ia.errors[:issue_id]
  end
end
