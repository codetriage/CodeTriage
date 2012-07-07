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

end
