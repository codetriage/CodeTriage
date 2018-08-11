require 'test_helper'

class GitBranchnameGeneratorTest < ActiveSupport::TestCase
  test "replaces non alpha-numerics and underscores with dashes" do
    doc_path = "Pay-)(*&^%$#@!~ment.charge?"
    assert_equal "username-update-docs-Pay------------ment-charge--for-pr",
                 GitBranchnameGenerator.new(username: "username", doc_path: doc_path).branchname
  end

  test "does not allow pounds (#)" do
    doc_path = "Payment#charge?"
    assert_equal "username-update-docs-Payment-charge--for-pr",
                 GitBranchnameGenerator.new(username: "username", doc_path: doc_path).branchname
  end

  test "does not allow periods" do
    doc_path = "Payment.charge?"
    assert_equal "username-update-docs-Payment-charge--for-pr",
                 GitBranchnameGenerator.new(username: "username", doc_path: doc_path).branchname
  end
end
