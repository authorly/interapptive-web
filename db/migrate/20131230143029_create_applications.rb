class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.integer :publish_request_id
      t.string  :provider
      t.string  :url
      t.timestamps
    end
  end
end
