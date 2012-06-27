require 'clockwork'
include Clockwork


every(6.hours, 'send.triage.emails') do
  RepoSubscription.queue_triage_emails!
end

every(12.hours, 'repo.populate_issues') do
  Repo.queue_populate_open_issues!
end

every(24.hours, 'issue.mark_closed') do
  Issue.queue_mark_old_as_closed!
end