require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'trashed/railclock'
require 'statsd'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CodeTriage
  class Application < Rails::Application
    config.trashed_periodic.statsd = Statsd.new('localhost', ENV["PORT"]) if ENV["PORT"]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_job.queue_adapter = :sidekiq
    config.encoding = "utf-8"
    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false
    # Set i18n.enforce_available_locales to true
    config.i18n.enforce_available_locales = true

    config.force_ssl = ENV["APPLICATION_HOST"]
    config.middleware.insert_after ActionDispatch::SSL, Rack::CanonicalHost, ENV["APPLICATION_HOST"] if ENV["APPLICATION_HOST"]
  end
end
