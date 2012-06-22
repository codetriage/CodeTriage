class Repo < ActiveRecord::Base

  validate :github_url_exists, :on => :create


  def github_url_exists
    response = HTTParty.get(github_url)
    if response.code != 200
      errors.add(:expiration_date, "cannot reach #{github_url} perhaps github is down?")
    end
  end

  def github_url
    File.join("http://github.com", username_repo)
  end

  def username_repo
    "#{user_name}/#{name}"
  end

  def to_params
  end

end
