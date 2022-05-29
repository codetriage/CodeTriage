# frozen_string_literal: true

require File.expand_path("../../../lib/sorted_repo_collection", __FILE__)

class ReposController < RepoBasedController
  before_action :authenticate_user!, only: [:create, :edit, :update]
  before_action :default_format

  def new
    @repo = Repo.new(user_name: params[:user_name], name: params[:name])
    @full_name = @repo.name && @repo.user_name ? +"#{@repo.user_name}/#{@repo.name}" : nil
    @full_name.prepend("https://github.com/") if @full_name
    @repo_sub = RepoSubscription.new
  end

  def show
    record_count = 10
    @repo = find_repo(params)
    @issues = @repo.open_issues.select(:id, :title, :html_url).limit(record_count)
    @issues = paginate(@issues, after: params[:issues_after],
                                before: params[:issues_before])

    @docs   = @repo.doc_methods.select(:id, :doc_comments_count, :path).limit(record_count)
    @docs   = paginate(@docs, after: params[:docs_after],
                              before: params[:docs_before])

    @repo_sub    = current_user.repo_subscriptions_for(@repo.id).first if current_user
    @subscribers = @repo.subscribers.select(:private, :avatar_url, :github).limit(27)

    @docs_pagination   = params[:docs_after]   || params[:docs_before]
    @issues_pagination = params[:issues_after] || params[:issues_before]

    set_title("Help Contribute to #{@repo.full_name} - #{@repo.language}")
    set_description("Discover the easiest way to get started contributing to #{@repo.name} with our free community tools. #{@repo.subscribers_count} developers and counting")
  rescue ActiveRecord::RecordNotFound
    user_name, name = params[:full_name].split("/")
    redirect_to new_repo_url(user_name: user_name, name: name), notice: "Repo #{params[:full_name].inspect} is not added to CodeTriage yet, add it!"
  end

  def create
    parse_params_for_repo_info
    @repo   = Repo.search_by(params[:repo][:name], params[:repo][:user_name]).first unless params_blank?
    @repo ||= Repo.new(repo_params)
    if @repo.save
      @repo_sub = current_user.repo_subscriptions.create(repo: @repo)
      flash[:notice] = "Added #{@repo.to_param} for triaging"
      SendSingleTriageEmailJob.perform_later(@repo_sub.id, create: true)
      redirect_to @repo
    else
      @own_repos = current_user.own_repos_json
      render :new
    end
  end

  def edit
    @repo = find_repo(params)
    redirect_to root_path, notice: "You cannot edit this repo" unless current_user.able_to_edit_repo?(@repo)
  end

  def update
    @repo = find_repo(params)
    if @repo.update(repo_params)
      redirect_to @repo, notice: "Repo updated"
    else
      render :edit
    end
  end

  def list
    @repo = Repo.new(user_name: params[:user_name], name: name_from_params(params))
    if user_signed_in?
      case params[:show]
      when 'own'
        @repos = cached_repos 'repos', current_user.own_repos_json
      when 'starred'
        @repos = cached_repos 'starred', current_user.starred_repos_json
      when 'watched'
        @repos = cached_repos 'subscriptions', current_user.subscribed_repos_json
      end
    end
    render layout: nil
  end

  private

  def paginate(element, after: nil, before: nil)
    if after
      element = element.where("id < ?", after)
      element = element.order("id DESC")
    elsif before
      element = element.where("id > ?", before)
      element = element.order("id ASC")
      element = element.reverse
    else
      element = element.order("id DESC")
    end

    element
  end

  def default_format
    request.format = "html"
  end

  def repo_params
    params.require(:repo).permit(
      :notes,
      :name,
      :user_name,
      :issues_count,
      :stars_count,
      :language,
      :description,
      :full_name,
    )
  end

  def parse_params_for_repo_info
    return unless params[:url]
    params[:repo] ||= {}

    params[:url].gsub!(/(.*)github\.com\//, "")
    params[:url].gsub!(/\?(.*)/, "")

    url_array = params[:url].split("/")
    params[:repo][:name]      = url_array.pop || ""
    params[:repo][:user_name] = url_array.pop || ""
  end

  def params_blank?
    repo_params.blank?
  end

  def cached_repos(kind, repos_json)
    Rails.cache.fetch("user/#{kind}/#{current_user.id}", expires_in: 30.minutes) do
      SortedRepoCollection.new(repos_json)
    end
  end
end
