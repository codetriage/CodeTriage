require File.expand_path("../../../lib/sorted_repo_collection", __FILE__)

class ApiInfoController < RepoBasedController
  include ActionView::Helpers::DateHelper

  def show
    @repo    = find_repo(params)
    added_by = @repo.subscribers.where(private: false).order(:created_at).first&.github
    respond_to do |format|
      format.json do
        render json: {
          subscriber_count:  @repo.subscribers_count,
          added_by_username: added_by,
          time_ago:          time_ago_in_words(@repo.created_at),
          message:           "This is an unstable interface, do not use"
        }.to_json
      end
    end
  end
end
