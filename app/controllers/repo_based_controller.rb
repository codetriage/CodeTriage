class RepoBasedController < ApplicationController
  protected

    def fix_name
      params[:name] = [params[:name], params[:format]].compact.join('.')
      true
    end

    def find_repo
      @repo = Repo.includes(:issues).
        where(user_name: params[:user_name], name: params[:name]).first

      if @repo.nil?
        redirect_to new_repo_path(user_name: params[:user_name], name: params[:name]), :notice => "Could not find repo: \"#{params[:user_name]}/#{params[:name]}\" on Code Triage, add it?"
      end
    end
end
