class SubscribeUserToDocs < ApplicationJob
  def perform(id)
    User.find(id).subscribe_docs!
  end
end
