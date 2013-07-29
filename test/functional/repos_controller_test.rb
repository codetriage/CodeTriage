require 'test_helper'

class ReposControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users, :repos

  test 'responds with 404 if repo does not exist' do
    assert_raise(ActiveRecord::RecordNotFound) {
      get :show, full_name: 'foobar'
    }
  end
end
