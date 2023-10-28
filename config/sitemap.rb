# frozen_string_literal: true

# Set the host name for URL creation
require "aws-sdk-s3"

if ENV["BUCKETEER_BUCKET_NAME"]

  adapter = SitemapGenerator::AwsSdkAdapter.new(
    ENV["BUCKETEER_BUCKET_NAME"],
    aws_access_key_id: ENV["BUCKETEER_AWS_ACCESS_KEY_ID"],
    aws_secret_access_key: ENV["BUCKETEER_AWS_SECRET_ACCESS_KEY"],
    aws_region: ENV["BUCKETEER_AWS_REGION"]
  )
  SitemapGenerator::Sitemap.adapter = adapter
  SitemapGenerator::Sitemap.sitemaps_host = "https://#{ENV["BUCKETEER_BUCKET_NAME"]}.s3.amazonaws.com/"
  SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"
end

SitemapGenerator::Sitemap.create_index = true
SitemapGenerator::Sitemap.default_host = "https://www.codetriage.com"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #

  add "/", changefreq: "daily", priority: 0.9
  add "/what"
  add "/privacy"
  add "/support"

  Repo.find_each do |repo|
    add repo_path(repo), lastmod: repo.updated_at
  end

  # DocMethod.find_each do |m|
  #   add doc_method_path(m), lastmod: m.updated_at
  # end
end
