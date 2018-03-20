class DocMethod < ActiveRecord::Base
  NeedsDocs = "⚠ Needs Docs ⚠".freeze

  belongs_to :repo
  has_many   :doc_comments, dependent: :destroy, counter_cache: :doc_comments_count

  validates :raw_file, :name, :path, presence: true

  include ActiveRecord::CounterCache

  def self.missing_docs
    where(doc_methods: { doc_comments_count: 0 })
  end

  def self.active
    where(active: true)
  end

  def self.with_docs
    where("doc_comments_count > 0")
  end

  def missing_docs?
    doc_comments_count.zero?
  end

  def raw_file
    read_attribute(:file)
  end

  def file
    return nil if raw_file.blank?
    _absolute, _match, relative = raw_file.partition(/(\/|^)#{repo.name}\//i)
    return relative
  end

  # converts a doc method to a github path
  def to_github
    GithubUrlFromBasePathLine.new(repo.github_url, repo.commit_sha, file, line).to_github
  end
end
