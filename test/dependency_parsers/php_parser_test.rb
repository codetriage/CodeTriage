# frozen_string_literal: true

require "test_helper"
require_relative "../../lib/dependency_parser/php/parse"

class PHPParserTest < ActiveSupport::TestCase
  test "returns nothing on invalid composer.lock" do
    parser = DependencyParser::PHP::Parse.new("invalid")
    parser.call
    refute parser.success?
    assert_equal({repos: [], language: "php"}, parser.direct)
  end

  test "returns the list of dependencies (with dev dependencies) for a small composer.lock file" do
    gemfile_lock = file_fixture("composer.lock").read

    parser = DependencyParser::PHP::Parse.new(gemfile_lock)
    parser.call

    composer_data = {
      repos: [
        {
          name: "doctrine/annotations",
          url: "https://github.com/doctrine/annotations.git",
          description: "Docblock Annotations Parser"
        },
        {
          name: "doctrine/cache",
          url: "https://github.com/doctrine/cache.git",
          description: "PHP Doctrine Cache library is a popular cache implementation that supports many different drivers such as redis, memcache, apc, mongodb and others."
        },
        {
          name: "phpunit/php-code-coverage",
          url: "https://github.com/sebastianbergmann/php-code-coverage.git",
          description: "Library that provides collection, processing, and rendering functionality for PHP code coverage information."
        }
      ],
      language: "php"
    }

    assert parser.success?
    assert_equal composer_data, parser.direct
  end
end
