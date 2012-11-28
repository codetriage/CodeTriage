require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test '#github_url returns github url' do
    assert User.new(:github => 'jroes').github_url == 'https://github.com/jroes'
  end

  test 'public scope should only return public users' do
    assert_equal 2, User.public.size
  end

  test 'able_to_edit_repo allows the correct rights' do
    u = User.new(:github => "bob")
    r = Repo.new(:user_name => "bob")
    assert u.able_to_edit_repo?(r)
    r2 = Repo.new(:user_name => "neilmiddleton")
    assert !u.able_to_edit_repo?(r2)
  end
end
