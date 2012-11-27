class SortedRepoCollection
  include Enumerable

  def initialize(repos)
    @repos = repos.sort_by { |r| r.fetch("full_name").downcase }
  end

  def each
    @repos.each { |r| yield r }
  end

  def size
    @repos.length
  end

end
