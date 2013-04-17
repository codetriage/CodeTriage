source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'ar_pg_array'
gem 'resque'
gem 'sextant'
gem 'unicorn'
gem 'omniauth-github'
gem 'mail_view',          '~> 1.0.2'
gem 'will_paginate'
gem 'httparty'
gem 'thin'
gem 'dalli'
gem 'wicked'
gem 'rails_autolink'
gem 'bluecloth'


gem 'rrrretry'

group :development do
  gem 'foreman'
  gem 'quiet_assets'
end

group :test do
  gem 'capybara'
  # Not essential but helpful for save_and_open_page
  gem 'launchy'
  gem 'webmock'
  gem 'vcr'
  gem 'mocha', require: false
  gem 'shoulda'
  gem 'simplecov', :require => false
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'

  gem 'therubyracer'
  gem "less-rails"
end

gem 'jquery-rails'
gem 'devise',                  "~> 2.0.4"
gem "twitter-bootstrap-rails", "~> 2.2.6"

gem "rack-timeout"
