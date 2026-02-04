# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

# Core
gem "rails", "8.1.2"

# API & Networking
gem "git_hub_bub"

# Application server & middleware
gem "puma", "7.2.0"
gem "puma_worker_killer"
gem "rack-timeout"
gem "rack-canonical-host"

# Assets
gem "autoprefixer-rails"
gem "babel-transpiler"
gem "bourbon"
gem "coffee-rails", "~> 5.0.0"
gem "neat", "~> 1.7"
gem "normalize-rails"
gem "sassc"
gem "sassc-rails"
gem "slim-rails"
gem "sprockets"
gem "sprockets-rails"
gem "terser"

# Authentication & Authorization
gem "devise"
gem "omniauth"
gem "omniauth-rails_csrf_protection"
gem "omniauth-github"

# Backgroud jobs
gem "sidekiq"
gem "sinatra"

# Caching
gem "dalli"

# Database
gem "pg"

# Email
gem "mail", require: ["mail", "mail/utilities", "mail/parsers"] # parsers is used by `valid_email` and may be causing https://github.com/mikel/mail/issues/912#issuecomment-170121429
gem "premailer-rails"
gem "valid_email"

# File Handling & Data Processing
gem "mime-types", require: "mime/types/columnar"

# JavaScript
gem "jquery-rails"
gem "render_async"

# JSON
gem "oj"

# Views
gem "bluecloth"
gem "local_time"
gem "maildown"
gem "wicked"

# Pagination
gem "will_paginate"

# Performance & Monitoring
gem "bootsnap", require: false
gem "flamegraph"
gem "matrix"
gem "prawn"
gem "rack-mini-profiler"
gem "rails-autoscale-web"
gem "rbtrace"
gem "sentry-ruby"
gem "sentry-rails"
gem "scout_apm"
gem "skylight"
gem "stackprof"

# SEO & Sitemaps
gem "sitemap_generator"

# Storage
gem "aws-sdk-s3"

# Utilities
gem "ostruct" # Required for Ruby 4.0+
gem "rake"
gem "rrrretry"

# Parse Ruby documentation
gem "yard", "~> 0.9.28"

group :development do
  gem "foreman"
  gem "listen"
  gem "memory_profiler"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "launchy" # Not essential but helpful for save_and_open_page
  gem "minitest"
  gem "minitest-mock" # Required for minitest 6.0+
  gem "mocha", require: false
  gem "rails-controller-testing"
  gem "simplecov", require: false
  gem "test-prof"
  gem "vcr"
  gem "webmock"
end

group :development, :test do
  gem "derailed_benchmarks"
  gem "dotenv-rails"
  gem "faker", require: false
  gem "pry"
  gem "standard", ">= 1.35.1"
  gem "standardrb", require: false
  gem "rubocop-performance"
end
