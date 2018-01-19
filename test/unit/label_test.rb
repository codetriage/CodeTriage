require 'test_helper'

class LabelTest < ActiveSupport::TestCase
	 def setup
 		 @repo = repos(:rails_rails)
 		 @issue = Issue.create(state: "open", number: 4)
 		 @label = @repo.labels.create(name: "bug")
 	end

	 test "belongs to a repo" do
 		  assert_equal @repo, @label.repo
   end

  test "lists label issues" do
  	 @label.issues << @issue

  	 assert_equal [@issue], @label.issues
  end

  test "lists issue labels" do
  	 @issue.labels << @label

  	 assert_equal [@label], @issue.labels
  end

  test "valid label" do
  	 assert @label.valid?
  end

  test "invalid without name" do
  	 @label.name = nil
  	 refute @label.valid?, "save label without a name"
  	 assert_not_nil @label.errors[:name]
  end

  test "invalid without repo" do
  	 @label.repo = nil
  	 refute @label.valid?, "save label without a repo"
  	 assert_not_nil @label.errors[:name]
  end
end
