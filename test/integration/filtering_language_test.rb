# frozen_string_literal: true

require "test_helper"

class FilteringLanguageTest < ActionDispatch::IntegrationTest
  teardown do
    Rails.cache.clear
  end

  test "filtering language in normal projects" do
    visit "/?language=Ruby"

    assert_equal page.all(".types-filter-button")[0].text, "Ruby"
  end
end
