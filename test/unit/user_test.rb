require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test '#github_url returns github url' do
    assert User.new(:github => 'jroes').github_url == 'https://github.com/jroes'
  end

  test 'public scope should only return public users' do
    assert_equal 2, User.public.size
  end
end
