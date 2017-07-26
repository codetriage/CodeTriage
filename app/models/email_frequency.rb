# Value Object representing the frequency with which email is sent. Used to
#   compare two different frequencies, e.g. between a set value and calculated
#   value.
class EmailFrequency
  include Comparable

  # More frequent has a higher index, less frequent a lower index. The index is
  #   used to compare the frequencies.
  FREQUENCIES = [
    # Wait is the _least_ frequent; used when a user has not yet clicked an email link, so we shouldn't send again (yet)
    WAIT         = "wait",
    ONCE_A_MONTH = "once_a_month",
    ONCE_A_WEEK  = "once_a_week",
    TWICE_A_WEEK = "twice_a_week",
    DAILY        = "daily"
  ]

  USER_FREQUENCIES = FREQUENCIES - [WAIT]

  # Human-readable string representing the frequency; based on the constant
  #   FREQUENCIES above.
  attr_reader :frequency_description

  def initialize(frequency_description)
    raise ArgumentError unless frequency_description.in? FREQUENCIES
    @frequency_description = frequency_description
  end

  # Constructor function that turns an int (num_days) into an EmailFrequency
  def self.from_days(num_days)
    case num_days
    when 0..3
      new(DAILY)
    when 7..13
      new(TWICE_A_WEEK)
    when 14..30
      new(ONCE_A_WEEK)
    when 31..Float::INFINITY
      new(ONCE_A_MONTH)
    else
      new(WAIT)
    end
  end

  # With the Comparable module, this allows for `>` and `<` comparisons
  def <=>(other)
    FREQUENCIES.index(frequency_description) <=>
      FREQUENCIES.index(other.frequency_description)
  end

  def eql?(other)
    frequency_description == other.frequency_description
  end

  # Alias of `>`, used for easier code comprehension
  def more_often?(other)
    self > other
  end

  # Alias of `<`, used for easier code comprehension
  def less_often?(other)
    self < other
  end

  def to_s
    frequency_description
  end
end
