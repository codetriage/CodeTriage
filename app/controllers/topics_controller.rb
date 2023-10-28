# frozen_string_literal: true

class TopicsController < ApplicationController
  TOPICS = ["hacktoberfest".html_safe].freeze
  before_action :set_topic

  def show
    set_title("Open Source Project Topic: #{@topic}")
    set_description("Open source repos labeled #{@topic}")

    label = Label.find_by(name: @topic)
    @repos = Repo.with_some_issues
      .joins(:repo_labels)
      .where(repo_labels: {label_id: label.id})
      .select(:id, :issues_count, :language, :full_name, :name, :description)

    @repos = @repos.order_by_issue_count.page(valid_params[:page]).per_page(valid_params[:per_page] || 50)
  end

  private def set_topic
    topic_name = valid_params["id"].downcase
    @topic = TOPICS.detect { |t| t == topic_name }

    if @topic.blank?
      redirect_back fallback_location: root_path, notice: "Invalid topic #{topic_name.inspect} not found in #{TOPICS.map(&:inspect).join(", ")}"
    end
  end

  private def valid_params
    params.permit(:id, :per_page, :page)
  end
end
