class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :private, :email, :password, :password_confirmation, :remember_me, :zip, :phone_number, :twitter, :github, :github_access_token, :avatar_url, :name

  has_many :repo_subscriptions, dependent: :destroy
  has_many :repos, :through => :repo_subscriptions

  has_many :issue_assignments, :through => :repo_subscriptions
  has_many :issues,            :through => :issue_assignments

  scope :public, where(private: false)

  # users that are not subscribed to any repos
  def self.inactive
    joins("LEFT OUTER JOIN repo_subscriptions on users.id = repo_subscriptions.user_id").where("repo_subscriptions.user_id is null")
  end

  def enqueue_inactive_email
    Resque.enqueue(InactiveEmail, self.id)
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

  def self.find_for_github_oauth(auth, signed_in_resource=nil)
    user = signed_in_resource || User.where(:github => auth.info.nickname).first
    params = {
      :github              => auth.info.nickname,
      :github_access_token => auth.credentials.token,
      :avatar_url => auth.extra.raw_info.avatar_url
    }

    if user
      user.update_attributes(params)
    else
      params = params.merge(:password => Devise.friendly_token[0,20],
                            :name     => auth.extra.raw_info.name,
                            :email    => auth.info.email)
      user = User.create(params)
    end
    user
  end

  def github_url
    "https://github.com/#{github}"
  end

  class InactiveEmail
    @queue = :inactive_email

    def self.perform(user_id)
      user = User.find(user_id.to_i)
      return false if user.repo_subscriptions.present?
      UserMailer.poke_inactive(user).deliver
    end
  end

end
