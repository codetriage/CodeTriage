# frozen_string_literal: true

require 'test_helper'

class RepoLabelsAssignerTest < ActiveSupport::TestCase
  test '#create_and_associate_labels! creates labels' do
    repo = repos(:rails_rails)
    VCR.use_cassette('fetch_labels_for_repo', record: :once) do
      assigner = RepoLabelAssigner.new(repo: repo)
      assert_difference('Label.count', 30) do
        assigner.create_and_associate_labels!
      end
    end
  end

  test '#create_and_associate_labels! it does not create existing labels' do
    repo = repos(:rails_rails)
    Label.create!(name: :autoloading)
    VCR.use_cassette('fetch_labels_for_repo', record: :once) do
      assigner = RepoLabelAssigner.new(repo: repo)
      assigner.create_and_associate_labels!
      assert_equal Label.where(name: :autoloading).count, 1
    end
  end

  test '#create_and_associate_labels! it does not care about label case' do
    repo = repos(:rails_rails)
    VCR.use_cassette('fetch_labels_for_repo', record: :once) do
      assigner = RepoLabelAssigner.new(repo: repo)
      assigner.create_and_associate_labels!
      assert_equal Label.where(name: :ActionMailer).count, 0
    end
  end

  test '#create_and_associate_labels! associates labels with the repo' do
    repo = repos(:rails_rails)
    VCR.use_cassette('fetch_labels_for_repo', record: :once) do
      assigner = RepoLabelAssigner.new(repo: repo)
      assigner.create_and_associate_labels!
    end

    assert_equal Label.count, RepoLabel.where(repo: repo).count
  end
end
