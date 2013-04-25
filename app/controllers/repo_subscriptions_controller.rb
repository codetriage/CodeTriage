class RepoSubscriptionsController < ApplicationController
  before_filter :authenticate_user!

	def index
	  @repos_subs = current_user.repo_subscriptions.page(params[:page]||1).per_page(params[:per_page]||50)
	end

	def create
    repo = Repo.find(params[:repo_id])
		@repo_subscription = RepoSubscription.create(:repo => repo, :user => current_user)
    if @repo_subscription.save
      @repo_subscription.send_triage_email!
      redirect_to repo_subscriptions_path
    else
      flash[:error] = "Something went wrong"
      redirect_to :back
    end
	end

  def destroy
    @repo_sub = current_user.repo_subscriptions.where(:id => params[:id]).first
    @repo_sub.destroy
    redirect_to :back
  end

  def update
    @repo_sub = current_user.repo_subscriptions.where(:id => params[:id]).first
    if @repo_sub.update_attributes(params[:repo_subscription])
      flash[:success] = "Email preferences updated!"
      redirect_to :back
    else
      flash[:error] ="Something went wrong"
      redirect_to :back
    end
  end
end