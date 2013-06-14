class User < ActiveRecord::Base
  include ResqueDef

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable

  validates_uniqueness_of :email, :allow_blank => true, :if => :email_changed?
  validates_length_of       :password, :within => 8..128, :allow_blank => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :private, :email, :password, :password_confirmation, :remember_me, :zip, :phone_number, :twitter,
                  :github, :github_access_token, :avatar_url, :name, :favorite_languages, :daily_issue_limit

  has_many :repo_subscriptions, dependent: :destroy
  has_many :repos, :through => :repo_subscriptions

  has_many :issue_assignments, :through => :repo_subscriptions
  has_many :issues,            :through => :issue_assignments

  scope :public, where("private is not true")

  alias_attribute :token, :github_access_token

  def self.random
    order("RANDOM()")
  end

  # users that are not subscribed to any repos
  def self.inactive
    joins("LEFT OUTER JOIN repo_subscriptions on users.id = repo_subscriptions.user_id").where("repo_subscriptions.user_id is null")
  end

  def default_avatar_url
    "http://gravatar.com/avatar/default"
  end

  def enqueue_inactive_email
    background_inactive_email(self.id)
  end

  def able_to_edit_repo?(repo)
    repo.user_name == github
  end

  def public
    !private
  end
  alias :public? :public

  def not_yet_subscribed_to?(repo)
    !subscribed_to?(repo)
  end

  def subscribed_to?(repo)
    sub_from_repo(repo).present?
  end

  def sub_from_repo(repo)
    self.repo_subscriptions.where(:repo_id => repo.id).first
  end

  def github_json
    GitHubBub.get(api_path, token: self.token).json_body
  end

  def fetch_avatar_url
    github_json["avatar_url"]
  end

  def set_avatar_url!
    self.avatar_url = self.fetch_avatar_url || default_avatar_url
    self.save!
  end

  def self.find_for_github_oauth(auth, signed_in_resource=nil)
    user  = signed_in_resource || User.where(:github => auth.info.nickname).first
    token = auth.credentials.token
    params = {
      :github              => auth.info.nickname,
      :github_access_token => token,
      :avatar_url => auth.extra.raw_info.avatar_url
    }

    if user
      user.update_attributes(params)
    else
      email =  auth.info.email
      email =  GitHubBub.get("/user/emails", token: token).json_body.first if email.blank?
      params = params.merge(:password => Devise.friendly_token[0,20],
                            :name     => auth.extra.raw_info.name,
                            :email    => email)
      user = User.create(params)
    end
    user
  end

  def github_url
    "https://github.com/#{github}"
  end

  def api_path
    "/user"
  end

  def valid_email?
    begin
      Mail::Address.new(email)
      true
    rescue
      false
    end
  end

  resque_def(:background_inactive_email) do |id|
    user = User.find(id.to_i)
    return false if user.repo_subscriptions.present?
    UserMailer.poke_inactive(user).deliver
  end

  def self.queue_triage_emails!
    find_each do |user|
      user.send_daily_triage_email!
    end
  end

  def send_daily_triage_email!
    delay_send_daily_triage_email(self.id)
  end

  def send_daily_triage!
    subscriptions = self.repo_subscriptions.ready_for_triage.order('RANDOM()').limit(daily_issue_limit)
    issues        = subscriptions.map(&:assign_multi_issues!).flatten.compact
    return false if issues.blank?
    UserMailer.send_daily_triage(user: self, issues: issues).deliver
  end

  resque_def(:delay_send_daily_triage_email) do |id|
    User.find(id).send_daily_triage!
  end

  def favorite_language?(language)
    favorite_languages.include? language if favorite_languages
  end

  def has_favorite_languages?
    favorite_languages && !favorite_languages.empty?
  end

end

