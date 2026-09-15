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

  test "process enables YARD safe mode" do
    require "yard"
    YARD::Config.options[:safe_mode] = false

    Dir.mktmpdir do |repo_dir|
      FileUtils.mkdir_p(File.join(repo_dir, "lib"))
      File.write(File.join(repo_dir, "lib", "thing.rb"), "class Thing\n  def hello\n  end\nend\n")

      DocsDoctor::Parsers::Ruby::Yard.new(repo_dir).process

      assert YARD::Config.options[:safe_mode],
        "Expected process to run YARD in safe mode"
    end
  end

  test "process ignores the repo's .yardopts and still parses methods" do
    Dir.mktmpdir do |repo_dir|
      # If this .yardopts were honored, `--exclude lib` would drop lib/thing.rb
      # from parsing and Thing#hello would be missing.
      File.write(File.join(repo_dir, ".yardopts"), "--exclude lib\n")
      FileUtils.mkdir_p(File.join(repo_dir, "lib"))
      File.write(File.join(repo_dir, "lib", "thing.rb"), "class Thing\n  def hello\n  end\nend\n")

      parser = DocsDoctor::Parsers::Ruby::Yard.new(repo_dir)
      parser.process

      assert(parser.yard_objects.any? { |o| o.respond_to?(:path) && o.path == "Thing#hello" },
        "Expected the repo's .yardopts to be ignored so Thing#hello is still parsed")
    end
  end
end
