class EnablePgStatExtension < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE extension IF NOT EXISTS "pg_stat_statements"
    SQL
  end
end
