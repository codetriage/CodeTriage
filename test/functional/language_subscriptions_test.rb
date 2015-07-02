require 'test_helper'

class LanguageSubscriptionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users, :repos, :language_subscriptions

  setup do
    request.env["HTTP_REFERER"] = "http://localhost:5000"
  end

  test 'successfully subscribe to ruby signed in as mockstar' do
    sign_in users(:mockstar)
    post :create, language_subscription: { language: "ruby" }
    assert flash[:notice] == "Awesome! You'll receive daily triage e-mails for this language."
    assert_redirected_to :back
  end

  test 'receive failure message when subscription did not created when signed in as mockstar' do
    sign_in users(:mockstar)
    LanguageSubscription.any_instance.stubs(:save).returns false
    post :create, language_subscription: { language: "ruby" }
    assert_equal flash[:error], "Something went wrong"
    assert_redirected_to :back
  end

  test "not update schneems' subscription when signed in as mockstar" do
    sign_in users(:mockstar)
    assert_raise ActiveRecord::RecordNotFound do
      patch :update, id: language_subscriptions(:schneems_to_ruby).id,
      language_subscription: { email_limit: 12 }
    end
  end

  test "not destroy schneems' subscription when signed in as mockstar" do
    sign_in users(:mockstar)
    assert_raise ActiveRecord::RecordNotFound do
      delete :destroy, id: language_subscriptions(:schneems_to_ruby).id
    end
  end

  test 'destroy a subscription' do
    sign_in users(:schneems)
    delete :destroy, id: language_subscriptions(:schneems_to_ruby).id
    assert_redirected_to :back
    assert_equal 0, LanguageSubscription.count
  end

  test 'update subscription limit when email limit is valid' do
    sign_in users(:schneems)
    patch :update, id: language_subscriptions(:schneems_to_ruby).id,
    language_subscription: { email_limit: 12 }
    assert_equal flash[:success], "Email preferences updated!"
    assert_redirected_to :back
  end

  test 'not update subscription when email limit is invalid' do
    sign_in users(:schneems)
    patch :update, id: language_subscriptions(:schneems_to_ruby).id,
    language_subscription: { email_limit: 0 }
    assert_equal flash[:error], "Something went wrong"
    assert_redirected_to :back
  end
end
