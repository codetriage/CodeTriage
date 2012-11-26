class Array

  def sorted_repo_list
    self.sort_by{|r| r["full_name"].downcase }
  end

end
