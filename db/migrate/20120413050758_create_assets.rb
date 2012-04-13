class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string  :type
      t.string  :image
      t.string  :video
      t.string  :audio
      t.string  :font

      t.timestamps
    end

    add_index :assets, :type
  end
end
