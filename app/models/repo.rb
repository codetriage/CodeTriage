class Repo < ActiveRecord::Base

  def username_repo
    "#{user_name}/#{name}"
  end

  def to_params
  end

end
