source 'https://rubygems.org'

ruby '2.2.1'

# Gems required in all environments
gem 'rails', '4.2.1.rc3'

gem 'puma'
gem 'puma_auto_tune', github: "schneems/puma_auto_tune"
gem 'skylight'
gem 'git_hub_bub'
gem 'pg'
gem 'resque'
gem 'resque_def'
gem 'omniauth', github: 'schneems/omniauth', branch: 'schneems/hashie-breakup'
gem 'omniauth-github'
gem 'will_paginate'
gem 'httparty'
gem 'dalli'
gem 'wicked'
gem 'rails_autolink'
gem 'bluecloth'
gem 'maildown'
gem 'rrrretry'
gem 'jquery-rails'
gem 'devise'
gem 'rack-timeout'
gem 'unicorn'
gem 'mail_view', '~> 1.0.2'
gem 'valid_email'
gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.0.3'

group :development do
  gem 'foreman'
  gem 'quiet_assets'
  gem 'spring'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'capybara', '2.3.0'
  # Not essential but helpful for save_and_open_page
  gem 'launchy'
  gem 'webmock'
  gem 'vcr'
  gem 'mocha', require: false
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'teaspoon'
  gem 'dotenv-rails'
end

group :production do
  gem 'rails_12factor'
end


gem 'newrelic_rpm'
gem 'derailed_benchmarks'
