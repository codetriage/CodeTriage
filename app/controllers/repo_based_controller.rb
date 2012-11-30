class RepoBasedController < ApplicationController
  protected

    def name_from_params(options)
      [options[:name], options[:format]].compact.join('.')
    end

    def find_repo(options)
      name =  name_from_params(options)
      Repo.includes(:issues).where(user_name: options[:user_name], name: name).first
    end
end
