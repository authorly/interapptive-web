class CreateKeyframes < ActiveRecord::Migration
  def change
    create_table :keyframes do |t|
      t.references :scene

      t.timestamps
    end
    
    add_index :keyframes, :scene_id
  end
end
