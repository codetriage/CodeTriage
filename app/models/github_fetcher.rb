class GithubFetcher
  attr_accessor :repo_path

  def initialize(repo_path)
    @repo_path = File.join("/repos/", repo_path)
  end

  def clone
    `cd #{dir} && git clone #{clone_url}`
    return dir
  end

  def commit_sha
    ::GitHubBub.get(File.join(repo_path, 'commits', repo_json['default_branch'])).json_body['sha']
  end

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
