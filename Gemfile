# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.6.5'

git_source :github do |name|
  "https://github.com/#{name}.git"
end

gem 'mime-types', '~> 3.3', require: 'mime/types/columnar'

# Gems required in all environments
if ENV["RAILS_MASTER"] == '1'
  gem 'rails', git: 'https://github.com/rails/rails.git'
else
  gem 'rails', '6.0.1'
end

gem 'bluecloth'
gem 'dalli'
gem 'devise'
gem 'git_hub_bub'
gem 'jquery-rails'
gem 'local_time', '2.1.0'
gem 'maildown', '~> 3.1'
gem 'omniauth', '~> 1.9.0'
gem 'omniauth-github'
gem 'pg'
gem 'puma', github: "puma/puma"
gem 'rack-timeout'
gem 'rrrretry'
gem 'valid_email'
gem 'warden', '1.2.8'
gem 'wicked'
gem 'will_paginate', '3.2.1'
# gem 'sass-rails', '6.0.0.beta1'
gem 'sassc'
gem 'sassc-rails'

gem 'autoprefixer-rails', '~> 9.7.1'
gem 'bourbon'
gem 'coffee-rails', '~> 5.0.0'
gem 'neat', '~> 1.7'
gem 'normalize-rails'
gem 'slim-rails'
gem 'uglifier', '>= 1.0.3'
gem 'render_async', '~> 2.1'

group :development do
  gem 'bullet', require: false
  gem 'foreman'
  gem 'listen'
  gem 'spring'
  gem 'web-console'
  gem 'memory_profiler'
end

group :test do
  gem 'capybara', '3.29.0'
  # Not essential but helpful for save_and_open_page
  gem 'launchy'
  gem 'mocha', require: false
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webmock'
  gem 'test-prof'
end

group :development, :test do
  gem 'derailed_benchmarks'
  gem 'dotenv-rails', '2.7.5'
  gem 'faker', require: false
  gem 'pry'
  gem 'rubocop', require: false
  gem 'rubocop-performance'
end

gem 'rack-mini-profiler'

gem 'the_lone_dyno'

gem 'sidekiq'
gem 'sinatra', '~> 2.0.7'

gem 'aws-sdk', '~> 3'

gem 'mail', require: ['mail', 'mail/utilities', 'mail/parsers'] # parsers is used by `valid_email` and may be causing https://github.com/mikel/mail/issues/912#issuecomment-170121429

gem 'sprockets', github: "rails/sprockets"
gem 'sprockets-rails'

gem 'babel-transpiler'

gem 'scout_apm', '~> 2.6.3'
gem 'yard', '~> 0.9.20'

gem 'oj'
gem 'rack-canonical-host'
gem 'sentry-raven'

gem 'bootsnap', require: false
gem 'rbtrace'
gem 'redis-namespace'
gem 'stackprof'
gem 'flamegraph'
gem 'prawn'
gem 'skylight'

gem 'minitest', '5.13.0'
gem 'sitemap_generator'
gem 'premailer-rails'

gem 'barnes'
gem 'puma_worker_killer'
gem 'rake'
