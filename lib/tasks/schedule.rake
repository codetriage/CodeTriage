namespace :schedule do
  desc 'Sends triage emails'
  task triage_emails: :environment do
    User.find_each do |user|
      SendDailyTriageEmailJob.perform_later(user.id)
    end
  end

  desc 'Populates github issues'
  task populate_issues: :environment do
    Repo.find_each(&:populate_issues)
  end

  desc 'Marks issues as closed'
  task mark_closed: :environment do
    Issue.queue_mark_old_as_closed!
  end

  desc 'Sends an email to invite users to engage once a week'
  task poke_inactive: :environment do
    next unless Date.today.tuesday?
    User.inactive.each do |user|
      BackgroundInactiveEmailJob.perform_later(user.id)
    end
  end

  task clean_inactive_repos: :environment do
    # Repo.inactive.destroy_all
  end

  task check_user_auth: :environment do
    User.where.not(token: nil).find_each do |user|
      if user.auth_is_valid?
        # good
      else
        user.update_attributes(token: nil)
      end
    end
  end

  task warn_invalid_token: :environment do
    User.where(token: nil).find_each do |user|
      next unless Date.today.thursday?
      ::UserMailer.invalid_token(user).deliver
    end
  end
end
