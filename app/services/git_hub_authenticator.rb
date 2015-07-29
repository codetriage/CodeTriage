class GitHubAuthenticator
  def self.authenticate(auth, signed_in_resource = nil)
    user  = signed_in_resource ||
            User.find_by(github: auth.info.nickname) ||
            User.find_by(email:  auth.info.email)

    token = auth.credentials.token
    params = {
      github:              auth.info.nickname,
      github_access_token: token,
      avatar_url: auth.extra.raw_info.avatar_url
    }

    if user
      user.update_attributes(params)
    else
      email =  auth.info.email
      email =  GitHubBub.get("/user/emails", token: token).json_body.first if email.blank?
      params = params.merge(password: Devise.friendly_token[0,20],
                            name:     auth.extra.raw_info.name,
                            email:    email)
      user = User.create(params)
    end
    user
  end
end
