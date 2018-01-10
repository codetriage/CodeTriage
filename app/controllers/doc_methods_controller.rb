class DocMethodsController < ApplicationController
  def show
    @doc     = DocMethod.where(id: params[:id])
                        .select(:id, :repo_id, :path, :line, :file)
                        .includes(:repo)
                        .first
    @comment = @doc.doc_comments.select(:comment).first
    @repo    = @doc.repo

    # http://stackoverflow.com/questions/3651860/which-characters-are-illegal-within-a-branch-name
    @username = current_user.present? ? current_user.github : "<your name>"
    @branch   = "#{@username}/update-docs-#{@doc.path}-for-pr".gsub(/:|~|\^|\\|\.\./, "_")

    set_title("Help Writing docs #{@doc.path} - #{@repo.full_name} #{@repo.lang}")
    set_description("#{@doc.missing_docs? ? 'Write' : 'Read'} docs for #{@repo.name} starting with #{@doc.path}.")
  end

  def click_method_redirect
    doc        = DocMethod.find(params[:id])
    sub        = RepoSubscription.where(user_id: params[:user_id], repo: doc.repo).first
    assignment = DocAssignment.where(doc_method_id: doc.id, repo_subscription_id: sub.id).first

    if assignment&.user&.id.to_s == params[:user_id]
      assignment.update_attributes(clicked: true)
      assignment.user.update_attributes(last_clicked_at: Time.now)
      redirect_to doc_method_url(doc)
    else
      flash[:notice] = "Bad url, if this problem persists please open an issue github.com/codetriage/codetriage"
      redirect_to :root
    end
  end

  def click_source_redirect
    doc        = DocMethod.find(params[:id])
    sub        = RepoSubscription.find_by!(id: params[:user_id], repo: doc.repo)
    assignment = DocAssignment.find_by!(doc_method_id: doc.id, repo_subscription_id: sub.id)

    if assignment.user.id.to_s == params[:user_id]
      assignment.update_attributes(clicked: true)
      assignment.user.update_attributes(last_clicked_at: Time.now)
      redirect_to doc.to_github
    else
      flash[:notice] = "Bad url, if this problem persists please open an issue github.com/codetriage/codetriage"
      redirect_to :root
    end
  end
end
