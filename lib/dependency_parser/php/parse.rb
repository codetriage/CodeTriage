# frozen_string_literal: true
require 'json'

module DependencyParser
  module PHP
    class Parse
      attr_reader :errors

      def initialize(content)
        @content = content
        @errors = []
        @direct = []
      end

      def call
        deps = JSON.parse(content, symbolize_names: true)
        @direct = deps[:packages].map do |package|
          { name: package[:name], url: package.dig(:source, :url), description: package[:description] }
        end
        @direct += deps[:'packages-dev'].map do |package|
          { name: package[:name], url: package.dig(:source, :url), description: package[:description] }
        end
      rescue StandardError
        @errors << 'Cannot parse lock file'
      end

      def direct
        { repos: @direct, language: "php" }
      end

      def success?
        errors.empty?
      end

      def error?
        errors.any?
      end

      private

      attr_reader :content
    end
  end
end
