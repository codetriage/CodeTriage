require "benchmark/ips"
require "action_view"
require "action_pack"
require "action_controller"
require "active_record"
require "stackprof"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :customers, force: true do |t|
    t.string :name
  end
end

class Customer < ActiveRecord::Base; end

class TestController < ActionController::Base
end

ActionView::PartialRenderer.collection_cache = ActiveSupport::Cache::MemoryStore.new
TestController.view_paths = [File.expand_path("perf_scripts/partial_cache")]

puts TestController.view_paths

# Create a bunch of data

letters = ("a".."z").to_a * 5
1000.times { Customer.create!(name: letters.sample(10).join) }

customers = Customer.all.to_a

controller_view = TestController.new.view_context

# Heat compilation cache and collection cache
controller_view.render("render_collection", customers: customers)
controller_view.render("render_collection_with_cache", customers: customers)

p ActionView::PartialRenderer.collection_cache # 1000 entries

Benchmark.ips do |x|
  x.report("collection render: no cache") do
    controller_view.render("render_collection", customers: customers)
  end

  x.report("collection render: with cache") do
    controller_view.render("render_collection_with_cache", customers: customers)
  end

  x.compare!
end
