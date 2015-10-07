class RepoSubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  def create
    repo = Repo.find(params[:repo_id])
    @repo_subscription = current_user.repo_subscriptions.new repo: repo
    if @repo_subscription.save
      RepoSubscription.background_send_triage_email(@repo_subscription.id)
      redirect_to repo, notice: I18n.t('repo_subscriptions.subscribed')
    else
      flash[:error] = "Something went wrong"
      redirect_to :back
    end
  end

  def destroy
    @repo_sub = current_user.repo_subscriptions.find params[:id]
    @repo_sub.destroy
    redirect_to :back
  end

  def update
    @repo_sub = current_user.repo_subscriptions.find params[:id]
    if @repo_sub.update_attributes(repo_subscription_params)
      flash[:success] = "Email preferences updated!"
    else
      flash[:error] = "Something went wrong"
    end
    redirect_to :back
  end

  private

    def repo_subscription_params
      params.require(:repo_subscription).permit(
        :email_limit
        )
    end
end
