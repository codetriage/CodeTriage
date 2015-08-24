class CreateLanguageSubscriptions < ActiveRecord::Migration
  def change
    create_table :language_subscriptions do |t|
      t.string      :user_name
      t.integer     :user_id
      t.string      :language
      t.datetime    :last_sent_at
      t.integer     :email_limit, default: 1

      t.timestamps
    end
  end
end
