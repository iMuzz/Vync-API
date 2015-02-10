class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :device_id
      t.string :devicetoken
      t.string :username
      # t.string :phone_number
      t.string :email
      t.string :facebook_object_id
      # t.string :facebook_avatar_url

      t.datetime :created_at
    end
  end
end
