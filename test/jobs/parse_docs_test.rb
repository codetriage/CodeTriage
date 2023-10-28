# frozen_string_literal: true

require "test_helper"

class ParseDocsTest < ActiveJob::TestCase
  test "Can parse yard docs" do
    repo = repos(:get_process_mem)
    assert_equal 0, repo.doc_methods.count

    parser = DocsDoctor::Parsers::Ruby::Yard.new(
      get_process_mem_disk_location
    )
    parser.process
    parser.store(repo)

    refute_equal 0, repo.doc_methods.count

    assert DocMethod.where(repo_id: repo).where(path: "GetProcessMem#initialize").any?
  end

  test "Does not error" do
    repos(:get_process_mem)
      .populate_docs!(
        location: get_process_mem_disk_location,
        commit_sha: repos(:get_process_mem).commit_sha,
        has_subscribers: true
      )
  end

  test "Errors are caught in fork" do
    assert_raise do
      DocsDoctor::Parsers::Ruby::Yard.new(
        get_process_mem_disk_location
      ).in_fork { raise "foo" }
    end
  end
end
