# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.new(
  github:     "schneems",
  email:      "foo@example.com",
  avatar_url: "https://avatars.githubusercontent.com/u/59744?v=3"
)
user.save(validate: false)
repo = user.repos.new(
  :user_name     => "schneems",
  :name          => "wicked",
  :issues_count  => 30,
  :language      => "Ruby",
  :description   => "A library or something",
  :full_name     => "schneems/wicked"
)
repo.save(validate: false)

repo.subscribers << user

100.times do |i|
  issue = repo.issues.new(
    number:     i,
    updated_at: Time.now,
    title:      "H3y did you know about #{i}",
    state:      "open",
    html_url:   "https://github.com/schneems/wicked/issues/#{i}"
  )
  issue.save
end
