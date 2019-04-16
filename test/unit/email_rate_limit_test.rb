# frozen_string_literal: true

require 'test_helper'

class EmailRateLimitTest < ActiveSupport::TestCase
  def seed_array
    @seed_array ||= (1..350).to_a # max value has to be divisible by the multiplier of th higest used value i.e. 10_000/30.0
  end

  test "decides daily email frequency" do
    # Daily
    last_clicked_days_ago = 0..3
    multiplier            = 1
    valid_values          = seed_array.map { |n| n * multiplier }
    day_ago               = rand(last_clicked_days_ago)
    clicked_ago           = valid_values.sample

    assert EmailRateLimit.new(day_ago).now?(clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}).now?(#{clicked_ago}) to be true, was not"
    # Use user email frequency settings
    assert EmailRateLimit.new(day_ago, minimum_frequency: "daily").now?(clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}, minimum_frequency: 'daily').now?(#{clicked_ago}) to be true, was not"
  end

  test "wait" do
    # wait
    last_clicked_days_ago = 4..6
    multiplier            = 1
    valid_values          = seed_array.map { |n| n * multiplier }
    invalid_values        = last_clicked_days_ago.to_a - valid_values
    day_ago               = rand(last_clicked_days_ago)
    bad_clicked_ago       = invalid_values.sample
    assert EmailRateLimit.new(day_ago).skip?(bad_clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}).skip?(#{bad_clicked_ago}) to be true, was not"
  end

  test "twice a week" do
    # twice a week
    last_clicked_days_ago = 7..13
    multiplier            = 3
    valid_values          = seed_array.map { |n| n * multiplier }
    invalid_values        = last_clicked_days_ago.to_a - valid_values
    day_ago               = rand(last_clicked_days_ago)
    clicked_ago           = valid_values.sample
    bad_clicked_ago = invalid_values.sample
    assert EmailRateLimit.new(day_ago).now?(clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}).now?(#{clicked_ago}) to be true, was not"
    assert EmailRateLimit.new(day_ago).skip?(bad_clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}).skip?(#{bad_clicked_ago}) to be true, was not"

    # Use user email frequency settings
    assert EmailRateLimit.new(day_ago, minimum_frequency: "twice_a_week").now?(clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}, minimum_frequency: 'twice_a_week').now?(#{clicked_ago}) to be true, was not"
  end

  test "once a week" do
    # once a week
    last_clicked_days_ago = 14..30
    multiplier            = 7
    valid_values          = seed_array.map { |n| n * multiplier }
    invalid_values        = last_clicked_days_ago.to_a - valid_values
    day_ago               = rand(last_clicked_days_ago)
    clicked_ago           = valid_values.sample
    bad_clicked_ago = invalid_values.sample
    assert EmailRateLimit.new(day_ago).now?(clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}).now?(#{clicked_ago}) to be true, was not"
    assert EmailRateLimit.new(day_ago).skip?(bad_clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}).skip?(#{bad_clicked_ago}) to be true, was not"

    # Use user email frequency settings
    assert EmailRateLimit.new(day_ago, minimum_frequency: "once_a_week").now?(clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}, minimum_frequency: 'once_a_week').now?(#{clicked_ago}) to be true, was not"
  end

  test "once a month" do
    # once a month
    last_clicked_days_ago = 31..10_000
    multiplier            = 30
    valid_values          = seed_array.map { |n| n * multiplier }
    invalid_values        = last_clicked_days_ago.to_a - valid_values
    day_ago               = rand(last_clicked_days_ago)
    clicked_ago           = valid_values.sample
    bad_clicked_ago = invalid_values.sample
    assert EmailRateLimit.new(day_ago).now?(clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}).now?(#{clicked_ago}) to be true, was not"
    assert EmailRateLimit.new(day_ago).skip?(bad_clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}).skip?(#{bad_clicked_ago}) to be true, was not"

    # Use user email frequency settings
    assert EmailRateLimit.new(day_ago, minimum_frequency: "once_a_month").now?(clicked_ago), "Expected  EmailRateLimit.new(#{day_ago}, minimum_frequency: 'once_a_month').now?(#{clicked_ago}) to be true, was not"
  end
end
