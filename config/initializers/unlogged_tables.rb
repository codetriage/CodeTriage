# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_tables = true if Rails.env.test?
end
