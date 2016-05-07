source 'https://rubygems.org'

ruby '2.3.1'

gem 'mime-types', '~> 2.6.1', require: 'mime/types/columnar'

# Gems required in all environments
if ENV["RAILS_MASTER"] == '1'
  gem 'rails', git: 'https://github.com/rails/rails.git'
else
  gem 'rails', '5.0.0.rc1'
end

gem 'puma', '3.0.0.rc1'
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
gem 'maildown', '2.0.0'
gem 'rrrretry'
gem 'jquery-rails'
gem 'devise', '4.0.0.rc1'
gem 'warden', '1.2.6'
gem 'rack-timeout'
gem 'mail_view', '~> 1.0.2'
gem 'valid_email'
gem 'sass-rails', '6.0.0.beta1'
gem 'bourbon'
gem 'neat'
gem 'autoprefixer-rails', '~> 6.3.3.1'
gem 'normalize-rails'
gem 'coffee-rails', '~> 4.1.0'
gem 'uglifier', '>= 1.0.3'
gem 'slim-rails'

group :development do
  gem 'foreman'
  gem 'quiet_assets'
  gem 'spring'
  gem 'web-console'
  gem 'bullet', '5.0.0'
  gem 'listen'
end

group :test do
  gem 'capybara', '2.6.2'
  # Not essential but helpful for save_and_open_page
  gem 'launchy'
  gem 'webmock'
  gem 'vcr'
  gem 'mocha', require: false
  gem 'simplecov', require: false
  gem 'rails-controller-testing'
end

group :development, :test do
  gem 'teaspoon', '~> 0.7.4'
  gem 'dotenv-rails', '2.1.0'
  gem 'derailed_benchmarks'
end

group :production do
  gem 'rails_12factor'
end

gem 'the_lone_dyno'

gem 'sidekiq'
gem 'sinatra', require: nil, git: 'https://github.com/sinatra/sinatra.git'

gem 'aws-sdk', '~> 2'

gem 'mail', require: ['mail', 'mail/utilities', 'mail/parsers'] # parsers is used by `valid_email` and may be causing https://github.com/mikel/mail/issues/912#issuecomment-170121429
gem 'record_tag_helper', '~> 1.0'

gem 'sprockets'      , '4.0.0.beta2'
gem 'sprockets-rails'

gem 'babel-transpiler'
