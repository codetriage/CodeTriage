class LanguageSubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @subs = current_user.language_subscriptions
    lang = @subs.map { |sub| sub.language }
    unless @subs.empty?
      @repos = Repo.where(language: lang)
    else
      @repos = Repo.all
    end
  end

  def create
    language = params[:language_subscription][:language]
    @language_sub = current_user.language_subscriptions.new language: language
    if @language_sub.save
      LanguageSubscription.background_send_language_email @language_sub.id
      redirect_to :back, notice: "Awesome! You'll receive daily triage e-mails for this language."
    else
      flash[:error] = "Something went wrong"
      redirect_to :back
    end
  end

  def update
    @language_sub = current_user.language_subscriptions.find params[:id]
    if @language_sub.update_attributes language_subscription_params
      flash[:success] = "Email preferences updated!"
    else
      flash[:error] = "Something went wrong"
    end
  end

  def destroy
    @language_sub = current_user.language_subscriptions.find params[:id]
    @language_sub.destroy
    redirect_to :back
  end

  def send_issue
    @language_sub = current_user.language_subscriptions.find params[:id]
    LanguageSubscription.background_send_language_email @language_sub.id
    redirect_to :back, notice: "You will receive an email with your new issue shortly"
  end

  private

    def language_subscription_params
      params.require(:language_subscription).permit(:email_limit)
    end
end
