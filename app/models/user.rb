class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :zip, :phone_number, :twitter, :github

  has_many :products

  def self.find_for_github_oauth(auth, signed_in_resource=nil)
    user = signed_in_resource || User.where(:github => auth.info.nickname).first
    params = { :github   => auth.info.nickname }
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
end
