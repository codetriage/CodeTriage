class Issue < ActiveRecord::Base
  belongs_to :repo

  def self.open
    where(:state => 'open')
  end

  def self.closed
    where(:state => 'closed')
  end

  def public_url
    "http://github.com/repos/#{repo.user_name}/#{repo.name}/issues/#{number}"
  end

  def self.find_or_create_from_hash!(issue_hash, repo)
    issue =   Issue.where(:number => issue_hash['number']).first
    issue ||= Issue.create(:number => issue_hash['number'], :repo => repo)
    issue.update_attributes( :title           => issue_hash['title'],
                             :url             => issue_hash['url'],
                             :last_touched_at => DateTime.parse(issue_hash['updated_at']),
                             :state           => issue_hash['state'],
                             :html_url        => issue_hash['html_url'])

  end


  def self.queue_mark_old_as_closed!
    find_each(:conditions => ["state = 'open' and updated_at < ?", 24.hours.ago]) do |issue|
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
