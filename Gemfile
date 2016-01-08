source 'https://rubygems.org'

ruby '2.3.0'

gem 'mime-types', '~> 2.6.1', require: 'mime/types/columnar'

# Gems required in all environments
gem 'rails', '5.0.0.beta1'

gem 'puma'
gem 'puma_auto_tune'
gem 'git_hub_bub'
gem 'pg'
gem 'omniauth', '1.3.1'
gem 'omniauth-github'
gem 'will_paginate', '3.1.0'
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
gem 'mail_view', '~> 1.0.2'
gem 'valid_email'
gem 'sass-rails', '~> 5.0.0'
gem 'bourbon'
gem 'neat'
gem 'autoprefixer-rails'
gem 'normalize-rails'
gem 'coffee-rails', '~> 4.1.0'
gem 'uglifier', '>= 1.0.3'
gem 'slim-rails'

group :development do
  gem 'foreman'
  gem 'quiet_assets'
  gem 'spring'
  gem 'web-console', '~> 2.0'
  gem 'bullet', '5.0.0'
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
  gem 'teaspoon', '~> 0.7.4'
  # gem 'dotenv-rails'
  gem 'derailed_benchmarks'
end

group :production do
  gem 'rails_12factor'
end

gem 'the_lone_dyno'

gem 'sidekiq'
# gem 'sinatra', :require => nil

gem 'aws-sdk', '~> 2'
gem 'multi_fetch_fragments'

gem "bullet", :group => "development"

gem 'mail', require: ['mail', 'mail/utilities', 'mail/parsers'] # parsers is used by `valid_email` and may be causing https://github.com/mikel/mail/issues/912#issuecomment-170121429

gem 'oauth2', github: 'matthewrudy/oauth2', branch: 'rack2'
