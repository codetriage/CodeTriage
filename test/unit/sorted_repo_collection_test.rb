# frozen_string_literal: true

require 'test_helper'
require_relative '../../lib/sorted_repo_collection'

class SortedRepoCollectionTest < ActiveSupport::TestCase
  test "yields repos sorted by full_name, case-insensitive" do
    collection = SortedRepoCollection.new([
                                            { "full_name" => "alice/coolness" },
                                            { "full_name" => "Bob/bravado" },
                                            { "full_name" => "Bob/awesomeness" },
                                            { "full_name" => "alice/bravado" },
                                            { "full_name" => "charlie/bravado" }
                                          ])

    full_names_in_sort_order = Array.new
    collection.each do |repo|
      full_names_in_sort_order << repo.fetch("full_name")
    end

    expected_order = [
      "alice/bravado",
      "alice/coolness",
      "Bob/awesomeness",
      "Bob/bravado",
      "charlie/bravado"
    ]
    assert_equal expected_order, full_names_in_sort_order
  end

  test 'yields the correct length' do
    collection = SortedRepoCollection.new([
                                            { "full_name" => "alice/coolness" },
                                            { "full_name" => "Bob/bravado" },
                                            { "full_name" => "Bob/awesomeness" },
                                            { "full_name" => "alice/bravado" },
                                            { "full_name" => "charlie/bravado" }
                                          ])
    assert_equal collection.size, 5
  end
end
