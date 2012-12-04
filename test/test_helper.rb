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
  :uid => 'mockstar',
  :credentials => {
    :token => "d401116495671f0a0ceca9276e677eff"
  },
  :email => "mockstar@example.com",
  :info => {
    :nickname => 'mockstar'
  },
  :extra => {
    :raw_info => {
      :name => "Mock Star"
    }
  }
})

VCR.configure do |c|
  # This 'allow' should be temporary, work towards covering
  # everything via vcr because github rate limits
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
end

module ActionController
  class IntegrationTest
    include Capybara::DSL

    def login_via_github
      visit "/users/auth/github"
    end
  end
end

require 'mocha/setup'
