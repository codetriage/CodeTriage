class SubscribersController < RepoBasedController
  def show
    @repo        = find_repo(params)
    @subscribers = @repo.users.public.page(params[:page]).per_page(params[:per_page]||50)
  end
end
