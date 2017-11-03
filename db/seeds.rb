# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'faker'

Rails.application.configure do
  config.active_job.queue_adapter = :test
end

100.times do
  printf "."
  begin
    username = Faker::Internet.user_name.tr(".", "-")
    user = User.new(
      github:     username,
      email:      Faker::Internet.email,
      avatar_url: Faker::Avatar.image
    )
    user.save(validate: false)

    name = Faker::Hipster.word.gsub(/\W/, '')
    repo = user.repos.new(
      :user_name     => username,
      :name          => name,
      :issues_count  => rand(30),
      :language      => %w[Ruby PHP Go Javascript Java Swift].sample,
      :description   => Faker::Lorem.paragraph(1, true, 4),
      :full_name     => "#{username}/#{name}"
    )
    repo.save(validate: false)

    repo.subscribers << user

    rand(10).times do |i|
      issue = repo.issues.new(
        number:     i,
        updated_at: Faker::Time.between(DateTime.now - 30, DateTime.now),
        title:      Faker::Lorem.paragraph(1, true, 2),
        state:      "open",
        html_url:   "https://github.com/#{username}/#{name}/issues/#{i}"
      )
      issue.save
    end
  rescue # unique constraints, etc who cares
    next
  end
end
