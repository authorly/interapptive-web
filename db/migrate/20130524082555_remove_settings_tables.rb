class RemoveSettingsTables < ActiveRecord::Migration
  def up
    drop_table 'settings'
  end

  def down
    create_table 'settings', :force => true do |t|
      t.string   'type'
      t.integer  'scene_id'
      t.integer  'storybook_id'
      t.integer  'font_id'
      t.integer  'font_size'
      t.datetime 'created_at',   :null => false
      t.datetime 'updated_at',   :null => false
    end
  end
end
