namespace :schedule do

  desc "Sends triage emails"
  task :triage_emails => :environment do
    RepoSubscription.queue_triage_emails!
  end

  desc "Populates github issues"
  task :populate_issues => :environment do
    Repo.queue_populate_open_issues!
  end

  desc "Marks issues as closed"
  task :mark_closed => :environment do
    Issue.queue_mark_old_as_closed!
  end

  desc "Sends an email to invite users to engage once a week"
  task :poke_inactive => :environment do
    next unless Date.today.tuesday?
    User.inactive.each do |user|
      user.enqueue_inactive_email
    end
  end


end
