# frozen_string_literal: true

class RepoSubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: :resume

  def create
    @repo_subscription = create_or_update_subscription
    if @repo_subscription.save
      SendSingleTriageEmailJob.perform_later(@repo_subscription.id)
      redirect_to @repo_subscription.repo, notice: I18n.t("repo_subscriptions.subscribed")
    else
      flash[:error] = "Something went wrong"
      redirect_to repo_path(@repo_subscription.try(:repo) || Repo.find(repo_subscription_params[:repo_id]))
    end
  end

  def destroy
    @repo_sub = current_user.repo_subscriptions.find params[:id]
    repo = @repo_sub.repo
    @repo_sub.destroy
    redirect_to repo_path(repo)
  end

  def update
    @repo_sub = create_or_update_subscription
    if @repo_sub.save
      flash[:success] = "Preferences updated!"
    else
      flash[:error] = "Something went wrong"
    end
    redirect_to repo_path(@repo_sub.repo)
  end

  def resume
    repo_sub = RepoSubscription.find_signed(params[:signed_id], purpose: :resume_docs)
    if repo_sub
      repo_sub.update_columns(docs_last_click_at: Time.now, docs_reopt_in_sent_at: nil)
      redirect_to repo_sub.repo, notice: "Docs re-enabled — you'll start receiving them again soon."
    else
      flash[:error] = "That re-enable link is invalid or has expired."
      redirect_to :root
    end
  end

  def create_or_update_subscription
    repo_sub = current_user.repo_subscriptions.find(params[:id]) if params[:id]
    repo_sub ||= current_user.repo_subscriptions.new(repo: Repo.find(repo_subscription_params[:repo_id]))
    repo_sub.update(repo_subscription_params)
    repo_sub
  end

  private

  def repo_subscription_params
    params.require(:repo_subscription).permit(
      :repo_id,
      :email_limit,
      :write,
      :write_limit,
      :read,
      :read_limit
    )
  end
end
