# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "capybara/rails"
require 'webmock'

WebMock.enable!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  # https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
  include Warden::Test::Helpers
  Warden.test_mode!

  setup do
    logout(:user)
  end
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
                               name: "Mock Star",
                               avatar_url: "http://gravatar.com/avatar/default"
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

module ActionDispatch
  class IntegrationTest
    include Capybara::DSL

    def login_via_github
      # Works based off of omniauth's mock
      # The user will be looked up from the database and updated
      # based off of the info in the mock.
      visit "/users/auth/github"
    end
  end
end

require 'mocha/setup'
require 'minitest/mock'
require 'sidekiq/testing'
