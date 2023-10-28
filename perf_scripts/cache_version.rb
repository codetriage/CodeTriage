# frozen_string_literal: true

require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.cache_versioning = true

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

mass_user_create = 1000.times.each.map do
  {name: "user"}
end

User.create(mass_user_create)

ALL_USERS = User.all

puts ALL_USERS.first.method(:cache_version).source_location

Benchmark.bm { |x|
  x.report("title_was") {
    ALL_USERS.each do |user|
      user.cache_version
    end
  }
}
