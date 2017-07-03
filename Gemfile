source 'https://rubygems.org'

ruby '> 2.3', '< 2.5'

git_source :github do |name|
  "https://github.com/#{name}.git"
end

gem 'mime-types', '~> 2.6.1', require: 'mime/types/columnar'

# Gems required in all environments
if ENV["RAILS_MASTER"] == '1'
  gem 'rails', git: 'https://github.com/rails/rails.git'
  gem 'arel', git: 'https://github.com/rails/arel.git'
else
  gem 'rails', '5.1.1'
end

gem 'puma', '~> 3.x'
gem 'git_hub_bub'
gem 'pg'
gem 'omniauth', '1.3.1'
gem 'omniauth-github'
gem 'will_paginate', '3.1.0'
gem 'local_time', github: 'basecamp/local_time', branch: '2-0'
gem 'dalli'
gem 'wicked'
gem 'rails_autolink'
gem 'bluecloth'
gem 'maildown', '2.0.0'
gem 'rrrretry'
gem 'jquery-rails'
gem 'devise'
gem 'warden', '1.2.6'
gem 'rack-timeout'
gem 'mail_view', '~> 1.0.2'
gem 'valid_email'
# gem 'sass-rails', '6.0.0.beta1'
gem 'sassc-rails', github: "schneems/sassc-rails", branch: "schneems/sprockets4"
gem 'sassc'

gem 'bourbon'
gem 'neat'
gem 'autoprefixer-rails', '~> 6.3.3'
gem 'normalize-rails'
gem 'coffee-rails', '~> 4.2.0'
gem 'uglifier', '>= 1.0.3'
gem 'slim-rails'

group :development do
  gem 'foreman'
  gem 'spring'
  gem 'web-console'
  gem 'bullet'
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
  gem 'teaspoon'
  gem 'dotenv-rails'
  gem 'derailed_benchmarks'
  gem 'faker', require: false
  gem 'pry'
end

gem 'rack-mini-profiler'

gem 'the_lone_dyno'

gem 'sidekiq'
# gem 'sinatra', require: nil, git: 'https://github.com/sinatra/sinatra.git'

gem 'aws-sdk', '~> 2'

gem 'mail', require: ['mail', 'mail/utilities', 'mail/parsers'] # parsers is used by `valid_email` and may be causing https://github.com/mikel/mail/issues/912#issuecomment-170121429
gem 'record_tag_helper', '~> 1.0'

gem 'sprockets', '4.0.0.beta4'
gem 'sprockets-rails'

gem 'babel-transpiler'

gem 'scout_apm', '~> 2.0.x'
gem 'yard'

gem 'sentry-raven'
gem 'oj'
gem 'rack-canonical-host'

gem 'stackprof'
gem 'bootsnap', require: false
gem 'rbtrace'
gem 'tunemygc'
gem 'trashed'
