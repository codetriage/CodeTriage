class RepoBasedController < ApplicationController
  protected

    def name_from_params(options)
      [options[:name], options[:format]].compact.join('.')
    end

    def find_repo(options)
      user_name = options[:user_name]
      name      = name_from_params(options)

      Repo.find_by_user_name_and_name(user_name, name)
    end
end
