class GithubUrlFromBasePathLine

  def initialize(base, commit_sha, path, line)
    @base = base
    @commit_sha = commit_sha
    @line = line
    @path = path
  end

  # https://github.com/codetriage/docs_doctor/blob/f5dd91595d5cdad0a2348515c6f715ef19c51070/app/models/github_url_from_base_path_line.rb#L10
  def to_github
    File.join(@base, 'blob', @commit_sha, @path, "#L#{@line}")
  end
end
