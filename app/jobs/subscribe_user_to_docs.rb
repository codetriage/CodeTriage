# frozen_string_literal: true

class SubscribeUserToDocs < ApplicationJob
  def perform(user)
    user.subscribe_docs!
  end
end
