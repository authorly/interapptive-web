class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :email,                  :null => false
      t.string   :username
      t.string   :role,                   :null => false, :default => 'user'
      t.string   :permalink
      t.string   :password_digest,        :null => false
      t.string   :auth_token
      t.string   :password_reset_token
      t.datetime :password_reset_sent_at

      t.timestamps
    end

    add_index :users, :email, :unique => true
  end
end
