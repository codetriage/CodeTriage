require 'test_helper'

class EmailDeciderTest < ActiveSupport::TestCase
  test "decides email frequency" do
    seed_array = [1,2,3,4,5,6,7]
    # daily
    last_clicked_days_ago = 0..3
    multiplier            = 1
    valid_values          = seed_array.map { |n| n * multiplier }
    invalid_values        = last_clicked_days_ago.to_a - valid_values
    assert EmailDecider.new(rand(last_clicked_days_ago)).now?(valid_values.sample)

    # wait
    last_clicked_days_ago = 4..6
    multiplier            = 1
    valid_values          = seed_array.map { |n| n * multiplier }
    invalid_values        = last_clicked_days_ago.to_a - valid_values
    assert EmailDecider.new(rand(last_clicked_days_ago)).skip?(valid_values.sample)


    # twice a week
    last_clicked_days_ago = 7..13
    multiplier            = 3
    valid_values          = seed_array.map { |n| n * multiplier }
    invalid_values        = last_clicked_days_ago.to_a - valid_values
    assert EmailDecider.new(rand(last_clicked_days_ago)).now?(valid_values.sample)
    assert EmailDecider.new(rand(last_clicked_days_ago)).skip?(invalid_values.sample)

    # once a week
    last_clicked_days_ago = 14..30
    multiplier            = 7
    valid_values          = seed_array.map { |n| n * multiplier }
    invalid_values        = last_clicked_days_ago.to_a - valid_values
    assert EmailDecider.new(rand(last_clicked_days_ago)).now?(valid_values.sample)
    assert EmailDecider.new(rand(last_clicked_days_ago)).skip?(invalid_values.sample)

    # once a month
    last_clicked_days_ago = 31..10_000
    multiplier            = 30
    valid_values          = seed_array.map { |n| n * multiplier }
    invalid_values        = last_clicked_days_ago.to_a - valid_values
    assert EmailDecider.new(rand(last_clicked_days_ago)).now?(valid_values.sample)
    assert EmailDecider.new(rand(last_clicked_days_ago)).skip?(invalid_values.sample)
  end
end
