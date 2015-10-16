require 'minitest/autorun'

if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails'
end

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "capybara/rails"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:github, {
  uid: 'mockstar',
  credentials: {
    token: ENV['GITHUB_API_KEY'] || "d401116495671f0a0ceca9276e677eff"
  },
  email: "mockstar@example.com",
  info: {
    nickname: 'mockstar'
  },
  extra: {
    raw_info: {
      name: "Mock Star"
    }
  }
})

VCR.configure do |c|
  # This 'allow' should be temporary, work towards covering
  # everything via vcr because github rate limits
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock

  'GITHUB_APP_ID GITHUB_APP_SECRET GITHUB_API_KEY'.split(' ').each do |secure|
    sensitive = ENV[secure] ||= secure
    c.filter_sensitive_data("<#{secure}>") { sensitive }
  end
end


# Provide default configuration.
#
# You can override various configuration directives defined here by using arguments with the teaspoon command.
#
# teaspoon --driver=selenium --suppress-log
# rake teaspoon DRIVER=selenium SUPPRESS_LOG=false

Teaspoon.setup do |config|
  # Driver / Server
  #config.driver           = "phantomjs" # available: phantomjs, selenium
  #config.server           = nil # defaults to Rack::Server

  # Behaviors
  #config.server_timeout   = 20 # timeout for starting the server
  #config.server_port      = nil # defaults to any open port unless specified
  #config.fail_fast        = true # abort after the first failing suite

  # Output
  #config.formatters       = "dot" # available: dot, tap, tap_y, swayze_or_oprah
  #config.suppress_log     = false # suppress logs coming from console[log/error/debug]
  #config.color            = true

  # Coverage (requires istanbul -- https://github.com/gotwarlost/istanbul)
  #config.coverage         = true
  #config.coverage_reports = "text,html,cobertura"
end

module ActionDispatch
  class IntegrationTest
    include Capybara::DSL

    def login_via_github
      visit "/users/auth/github"
    end
  end
end

require 'mocha/setup'

require 'sidekiq/testing'
Sidekiq::Testing.inline!
