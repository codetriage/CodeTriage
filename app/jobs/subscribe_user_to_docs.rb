# frozen_string_literal: true

class SubscribeUserToDocs < UserBasedJob
  def perform(user)
    user.subscribe_docs!
  end
end
