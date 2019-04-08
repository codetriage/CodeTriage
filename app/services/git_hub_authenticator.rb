class GitHubAuthenticator
  def initialize(auth, current_user = nil)
    @auth = auth
    @current_user = current_user
  end

  def self.authenticate(auth, current_user = nil)
    new(auth, current_user).authenticate
  end

  def authenticate
    if (user = find_user)
      user.update_attributes!(github_params)
      user
    else
      User.create(user_params)
    end
  end

  private

  attr_reader :auth, :current_user

  def find_user
    current_user ||
      User.find_by(github: auth.info.nickname) ||
      User.find_by(email:  auth_email)
  end

  def auth_email
    @auth_email ||= auth.info.email
  end

  def token
    @token ||= auth.credentials.token
  end

  def github_email
    return auth_email if auth_email.present?
    GithubFetcher::Email.new(token: token).as_json.first
  end

  def github_params
    @github_params ||= {
      github: auth.info.nickname,
      github_access_token: token,
      avatar_url: auth.extra.raw_info.avatar_url
    }
  end

  def user_params
    github_params.merge(
      password: Devise.friendly_token[0, 20],
      name: auth.extra.raw_info.name,
      email: github_email
    )
  end
end
