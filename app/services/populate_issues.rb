class PopulateIssues
  def self.call(repo, state = 'open')
    new(repo, state).populate_multi_issues!
  end

  def initialize(repo, state)
    @repo = repo
    @state = state
  end

  def populate_multi_issues!
    page = 1
    while populate_issues(page)
      page += 1
    end
  end

  private

  def fetcher(page)
    GithubFetcher::Issues.new(
      user_name: user_name,
      name: name,
      page: page,
      state: state,
    )
  end

  attr_reader :repo, :state

  def populate_issues(page)
    response = fetcher(page).response

    if response.respond_to(:error)
      repo.update_attributes(github_error_msg: response.error)
      false
    else
      response.json_body.each do |issue_hash|
        logger.info "Issue: number: #{issue_hash['number']}, "\
                    "updated_at: #{issue_hash['updated_at']}"
        Issue.find_or_create_from_hash!(issue_hash, repo)
      end
    end
  end
end
