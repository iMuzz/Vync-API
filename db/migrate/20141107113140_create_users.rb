class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :device_id
      t.string :device_token
      t.string :username
      t.string :email
      t.string :facebook_object_id

      t.datetime :created_at
    end
  end
end
