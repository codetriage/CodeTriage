# frozen_string_literal: true

namespace :schedule do
  desc 'Sends triage emails'
  task triage_emails: :environment do
    User.with_repo_subscriptions.select(:id).find_each(batch_size: 1000) do |user|
      # TODO cache last_sent_at in the user object
      # and move filtering before we enqueue a ton of jobs into
      # redis
      SendDailyTriageEmailJob.perform_later(user.id)
    end
  end

  desc "pulls in files from repos and adds them to the database"
  task process_repos: :environment do
    Repo.where("docs_subscriber_count > 0").select(:id, :removed_from_github).find_each(batch_size: 1000) do |repo|
      next if repo.removed_from_github?

      PopulateDocsJob.perform_later(repo.id)
    end
  end

  desc 'Populates github issues'
  task populate_issues: :environment do
    Repo.select(:id, :removed_from_github).find_each(batch_size: 100) do |repo|
      next if repo.removed_from_github?

      PopulateIssuesJob.perform_later(repo.id)
    end
  end

  def github_api_up?
    # Github switched where their status page is hosted
    # and they no longer report programatically
    # one way to test is by exercising the API for a value
    # that should be known to exist.

    return GithubFetcher::Repo.new(user_name: "rails", name: "rails").success?
  end

  desc "Update repos information"
  task update_repos: :environment do
    raise "GITHUB API APPEARS TO BE DOWN" unless github_api_up?

    Repo.find_each(batch_size: 100) do |repo|
      repo.update_repo_info!
    end
  end

  desc 'Marks issues as closed'
  task mark_closed: :environment do
    Issue.queue_mark_old_as_closed!
    Repo.find_each(batch_size: 100) do |repo|
      next if repo.removed_from_github?

      repo.force_issues_count_sync!
    end
  end

  desc 'Sends an email to invite users to engage once a week'
  task poke_inactive: :environment do
    next unless Date.today.tuesday?


    perc_90_issues_count = ActiveRecord::Base.connection.select_one("SELECT PERCENTILE_CONT(0.90) WITHIN GROUP(ORDER BY issues_count) FROM repos;")["percentile_cont"]
    perc_90_subscriber_count = ActiveRecord::Base.connection.select_one("SELECT PERCENTILE_CONT(0.90) WITHIN GROUP(ORDER BY subscribers_count) FROM repos;")["percentile_cont"]

    User.inactive.find_each(batch_size: 100) do |user|
      BackgroundInactiveEmailJob.perform_later(
        user,
        min_issue_count: perc_90_issues_count,
        min_subscriber_count: perc_90_subscriber_count)
    end
  end

  task clean_inactive_repos: :environment do
    # Repo.inactive.destroy_all
  end

  task check_user_auth: :environment do
    # Why doesn't this work?
    #
    #   token = User.where(github: "schneems").pluck(:token).first
    #   GithubFetcher::User.new(token: token).valid?
    #
    # disabling it until I can make it more robust
    #
    next
    raise "GITHUB API APPEARS TO BE DOWN" unless github_api_up?

    User.where.not(token: nil).find_each(batch_size: 100) do |user|
      # Check multiple times if token is not valid
      # if token is valid once, go to next user
      next if user.auth_is_valid?
      next if user.auth_is_valid?
      next if user.auth_is_valid?

      # Archive bad token
      user.update(token: nil, old_token: user.token)
    end
  end

  task warn_invalid_token: :environment do
    next unless Date.today.thursday?
    User.where(token: nil).find_each(batch_size: 100) do |user|
      UserMailer.invalid_token(user: user).deliver_later
    end
  end

  desc 'sitemaps'
  task sitemap: :environment do
    next unless Date.today.sunday?
    Rake::Task['sitemap:refresh'].invoke
  end

  desc 'fetch and assign labels for repos'
  task fetch_labels_and_assign: :environment do
    Repo.find_each(batch_size: 100) do |repo|
      RepoLabelAssigner.new(repo: repo).create_and_associate_labels!
    end
  end
end
