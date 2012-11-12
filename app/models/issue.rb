class Issue < ActiveRecord::Base
  OPEN   = "open"
  CLOSED = "closed"

  validates :state, :inclusion => { :in => [OPEN, CLOSED] }

  belongs_to :repo, counter_cache: true

  after_save    :update_counter_cache
  after_destroy :update_counter_cache

  def update_counter_cache
    return true unless self.state_changed? # only continue if state has changed
    return true if repo.blank?
    self.repo.issues_count = Issue.where(state: 'open', repo_id: self.repo_id).count
    self.repo.save
  end

  def self.open
    where(:state => OPEN)
  end

  def self.closed
    where(:state => CLOSED)

  def closed?
    state == CLOSED
  end

  def open?
    state == OPEN
  end

  def public_url
    "https://github.com/repos/#{repo.user_name}/#{repo.name}/issues/#{number}"
  end

  def self.find_or_create_from_hash!(issue_hash, repo)
    issue =   Issue.where(:number  => issue_hash['number'], :repo_id  => repo.id).first
    issue ||= Issue.create(:number => issue_hash['number'], :repo     => repo)
    issue.update_attributes( :title           => issue_hash['title'],
                             :url             => issue_hash['url'],
                             :last_touched_at => DateTime.parse(issue_hash['updated_at']),
                             :state           => issue_hash['state'],
                             :html_url        => issue_hash['html_url'])

  end


  def self.queue_mark_old_as_closed!
    find_each(:conditions => ["state = ? and updated_at < ?", OPEN, 24.hours.ago]) do |issue|
      Resque.enqueue(MarkClosed, issue.id)
    end
  end

  class MarkClosed
    @queue = :mark_issues_closed
    def self.perform(id)
      issue = Issue.find(id)
      issue.update_attributes(:state => 'closed')
    end
  end

end
