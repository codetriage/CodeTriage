module MailBuilder
  # Takes in Issue Assignment IDs and Doc IDs and groups them together by repo
  #
  # The main purpose of this class is to make data easier to navigate for
  # rendering mail views, specifically the "daily triage" email.
  #
  # The main reason this exists is to minimize query time while rendering
  # mail views without sacraficing view readability.
  #
  # To access these elements you need to be inside of an `each` loop
  #
  #   group = GroupedIssuesDocs.new(User.last, assignment_ids: [99])
  #   group.each do |g|
  #     g.assignments # => [...]
  #     g.read_docs   # => [...]
  #     g.write_docs  # => [...]
  #     g.read_docs.each do |doc|
  #       g.comment_for_doc(doc) # => "..."
  #     end
  #   end
  #
  # There is a method `comment_for_doc` that will retrieve the documentation
  # comment object for a specific doc method.
  #
  # There are helper methods designed to make rendering views easier.
  # For example `GroupedIssuesDocs#actions` will return either "issues", "docs"
  # or "issues and docs" depending on the contents of the group.
  #
  # `GroupedIssuesDocs#any_docs?` returns true if there are docs in the group
  # `GroupedIssuesDocs#any_docs?` returns true if there are issues in the group
  #
  # Internally data is stored in a hash of hashes. The top level key is
  # the id of the repo subscription.
  #
  #   puts @sub_hashes
  #   {
  #     99 => {}
  #   }
  #
  # Each of these hashes has the following keys:
  #
  #   puts @sub_hashes.first.keys
  #   # => [:repo, :assignments, :read_docs, :write_docs]
  #
  # Each of these is an array except for repo.
  #
  # There is a helper hash @repo_id_to_sub that takes a repo id and
  # returns the subscription ID for that repo.
  #
  class GroupedIssuesDocs
    attr_accessor :any_docs, :any_issues

    alias :any_docs?   :any_docs
    alias :any_issues? :any_issues

    def initialize(user_id:, assignment_ids: [], read_doc_ids: [], write_doc_ids: [])
      @sub_hashes        = {}
      @repo_id_to_sub    = {}
      @doc_comments_hash = {}
      @error_hash        = Hash.new { raise "must call within each" }
      @active_hash       = @error_hash

      self.any_docs   = read_doc_ids.present? || write_doc_ids.present?
      self.any_issues = assignment_ids.present?

      ## Issue assignments
      assignments = IssueAssignment
                    .where(id: assignment_ids)
                    .includes(:issue)
                    .select(:id, :repo_subscription_id, :issue_id)

      ## Docs
      docs = DocMethod
             .where(id: write_doc_ids + read_doc_ids)
             .select(:id, :repo_id, :line, :file, :path)

      ## Comments
      doc_comments = DocComment
                     .where(doc_method_id: docs.map(&:id).uniq)
                     .select(:comment, :doc_method_id)

      ## Subscriptions
      doc_repo_ids = docs.map(&:repo_id).uniq
      subscriptions = RepoSubscription
                      .where(user_id: user_id)
                      .where(repo_id: doc_repo_ids)
                      .includes(:repo)
                      .select(:id, :repo_id)

      subscriptions += RepoSubscription
                       .joins(:issue_assignments)
                       .where("issue_assignments.id" => assignment_ids)
                       .where(user_id: user_id)
                       .where.not(repo_id: doc_repo_ids)
                       .includes(:repo)
                       .select(:id, :repo_id)

      subscriptions.uniq!

      store_subscriptions!(subscriptions)
      store_assignments!(assignments)
      store_docs!(
        docs:          docs,
        write_doc_ids: write_doc_ids,
        doc_comments:  doc_comments
      )
    end

    def store_subscriptions!(subscriptions)
      subscriptions.each do |sub|
        @repo_id_to_sub[sub.repo.id] = sub.id

        @sub_hashes[sub.id] ||= {}
        @sub_hashes[sub.id][:repo] = sub.repo
        @sub_hashes[sub.id][:assignments] ||= []
        @sub_hashes[sub.id][:read_docs]   ||= []
        @sub_hashes[sub.id][:write_docs]  ||= []
        @sub_hashes
      end
    end

    def store_assignments!(assignments)
      assignments.each do |assignment|
        @sub_hashes[assignment.repo_subscription_id][:assignments] << assignment
      end
    end

    def store_docs!(write_doc_ids:, docs:, doc_comments:)
      write_docs = []
      read_docs  = []
      docs.each do |doc|
        if write_doc_ids.include?(doc.id)
          write_docs << doc
        else
          read_docs << doc
        end
      end

      doc_comments.each do |comment|
        @doc_comments_hash[comment.doc_method_id] = comment
      end

      write_docs.each do |doc|
        sub_id = @repo_id_to_sub.fetch(doc.repo_id)
        @sub_hashes[sub_id][:write_docs] << doc
      end

      read_docs.each do |doc|
        sub_id = @repo_id_to_sub.fetch(doc.repo_id)
        @sub_hashes[sub_id][:read_docs] << doc
      end
    end

    def each
      @sub_hashes.each do |_, hash|
        @active_hash = hash
        yield self
        @active_hash = @error_hash
      end
    end

    def repo
      @active_hash[:repo]
    end

    def assignments
      @active_hash[:assignments]
    end

    def read_docs
      @active_hash[:read_docs]
    end

    def write_docs
      @active_hash[:write_docs]
    end

    def actions
      "issues" if !self.any_docs
      "docs"   if !self.any_issues
      "issues and docs"
    end

    def comment_for_doc(doc)
      @doc_comments_hash[doc.id]
    end

    def count
      @sub_hashes.length
    end
  end
end
