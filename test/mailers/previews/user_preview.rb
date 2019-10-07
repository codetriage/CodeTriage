# frozen_string_literal: true

class UserPreview < ActionMailer::Preview
  def invalid_token
    user = User.last
    ::UserMailer.invalid_token(user: user)
  end

  # Pull data from existing fixtures
  def send_spam
    user    = User.last
    subject = "Big launch"
    message = "hello world"
    ::UserMailer.spam(user: user, subject: subject, message: message)
  end

  def send_triage_create
    user  = User.last
    repo  = Repo.order(Arel.sql("RANDOM()")).first
    issue = Issue.where(state: "open", repo_id: repo.id).where.not(number: nil).first!
    sub   = RepoSubscription.where(user_id: user.id, repo_id: repo.id).first_or_create!
    assignment = sub.issue_assignments.where(issue_id: issue.id).first_or_create!
    ::UserMailer.send_triage(user: user, repo: repo, assignment: assignment, create: true)
  end

  def send_triage
    user  = User.last
    repo  = Repo.order(Arel.sql("RANDOM()")).first
    issue = Issue.where(state: "open", repo_id: repo.id).where.not(number: nil).first!
    sub   = RepoSubscription.where(user_id: user.id, repo_id: repo.id).first_or_create!
    assignment = sub.issue_assignments.where(issue_id: issue.id).first_or_create!
    ::UserMailer.send_triage(user: user, repo: repo, assignment: assignment)
  end

  def send_daily_triage_mixed
    write_docs = DocMethod.order(Arel.sql("RANDOM()")).includes(:repo).missing_docs.first(rand(0..8))
    read_docs  = DocMethod.order(Arel.sql("RANDOM()")).includes(:repo).with_docs.first(rand(0..8))

    write_docs = DocMethod.order(Arel.sql("RANDOM()")).includes(:repo).first(rand(0..8)) if write_docs.blank?
    read_docs  = DocMethod.order(Arel.sql("RANDOM()")).includes(:repo).first(rand(0..8)) if read_docs.blank?

    user        = User.last
    assignments = []
    repos       = (write_docs + read_docs).map(&:repo)

    (write_docs + read_docs).each do |doc|
      RepoSubscription.where(
        user_id: user.id,
        repo_id: doc.repo.id
      ).first_or_create!
    end

    repos.each do |repo|
      issue_count = rand(3..5)
      issue_count.times.each do
        issue = Issue.where(state: "open", repo_id: repo.id).where.not(number: nil).first
        next if issue.nil?

        sub = RepoSubscription.where(
          user_id: user.id,
          repo_id: repo.id
        ).first_or_create!
        assignment = sub.issue_assignments.where(issue_id: issue.id).first_or_create!
        assignments << assignment
      end
    end

    ::UserMailer.send_daily_triage(
      user_id: user.id,
      assignment_ids: assignments.map(&:id),
      write_doc_ids: write_docs.map(&:id),
      read_doc_ids: read_docs.map(&:id)
    )
  end

  def send_daily_triage_issues_only
    issue_count = rand(3..5)
    user        = User.last
    assignments = []

    issue_count.times.each do
      issue = Issue
              .where(state: "open")
              .where.not(number: nil)
              .order(Arel.sql("RANDOM()"))
              .first

      next if issue.nil?

      sub        = RepoSubscription.where(user_id: user.id, repo_id: issue.repo.id).first_or_create!
      assignment = sub.issue_assignments.where(issue_id: issue.id).first_or_create!
      assignments << assignment
    end

    ::UserMailer.send_daily_triage(
      user_id: user.id,
      assignment_ids: assignments.map(&:id)
    )
  end

  def poke_inactive
    user = User.last
    ::UserMailer.poke_inactive(user: user)
  end

  def daily_docs
    user = User.last

    write_docs = DocMethod.order(Arel.sql("RANDOM()")).missing_docs.first(rand(0..8))
    read_docs  = DocMethod.order(Arel.sql("RANDOM()")).with_docs.first(rand(0..8))

    write_docs = DocMethod.order(Arel.sql("RANDOM()")).first(rand(0..8)) if write_docs.blank?
    read_docs  = DocMethod.order(Arel.sql("RANDOM()")).first(rand(0..8)) if read_docs.blank?

    ::UserMailer.daily_docs(
      user: user,
      write_docs: write_docs,
      read_docs: read_docs
    )
  end
end
