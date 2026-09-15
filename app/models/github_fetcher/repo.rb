# frozen_string_literal: true

require "open3"

module GithubFetcher
  class Repo < Resource
    UnsafeCloneUrlError = Class.new(StandardError)

    # Only clone from https://github.com. This rejects git's dangerous
    # transports (file://, ssh://, ext::…) and any host other than GitHub, in
    # case the API response is unexpected or has been tampered with.
    def self.safe_clone_url?(url)
      return false unless url.is_a?(String)

      uri = URI.parse(url)
      uri.scheme == "https" && uri.host == "github.com"
    rescue URI::InvalidURIError
      false
    end

    def initialize(options)
      @api_path = File.join(
        "repos",
        options.delete(:user_name),
        options.delete(:name)
      )
      super
    end

    def default_branch
      as_json["default_branch"]
    end

    # TODO - does this really belong here? Seems like it (and Repo#populate_docs!)
    #   should move into the PopulateDocs job
    def clone
      url = clone_url
      unless self.class.safe_clone_url?(url)
        raise UnsafeCloneUrlError, "Refusing to clone unexpected URL: #{url.inspect}"
      end

      # Array form runs git directly with no shell, so the URL can never be
      # interpreted by /bin/sh. GIT_TERMINAL_PROMPT=0 keeps a bad URL from
      # blocking on a credential prompt, and chdir lands the checkout in our
      # scratch dir (git creates a subdirectory named after the repo).
      out, status = Open3.capture2e(
        {"GIT_TERMINAL_PROMPT" => "0"},
        *git_clone_argv(url),
        chdir: dir
      )
      raise "Error executing git clone #{url.inspect}: #{out.inspect}" unless status.success?
      dir
    end

    private

    # Build the git argv as an array so it runs without a shell, and place the
    # URL after `--` so a URL beginning with `-` can't be parsed as a git
    # option. Shallow/single-branch/no-tags keep the checkout small.
    def git_clone_argv(url)
      [
        "git", "clone",
        "--depth", "1",
        "--single-branch",
        "--no-tags",
        "--", url
      ]
    end

    # TODO - moves w/ clone
    def dir
      @dir ||= Dir.mktmpdir
    end

    # TODO - moves w/ clone
    def clone_url
      as_json["clone_url"]
    end

    public def cleanup
      FileUtils.remove_entry(@dir) if @dir
    end
  end
end
