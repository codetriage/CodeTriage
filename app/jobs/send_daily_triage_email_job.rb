class SendDailyTriageEmailJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    User.find(id).send_daily_triage!
  end
end
