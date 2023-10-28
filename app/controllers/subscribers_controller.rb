# frozen_string_literal: true

class SubscribersController < RepoBasedController
  def show
    @repo = find_repo(params)
    @subscribers = @repo.users.page(params[:page]).per_page(params[:per_page] || 50)
    set_title("Code helpers for #{@repo.full_name} - #{@repo.language}")
  end
end
