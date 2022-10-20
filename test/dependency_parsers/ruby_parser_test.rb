# frozen_string_literal: true

require 'test_helper'
require_relative '../../lib/dependency_parser/ruby/parse'

class RubyParserTest < ActiveSupport::TestCase
  test "returns nothing on invalid Gemfile.lock" do
    parser = DependencyParser::Ruby::Parse.new("invalid")
    parser.call
    refute parser.success?
    assert_equal({ repos: [], language: "ruby" }, parser.direct)
  end

  test "returns the list of gems for a small Gemfle" do
    gemfile_lock = <<~LOCKFILE
      GEM
        remote: https://rubygems.org/
        specs:
          solid_use_case (2.2.0)
            actionpack (= 6.1.4.1)
            activesupport (= 6.1.4.1)
            nio4r (~> 2.0)
            websocket-driver (>= 0.6.1)

      PLATFORMS
        ruby

      DEPENDENCIES
        actioncable

      RUBY VERSION
         ruby 3.0.4p208

      BUNDLED WITH
         2.3.21

      LOCKFILE

    parser = DependencyParser::Ruby::Parse.new(gemfile_lock)
    VCR.use_cassette("dependency_parser/rubygems") do
      parser.call
    end

    gem_data = {
      repos:
        [{
          name: "solid_use_case",
          url: "https://github.com/mindeavor/solid_use_case",
          description: "Create use cases the way they were meant to be. Easily verify inputs at each step and seamlessly fail with custom error data and convenient pattern matching."
        }],
      language: "ruby"
    }

    assert parser.success?
    assert_equal gem_data, parser.direct
  end
end
