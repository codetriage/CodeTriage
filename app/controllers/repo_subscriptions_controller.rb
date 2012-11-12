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
    @repo = current_user.repo_subscriptions.where(:id => params[:id]).first
    @repo.destroy
    redirect_to :back
  end

end
