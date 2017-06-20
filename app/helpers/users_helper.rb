module UsersHelper
  def available_times_of_day
    (0...24).map { |hour| Time.utc(2000, 1, 1, hour, 00, 0) }
  end
end
