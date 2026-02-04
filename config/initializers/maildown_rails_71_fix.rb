# frozen_string_literal: true

# Fix for maildown gem compatibility with Rails 7.1+
# Rails 7.1 changed ERB templates to return ActionView::OutputBuffer instead of String
# Kramdown expects a String, so we need to convert it.
#
# This can be removed once maildown is updated to handle this case.
require "kramdown"

Maildown::MarkdownEngine.set_html do |string|
  Kramdown::Document.new(string.to_s, input: "GFM").to_html
end
