# frozen_string_literal: true

class SentryJob < ApplicationJob
  def perform(event)
    Sentry.capture_event(event)
  end
end
