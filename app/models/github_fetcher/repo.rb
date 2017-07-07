module GithubFetcher
  class Repo
    attr_accessor :repo_path

    def initialize(full_name)
      @full_name = full_name
      @repo_path = File.join("/repos/", full_name)
    end

    def commit_sha
      @commit_sha ||= begin
        ::GitHubBub.get(
          File.join(repo_path, 'commits', repo_json['default_branch'])
        ).json_body['sha']
      rescue GitHubBub::RequestError
        nil
      end
    end

    def clone
      `cd #{dir} && git clone #{clone_url} 2>&1`
      return dir
    end

    def json
      @json ||= GitHubBub.get(repo_path).json_body
    end

    def issues(state = 'open', page = 1)
      begin
        IssuesResponse.new(GitHubBub.get(
          api_issues_path,
          state:     state,
          page:      page,
          sort:      'comments',
          direction: 'desc'
        ))
      rescue GitHubBub::RequestError => e
        if repo = ::Repo.where(full_name: @full_name).first
          repo.update_attributes(github_error_msg: e.message)
        end
        NullIssueResponse.new # return empty enumerable interface
      end
    end

    def api_issues_path
      File.join('repos', @full_name, '/issues')
    end

    def self.repos_for(token, kind, options)
      GitHubBub.get("/user/#{kind}", { token: token }.merge(options)).json_body
    end

    private

    def dir
      @dir ||= Dir.mktmpdir
    end

    def cleanup
      FileUtils.remove_entry(dir)
    end

    def clone_url
      repo_json["clone_url"]
    end

    def repo_json
      @repo_json ||= ::GitHubBub.get(repo_path).json_body
    end
  end
end
