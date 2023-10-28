# frozen_string_literal: true

module UsersHelper
  def available_times_of_day
    (0...24).map { |hour| Time.utc(2000, 1, 1, hour, 0o0, 0) }
  end
end
