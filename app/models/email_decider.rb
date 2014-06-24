class EmailDecider

  def initialize(clicked)
    @days = clicked
  end

  def skip?(sent)
    !now?(sent)
  end

  # send an email if you've clicked one in the last 3 days
  # back down to twice a week if they've not clicked in the last 7
  def now?(sent)
    case frequency
    when :daily
      true
    when :once_a_week
      sent.modulo(7).zero?
    when :twice_a_week
      sent.modulo(3).zero?
    when :wait
      false
    else
      raise "Unknown case: #{frequency}"
    end
  end

  private
    def frequency
      case @days
      when 0..3
        :daily
      when 7..14
        :twice_a_week
      when 14..Float::INFINITY
        :once_a_week
      else
        :wait
      end
    end
end