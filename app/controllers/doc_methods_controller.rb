class DocMethodsController < ApplicationController
  def show
    @doc  = DocMethod.find(params[:id])
    @repo = @doc.repo

    # http://stackoverflow.com/questions/3651860/which-characters-are-illegal-within-a-branch-name
    @username = current_user.present? ? current_user.github : "<your name>"

    @branch   = "#{ @username }/update-docs-#{ @doc.path }-for-pr".gsub(/:|~|\^|\\|\.\./, "_")
  end
end
