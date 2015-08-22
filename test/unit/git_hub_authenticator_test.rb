require 'test_helper'

class GitHubAuthenticatorTest < ActiveSupport::TestCase
  test "updates existing user params" do
    user  = users(:mockstar)
    oauth = OmniAuth::AuthHash.new(
      info: { email: 'mockstar@example.com', nickname: 'johndoe' },
      extra: { raw_info: { name: 'John Doe', avatar_url: 'avatar.png' } },
      credentials: { token: '123qwe' }
    )

    user = GitHubAuthenticator.authenticate oauth
    assert user.persisted?, 'user is persisted'
    assert_equal 'johndoe', user.github
    assert_equal 'mockstar@example.com', user.email
    assert_equal 'avatar.png', user.avatar_url
  end

  test "creates new user user when user does not exist and oauth contains email" do
    oauth = OmniAuth::AuthHash.new(
      info: { email: 'john.doe@example.com', nickname: 'johndoe' },
      extra: { raw_info: { name: 'john', avatar_url: 'avatar.png' } },
      credentials: { token: '123qwe' }
    )

    user = GitHubAuthenticator.authenticate oauth
    assert user.persisted?, 'user is persisted'
    assert_equal 'johndoe', user.github
    assert_equal 'john.doe@example.com', user.email
    assert_equal 'avatar.png', user.avatar_url
  end

  test "creates new user user when user does not exist and oauth does not contains email" do
    oauth = OmniAuth::AuthHash.new(
      info: { nickname: 'johndoe' },
      extra: { raw_info: { name: 'john', avatar_url: 'avatar.png' } },
      credentials: { token: '123qwe' }
    )

    emails = Struct.new(:json_body).new ['john.doe@example.com']
    GitHubBub.expects(:get).with("/user/emails", token: '123qwe')
      .returns emails

    user = GitHubAuthenticator.authenticate oauth
    assert user.persisted?, 'user is persisted'
    assert_equal 'john.doe@example.com', user.email
  end

end

