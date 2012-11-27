class SubscribersController < RepoBasedController
  before_filter :fix_name
  before_filter :find_repo

  def show
    @subscribers = @repo.users.public.page(params[:page]).per_page(params[:per_page]||20)
  end
end
