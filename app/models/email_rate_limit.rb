# This class is used to determine the rate at which emails are sent.
# We look at two parameters, the last day the user clicked on a link and the
# last day we sent them an email. The idea is that we should send more active users
# more emails. Less active users should get fewer emails so that it's less annoying.
class EmailRateLimit
  USER_STATES = ["daily", "twice_a_week", "once_a_week", "once_a_month"]

  def initialize(last_clicked_days_ago, minimum_frequency: nil)
    @last_clicked_days_ago = last_clicked_days_ago
    @minimum_frequency     = minimum_frequency
  end

  def skip?(last_sent_days_ago)
    !now?(last_sent_days_ago)
  end

  # send an email if you've clicked one in the last 3 days
  # back down to twice a week if they've not clicked in the last 7
  def now?(last_sent_days_ago)
    case minimum_calculated_frequency
    when "daily"
      true
    when "twice_a_week"
      last_sent_days_ago.modulo(3).zero?
    when "once_a_week"
      last_sent_days_ago.modulo(7).zero?
    when "once_a_month"
      last_sent_days_ago.modulo(30).zero?
    when "wait"
      false
    else
      raise "Unknown case: #{frequency}"
    end
  end

  private

    # When a user provides a default frequency use that value
    # For instance if a user has "twice_a_week" selected as a default yet we calculate their
    # send rate as "daily" the higher value will be used i.e. "twice_a_week". If however
    # they are inactive and calculated frequency is "once_a_month" we will use that instead.
    # The highest duration wins between user supplied and calculated
    def minimum_calculated_frequency
      return frequency_of_send_rate if @minimum_frequency.blank?
      return frequency_of_send_rate if !USER_STATES.include?(frequency_of_send_rate)

      if USER_STATES.index(@minimum_frequency) > USER_STATES.index(frequency_of_send_rate)
        @minimum_frequency
      else
        frequency_of_send_rate
      end
    end

    def frequency_of_send_rate
      case @last_clicked_days_ago
      when 0..3
        "daily"
      when 7..13
        "twice_a_week"
      when 14..30
        "once_a_week"
      when 31..Float::INFINITY
        "once_a_month"
      else
        "wait"
      end
    end
end
