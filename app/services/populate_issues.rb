class PopulateIssues
  def self.call(repo, state = 'open')
    new(repo, state).populate_multi_issues!
  end

  def initialize(repo, state)
    @repo = repo
    @state = state
  end

  def populate_multi_issues!(page = 1)
    while populate_issues(page).more_issues?
      page += 1
    end
  end

  private

  attr_reader :repo, :state

  def populate_issues(page = 2)
    repo.fetcher.issues(state, page).tap do |response|
      response.each do |issue_hash|
        logger.info "Issue: number: #{issue_hash['number']}, "\
                    "updated_at: #{issue_hash['updated_at']}"
        Issue.find_or_create_from_hash!(issue_hash, repo)
      end
    end
  end
end
