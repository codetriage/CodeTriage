class DocMethodsController < ApplicationController
  def show
    @doc     = DocMethod.where(id: params[:id])
                        .select(:id, :repo_id, :path, :line, :file, :doc_comments_count)
                        .includes(:repo)
                        .first
    @comment = @doc.doc_comments.select(:comment).first
    @repo    = @doc.repo
    @username = current_user.present? ? current_user.github : "<your name>"
    @branch   = GitBranchnameGenerator.new(username: @username, doc_path: @doc.path)

    set_title("Help Writing docs #{@doc.path} - #{@repo.full_name} #{@repo.language}")
    set_description("#{@doc.missing_docs? ? 'Write' : 'Read'} docs for #{@repo.name} starting with #{@doc.path}.")
  end

  def click_method_redirect
    doc        = DocMethod.find(params[:id])
    sub        = RepoSubscription.where(user_id: params[:user_id], repo: doc.repo).first
    assignment = DocAssignment.where(doc_method_id: doc.id, repo_subscription_id: sub.id).first

    if assignment&.user&.id.to_s == params[:user_id]
      assignment.user.record_click!
      assignment.update_attributes(clicked: true)
      assignment.user.update_attributes(last_clicked_at: Time.now)
      redirect_to doc_method_url(doc)
    else
      flash[:notice] = "Bad url, if this problem persists please open an issue github.com/codetriage/codetriage"
      redirect_to :root
    end
  rescue => e
    handle_development_click(error: e, url: doc_method_url(doc))
  end

  def click_source_redirect
    doc        = DocMethod.find(params[:id])
    sub        = RepoSubscription.find_by!(id: params[:user_id], repo: doc.repo)
    assignment = DocAssignment.find_by!(doc_method_id: doc.id, repo_subscription_id: sub.id)

    if assignment.user.id.to_s == params[:user_id]
      assignment.user.record_click!
      assignment.update_attributes(clicked: true)
      assignment.user.update_attributes(last_clicked_at: Time.now)
      redirect_to doc.to_github
    else
      flash[:notice] = "Bad url, if this problem persists please open an issue github.com/codetriage/codetriage"
      redirect_to :root
    end
  rescue => e
    handle_development_click(error: e, url: doc.to_github)
  end

  private def handle_development_click(error:, url:)
    raise error unless Rails.env.development?

    flash[:error] = error.inspect
    puts error.message
    puts error.backtrace
    redirect_to url
  end
end
