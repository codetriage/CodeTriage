class UserRepositorySubscriptions
  def self.queue_triage_emails!
    new.queue_triage_emails!
  end

  def queue_triage_emails!
    users_where_repository_nofitications_sent(23.hours.ago).find_each do |user|
      Resque.enqueue SendDigestEmail, user.id
    end
  end

  def users_where_repository_nofitications_sent time_ago
    user_join_repo_subs.where "last_sent_at is null or last_sent_at < ?", time_ago
  end

  private
    def user_join_repo_subs
      User.joins :repo_subscriptions
    end

  class SendDigestEmail
    @queue = :send_triage_email
    def self.perform(id)
      new(id).perform
    end

    def initialize id
      @id = id
    end
    attr_reader :id

    def perform
      mail = UserMailer.send_triage user: User.find(id), issues: user_issues
      mail.deliver!
    end

    private
      def user_issues
        user_repo_subscriptions.map { |sub| sub.assign_issue! false rescue nil }.compact
      end
      def user_repo_subscriptions
        RepoSubscription.includes(:user, :repo).where :user_id => id
      end
  end
end
