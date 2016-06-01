class SubscribeUserToDocs < ActiveJob::Base
  queue_as :default

  def perform(id)
    User.find(id).subscribe_docs!
  end
end
