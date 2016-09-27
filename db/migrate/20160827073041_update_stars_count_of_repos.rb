class UpdateStarsCountOfRepos < ActiveRecord::Migration[5.0]
  def change
    Repo.where.not(stars_count: nil).find_each do |repo|
      repo_path = File.join "repos", "#{repo.user_name}/#{repo.name}"
      resp = GitHubBub.get(repo_path).json_body
      repo.stars_count = resp["stargazers_count"]
      repo.save!
    end
  end
end
