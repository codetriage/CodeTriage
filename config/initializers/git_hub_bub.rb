# frozen_string_literal: true

# I know it's awful but I don't have time to fix the GitHubBub API and this makes `rails c` not noisey
GitHubBub::Request.send(:remove_const, :GITHUB_VERSION)
GitHubBub::Request.send(:remove_const, :USER_AGENT)
GitHubBub::Request.send(:remove_const, :RETRIES)

GitHubBub::Request::GITHUB_VERSION = 'vnd.github.v3.full+json'
GitHubBub::Request::USER_AGENT = 'codetriage'
GitHubBub::Request::RETRIES = 3

class CodeTraigeRandomApiKeyStore
  def initialize
    @keys = []
    @mutex = Mutex.new
  end

  def call
    return ENV['GITHUB_API_KEY'] if ENV['GITHUB_API_KEY']

    until (key = @keys.pop)
      populate_keys
    end

    return key
  end

  private def get_key
    @keys.pop
  end

  private def populate_keys
    @mutex.synchronize do
      return if @keys.any?

      @keys = User.order("RANDOM()").where.not(token: nil).limit(2000).pluck(:token)
    end
  end
end

code_triage_random_api_key_store = CodeTraigeRandomApiKeyStore.new

# Auth all non authed requests (due to github request limits)
GitHubBub::Request.set_before_callback do |request|
  if request.token?
    # Request is authorized, do nothing
  else
    request.token = code_triage_random_api_key_store.call
  end
end
