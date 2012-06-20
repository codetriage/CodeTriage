class RepoSubscriptionsControllerfe < ApplicationController

	def show
	  @repo_subscription = RepoSubscription.new
	end

	def create
		@repo_subscription
	end

end