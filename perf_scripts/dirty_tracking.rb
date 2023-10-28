# frozen_string_literal: true

require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table :topics, force: true do |t|
    t.string :title
    t.integer :user_id
    t.timestamps null: false
  end
end

class Topic < ActiveRecord::Base
  belongs_to :user
end

class User < ActiveRecord::Base
  has_many :topics
end

user = User.create!(name: "user name")
topic = user.topics.build(title: "topic title")

# Benchmark.ips do |x|
#   x.report("changed?") { topic.changed? }
#   x.report("changed") { topic.changed }
#   x.report("changes") { topic.changes }
#   x.report("changed_attributes") { topic.changed_attributes }
#   x.report("title_change") { topic.title_change }
#   x.report("title_was") { topic.title_was }
# end

Benchmark.bm { |x|
  x.report("title_was") {
    1_000_000.times {
      topic.title_was
    }
  }
}
