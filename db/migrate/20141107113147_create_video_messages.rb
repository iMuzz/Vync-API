class CreateVideoMessages < ActiveRecord::Migration
  def change
    create_table :video_messages do |t|
      t.string :title
      t.integer :reply_to_id
      t.integer :sender_id
      t.integer :recipient_id
      t.string :video_id
      t.datetime :created_at
    end
  end
end
