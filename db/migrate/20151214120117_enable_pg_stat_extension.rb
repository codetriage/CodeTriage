class EnablePgStatExtension < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
      CREATE extension IF NOT EXISTS "pg_stat_statements"
    SQL
  end
end
