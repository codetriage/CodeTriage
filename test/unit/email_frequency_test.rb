require 'test_helper'

class EmailFrequencyTest < ActiveSupport::TestCase
  test "an invalid frequency is invalid" do
    assert_raise(ArgumentError) { EmailFrequency.new('foo') }
  end

  test "#to_s returns the description" do
    description = EmailFrequency::FREQUENCIES.sample

    assert_equal EmailFrequency.new(description).to_s, description
  end

  test "frequencies with the same description are eql" do
    description = EmailFrequency::FREQUENCIES.sample
    assert_equal EmailFrequency.new(description), EmailFrequency.new(description)
  end

  test "greater than" do
    assert EmailFrequency.new("daily") > EmailFrequency.new("twice_a_week")
  end

  test "less than" do
    assert EmailFrequency.new("twice_a_week") < EmailFrequency.new("daily")
  end

  test "#more_often? synonym of >" do
    assert EmailFrequency.new("daily").more_often? EmailFrequency.new("twice_a_week")
  end

  test "#less_often? synonmym of <" do
    assert EmailFrequency.new("twice_a_week").less_often? EmailFrequency.new("daily")
  end
end
