# frozen_string_literal: true
require 'bundler'
require 'json'

module DependencyParser
  module Ruby
    class Parse
      def initialize(content)
        @content = content
      end

      def call
        deps = Bundler::LockfileParser.new(content)
        parsed = deps.specs.map do |spec|
          { repos: [{ name: spec.name }], language: "ruby" }
        end
        JSON.pretty_generate(parsed)
      end

      private

      attr_reader :content

      def self.valid_gemfile?(content)
        Bundler::LockfileParser.new(content).specs.any?
      rescue
        false
      end
    end
  end
end

content = ARGF.read
puts DependencyParser::Ruby::Parse.new(content).call if DependencyParser::Ruby::Parse.valid_gemfile?(content)
