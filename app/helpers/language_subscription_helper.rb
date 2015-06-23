module LanguageSubscriptionHelper
  def user_subscribed_to_language?(language)
    if user_signed_in? && current_user.language_subscriptions.exists?(language: language)
      return current_user.language_subscriptions.where(language: language).first
    end
    return false
  end
end
