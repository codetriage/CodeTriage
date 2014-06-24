require 'test_helper'

class EmailDeciderTest < ActiveSupport::TestCase
  test "decides email frequency" do
    # daily
    assert EmailDecider.new(rand(0..3)).now?(1)

    # wait
    assert EmailDecider.new(rand(4..6)).skip?(1)

    # twice a week
    assert EmailDecider.new(rand(7..13)).now?([3, 6, 9, 12].sample)
    assert EmailDecider.new(rand(7..13)).skip?([4, 7, 10, 13].sample)

    # once a week
    assert EmailDecider.new(rand(14..100)).now?([7, 14, 21, 28].sample)
    assert EmailDecider.new(rand(14..100)).skip?([8, 15, 22, 29].sample)
  end
end
