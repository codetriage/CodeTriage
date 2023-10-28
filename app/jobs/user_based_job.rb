# frozen_string_literal: true

# The purpose of this class is to provide
# a base class that any job that needs to accept
# a user can use.
#
# This class allows a job to either take an
# ActiveRecord instance or a user integer
#
# The context of which user the job is working
# on will be automatically added to scout
#
# Example:
#
#   class PrintUserGithubJob < UserBasedJob
#     def perform(user)
#       puts user.github
#     end
#   end
#
#  user = User.where(github: "schneems").first
#  PrintUserGithubJob.perform_now(user)
#  # => "schneems"
#
#  user_id = user.id
#  PrintUserGithubJob.perform_now(user_id)
#  # => "schneems"
class UserBasedJob < ApplicationJob
  around_perform do |job, block|
    user_or_id = job.arguments[0]
    user = if user_or_id.is_a?(Integer)
      User.find(user_or_id)
    else
      user_or_id
    end
    job.arguments[0] = user
    ScoutApm::Context.add_user(github: user.github)

    block.call
  end
end
