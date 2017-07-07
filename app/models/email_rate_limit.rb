# This class is used to determine the rate at which emails are sent.
# We look at two parameters, the last day the user clicked on a link and the
# last day we sent them an email. The idea is that we should send more active users
# more emails. Less active users should get fewer emails so that it's less annoying.
class EmailRateLimit
  def initialize(last_clicked_days_ago, minimum_frequency: EmailFrequency::DAILY)
    @frequency_from_last_click = EmailFrequency.from_days(last_clicked_days_ago)
    @frequency_from_preference = EmailFrequency.new(minimum_frequency)
  end

  def skip?(last_sent_days_ago)
    !now?(last_sent_days_ago)
  end

  # send an email if you've clicked one in the last 3 days
  # back down to twice a week if they've not clicked in the last 7
  def now?(last_sent_days_ago)
    case less_frequent_of_activity_and_preference.to_s
    when EmailFrequency::DAILY
      true
    when EmailFrequency::TWICE_A_WEEK
      last_sent_days_ago.modulo(3).zero?
    when EmailFrequency::ONCE_A_WEEK
      last_sent_days_ago.modulo(7).zero?
    when EmailFrequency::ONCE_A_MONTH
      last_sent_days_ago.modulo(30).zero?
    when EmailFrequency::WAIT
      false
    end
  end

  private
    # When a user provides a default frequency use that value
    # For instance if a user has "twice_a_week" selected as a default yet we calculate their
    # send rate as "daily" the higher value will be used i.e. "twice_a_week". If however
    # they are inactive and calculated frequency is "once_a_month" we will use that instead.
    # The highest duration wins between user supplied and calculated
    def less_frequent_of_activity_and_preference
      [@frequency_from_last_click, @frequency_from_preference].min
    end
end
