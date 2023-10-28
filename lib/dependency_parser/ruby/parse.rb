# frozen_string_literal: true

require "bundler"
require "json"

module DependencyParser
  module Ruby
    class Parse
      attr_reader :errors

      def initialize(content)
        @content = content
        @errors = []
        @direct = []
      end

      def call
        validate_lockfile!(content)
        return if error?

        @direct = Bundler::LockfileParser.new(content).specs.map do |spec|
          fetch_spec(name: spec.name, version: spec.version)
        end.compact
      end

      def direct
        {repos: @direct, language: "ruby"}
      end

      def success?
        errors.empty?
      end

      def error?
        errors.any?
      end

      private

      attr_reader :content

      def validate_lockfile!(content)
        @errors << "No specs found" unless Bundler::LockfileParser.new(content).specs.any?
      end

      def fetch_spec(name:, version: nil)
        full_spec = fetcher.fetch_spec([name, version])
        {name: full_spec.name, url: extract_url(full_spec), description: full_spec.description}
      rescue
        @errors << "Invalid spec #{name}"
        nil
      end

      def extract_url(full_spec)
        url = full_spec.metadata["source_code_uri"] || full_spec.homepage
        url if url.include? "https://github.com/"
      end

      def fetcher
        @fetcher ||= Bundler::Fetcher.new(Bundler::Source::Rubygems::Remote.new("https://rubygems.org"))
      end
    end
  end
end
