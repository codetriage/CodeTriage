# This class is used to determine the rate at which emails are sent.
# We look at two parameters, the last day the user clicked on a link and the
# last day we sent them an email. The idea is that we should send more active users
# more emails. Less active users should get fewer emails so that it's less annoying.
class EmailDecider

  def initialize(last_clicked_days_ago)
    @last_clicked_days_ago = last_clicked_days_ago
  end

  def skip?(last_sent_days_ago)
    !now?(last_sent_days_ago)
  end

  # send an email if you've clicked one in the last 3 days
  # back down to twice a week if they've not clicked in the last 7
  def now?(last_sent_days_ago)
    case frequency_of_send_rate
    when :daily
      true
    when :once_a_week
      last_sent_days_ago.modulo(7).zero?
    when :twice_a_week
      last_sent_days_ago.modulo(3).zero?
    when :once_a_month
      last_sent_days_ago.modulo(30).zero?
    when :wait
      false
    else
      raise "Unknown case: #{frequency}"
    end
  end

  private
    def frequency_of_send_rate
      case @last_clicked_days_ago
      when 0..3
        :daily
      when 7..14
        :twice_a_week
      when 14..30
        :once_a_week
      when 31..Float::INFINITY
        :once_a_month
      else
        :wait
      end
    end
end