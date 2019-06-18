# frozen_string_literal: true

require 'bundler'
Bundler.setup

require 'derailed_benchmarks'
require 'derailed_benchmarks/tasks'

ENV["RAILS_LOG_TO_STDOUT"]      ||= "1"
ENV["RAILS_SERVE_STATIC_FILES"] ||= "1"
ENV["SECRET_KEY_BASE"]          ||= "lol"
ENV["DEVISE_SECRET_KEY"]        ||= "lol"
