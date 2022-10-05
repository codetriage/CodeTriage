# frozen_string_literal: true

require 'test_helper'
require_relative '../../lib/dependency_parser/ruby/parse'

class UserMailerTest < ActiveSupport::TestCase
  test "returns nothing on invalid Gemfile.lock" do
    deps = DependencyParser::Ruby::Parse.new("invalid").call
    assert_equal [], JSON.parse(deps)
  end

  test "returns the list of gems for a small Gemfle" do
    gemfile_lock = <<-LOCKFILE
GEM
  remote: https://rubygems.org/
  specs:
    actioncable (6.1.4.1)
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

    deps = DependencyParser::Ruby::Parse.new(gemfile_lock).call
    assert_equal [{ "repos" => [{ "name" => "actioncable" }], "language" => "ruby" }], JSON.parse(deps)
  end
end
