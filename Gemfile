source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '> 2.5', '< 2.7'

git_source :github do |name|
  "https://github.com/#{name}.git"
end

gem 'mime-types', '~> 2.6.1', require: 'mime/types/columnar'

# Gems required in all environments
if ENV["RAILS_MASTER"] == '1'
  gem 'arel', git: 'https://github.com/rails/arel.git'
  gem 'rails', git: 'https://github.com/rails/rails.git'
else
  gem 'rails', '5.1.4'
end

gem 'bluecloth'
gem 'dalli'
gem 'devise'
gem 'git_hub_bub'
gem 'jquery-rails'
gem 'local_time', '2.0'
gem 'mail_view', '~> 1.0.2'
gem 'maildown', '2.0.0'
gem 'omniauth', '~> 1.3.2'
gem 'omniauth-github'
gem 'pg'
gem 'puma', '~> 3.x'
gem 'rack-timeout'
gem 'rails_autolink'
gem 'rrrretry'
gem 'valid_email'
gem 'warden', '1.2.6'
gem 'wicked'
gem 'will_paginate', '3.1.0'
# gem 'sass-rails', '6.0.0.beta1'
gem 'sassc'
gem 'sassc-rails'

gem 'autoprefixer-rails', '~> 6.3.3'
gem 'bourbon'
gem 'coffee-rails', '~> 4.2.0'
gem 'neat'
gem 'normalize-rails'
gem 'slim-rails'
gem 'uglifier', '>= 1.0.3'
gem 'render_async', '~> 1.1', '>= 1.1.2'

group :development do
  gem 'bullet'
  gem 'foreman'
  gem 'listen'
  gem 'spring'
  gem 'web-console'
end

group :test do
  gem 'capybara', '2.17.0'
  # Not essential but helpful for save_and_open_page
  gem 'launchy'
  gem 'mocha', require: false
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  gem 'derailed_benchmarks'
  gem 'dotenv-rails'
  gem 'faker', require: false
  gem 'pry'
  gem 'rubocop', '0.49.1', require: false
  gem 'teaspoon'
end

gem 'rack-mini-profiler'

gem 'the_lone_dyno'

gem 'sidekiq'
gem 'sinatra'

gem 'aws-sdk', '~> 2'

gem 'mail', require: ['mail', 'mail/utilities', 'mail/parsers'] # parsers is used by `valid_email` and may be causing https://github.com/mikel/mail/issues/912#issuecomment-170121429
gem 'record_tag_helper', '~> 1.0'

gem 'sprockets', github: "rails/sprockets"
gem 'sprockets-rails'

gem 'babel-transpiler'

gem 'scout_apm', '~> 2.3.x'
gem 'yard', '~> 0.9.12'

gem 'oj'
gem 'rack-canonical-host'
gem 'sentry-raven', github: "getsentry/raven-ruby" # @nateberkopec uses CodeTriage as a guineapig/canary for raven-ruby master

gem 'bootsnap', require: false
gem 'rbtrace'
gem 'redis-namespace'
gem 'barnes', git: "https://github.com/heroku/barnes"
gem 'stackprof'
gem 'prawn'
gem 'skylight'

gem 'minitest', '5.10.3'
gem 'sitemap_generator'
