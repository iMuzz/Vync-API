class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :device_id
      t.string :devicetoken
      t.string :username
      t.datetime :created_at
    end
  end
end
