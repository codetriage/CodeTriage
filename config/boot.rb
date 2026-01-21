# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Ruby 3.2+ requires these to be explicitly loaded before bootsnap
require "logger"
if ENV["RAILS_ENV"] == "test"
  require "minitest"
  require "minitest/mock"
end

require "bootsnap/setup" # Speed up boot time by caching expensive operations.
